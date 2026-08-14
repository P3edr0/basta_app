import * as admin from "firebase-admin";
import { DataSnapshot, getDatabase } from "firebase-admin/database";
import { onValueCreated } from "firebase-functions/v2/database";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

// Se admin e os outros imports já estiverem no topo do arquivo, não precisa repetir:
admin.initializeApp();

// 💡 onValueCreated garante que a função SÓ RODA UMA VEZ por emergência criada
export const sendEmergencyNotificationOnUpdate = onValueCreated(
    "emergencies/{userId}/{emergencyId}",
    async (event) => {
        const { userId, emergencyId } = event.params;
        console.log(`[ENTRY] Nova emergência criada! ID: ${emergencyId} (Vítima: ${userId})`);

        const newData = event.data.val();

        if (!newData) {
            console.log("[ABORT] Dados da emergência criados estão vazios.");
            return;
        }

        // Valida se foi criada com o status 'active' (caso crie com outro status inicial por algum motivo)
        if (newData.status !== "active") {
            console.log(`[FILTER] Emergência criada com status "${newData.status}". Ignorando notificação.`);
            return;
        }

        console.log(`[TRIGGER] Emergência ${emergencyId} válida e ativa. Iniciando envio de notificações...`);

        try {
            // 1. Extração dos guardiões
            const guardiansMap: Record<string, boolean> = newData.guardians || {};
            const guardianIds = Object.keys(guardiansMap).filter(
                (id) => guardiansMap[id] === true
            );

            console.log(`[GUARDIANS] Encontrados ${guardianIds.length} guardião(ões) na emergência:`, guardianIds);

            if (guardianIds.length === 0) {
                console.warn(`[WARN] Nenhum guardião ativo no Map da emergência ${emergencyId}. Abortando.`);
                return;
            }

            // 2. Busca o nome da vítima no Firestore
            console.log(`[FIRESTORE] Buscando documento da vítima (ID: ${userId})...`);
            const victimDoc = await admin.firestore().collection("users").doc(userId).get();

            let victimName = "Sua protegida";
            if (victimDoc.exists) {
                victimName = victimDoc.data()?.name || victimName;
                console.log(`[FIRESTORE] Nome da vítima recuperado: "${victimName}"`);
            } else {
                console.warn(`[WARN] Documento da vítima ${userId} não encontrado no Firestore. Usando nome padrão.`);
            }

            // 3. Busca os tokens FCM dos guardiões no Firestore
            console.log(`[FIRESTORE] Consultando tokens FCM para os ${guardianIds.length} guardiões...`);
            const guardianDocs = await Promise.all(
                guardianIds.map((id) => admin.firestore().collection("users").doc(id).get())
            );

            const guardianTokens: string[] = [];
            guardianDocs.forEach((doc) => {
                if (doc.exists) {
                    const token = doc.data()?.notificationToken;
                    if (token) {
                        guardianTokens.push(token);
                        console.log(`[TOKEN] Token encontrado para o guardião ${doc.id}`);
                    } else {
                        console.warn(`[WARN] Guardião ${doc.id} não possui 'notificationToken' cadastrado.`);
                    }
                } else {
                    console.warn(`[WARN] Documento do guardião ${doc.id} não foi encontrado no Firestore.`);
                }
            });

            console.log(`[TOKENS_SUMMARY] Total de tokens FCM válidos: ${guardianTokens.length} de ${guardianIds.length}`);

            if (guardianTokens.length === 0) {
                console.error(`[ERROR] Nenhum token FCM válido para envio.`);
                return;
            }

            // 4. Envio das Notificações Push
            const payload: admin.messaging.MulticastMessage = {
                tokens: guardianTokens,
                notification: {
                    title: "🚨 ALERTA DE EMERGÊNCIA!",
                    body: `${victimName} acionou o botão de emergência!`,

                },
                data: {
                    victimId: userId,
                    emergencyId: emergencyId,
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                    type: "EMERGENCY_ALERT",
                },
                android: {
                    priority: "high",
                    notification: {
                        sound: 'alert',
                        defaultSound: false,
                        channelId: 'emergency_channel_v3',
                        visibility: 'public',
                        notificationCount: 1,
                        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/basta-82cce.firebasestorage.app/o/assets%2Femergency_notification.jpg?alt=media&token=ca52544f-077a-4d21-b73d-193c9d2b1282'
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            mutableContent: true,
                            sound: 'alert.wav', // 👈 OBRIGATÓRIO: Nome completo com a extensão no iOS
                            'interruption-level': 'time-sensitive' // Tenta furar o modo Não Perturbe (requer permissão da Apple)
                        },

                    },
                    fcmOptions: {
                        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/basta-82cce.firebasestorage.app/o/assets%2Femergency_notification.jpg?alt=media&token=ca52544f-077a-4d21-b73d-193c9d2b1282'

                    }
                },
            };

            console.log(`[FCM] Enviando notificação para ${guardianTokens.length} dispositivo(s)...`);
            const response = await admin.messaging().sendEachForMulticast(payload);

            console.log(
                `[FCM_RESULT] Envio concluído! Sucessos: ${response.successCount} | Falhas: ${response.failureCount}`
            );

            if (response.failureCount > 0) {
                response.responses.forEach((res, idx) => {
                    if (!res.success) {
                        console.error(
                            `[FCM_TOKEN_ERROR] Falha no token ${guardianTokens[idx]}:`,
                            res.error
                        );
                    }
                });
            }

        } catch (error) {
            console.error(`[FATAL_ERROR] Erro ao processar emergência ${emergencyId}:`, error);
        }
    }
);



// -------------------------------------------------------------
// FUNÇÃO 2: Notificação e Atualização Mútua de Anjo Guardião
// -------------------------------------------------------------
export const sendGuardianOrderNotification = onDocumentWritten(
    "orders/{orderId}",
    async (event) => {
        const orderId = event.params.orderId;
        console.log(`[ORDER_ENTRY] Evento acionado para o pedido: ${orderId}`);

        // 1. Valida se o documento foi excluído
        if (!event.data?.after.exists) {
            console.log(`[ORDER_ABORT] Documento de pedido ${orderId} foi deletado.`);
            return;
        }

        const previousData = event.data.before.exists ? event.data.before.data() : null;
        const newData = event.data.after.data();

        if (!newData) {
            console.log(`[ORDER_ABORT] Dados do pedido ${orderId} estão vazios.`);
            return;
        }

        const previousAnswer = previousData?.answer;
        const newAnswer = newData.answer;
        const applicantId = newData.applicantId;
        const receiverId = newData.receiverId;

        console.log(
            `[ORDER_STATUS] Pedido: ${orderId} | Applicant: ${applicantId} | Receiver: ${receiverId} | PreviousAnswer: ${previousAnswer} | NewAnswer: ${newAnswer}`
        );

        try {
            // -------------------------------------------------------------------
            // CENÁRIO 1: Novo Pedido Criado (answer é null / undefined)
            // -------------------------------------------------------------------
            if ((previousAnswer === undefined || previousAnswer === null) && (newAnswer === null || newAnswer === undefined)) {
                console.log(`[ORDER_FLOW] Novo pedido detectado. Notificando receiverId: ${receiverId}`);

                if (!receiverId) {
                    console.warn(`[ORDER_WARN] 'receiverId' ausente no pedido ${orderId}.`);
                    return;
                }

                const applicantDoc = await admin.firestore().collection("users").doc(applicantId).get();
                const applicantName = applicantDoc.exists ? applicantDoc.data()?.name || "Alguém" : "Alguém";

                const receiverDoc = await admin.firestore().collection("users").doc(receiverId).get();
                const receiverToken = receiverDoc.data()?.notificationToken;

                if (!receiverToken) {
                    console.warn(`[ORDER_WARN] Receiver ${receiverId} não possui 'notificationToken' cadastrado.`);
                    return;
                }

                const payload: admin.messaging.Message = {
                    token: receiverToken,
                    notification: {
                        title: "🤝 Nova Solicitação de Anjo Guardião",
                        body: `${applicantName} enviou um pedido para ser seu anjo guardião!`,
                    },
                    data: {
                        orderId: orderId,
                        applicantId: applicantId,
                        type: "GUARDIAN_ORDER_RECEIVED",
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    android: {
                        priority: "high",
                        notification: {
                            channelId: "high_importance_channel",
                            sound: "default",
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                contentAvailable: true,
                                sound: "default",
                            },
                        },
                    },
                };

                const response = await admin.messaging().send(payload);
                console.log(`[ORDER_FCM_SUCCESS] Notificação de pedido criada enviada para ${receiverId}. ID: ${response}`);
                return;
            }

            // -------------------------------------------------------------------
            // CENÁRIO 2: Pedido Respondido (answer mudou de null para boolean)
            // -------------------------------------------------------------------
            if ((previousAnswer === null || previousAnswer === undefined) && typeof newAnswer === "boolean") {
                console.log(`[ORDER_FLOW] Pedido respondido com answer=${newAnswer}.`);

                if (!applicantId || !receiverId) {
                    console.warn(`[ORDER_WARN] 'applicantId' ou 'receiverId' ausentes no pedido ${orderId}.`);
                    return;
                }

                // =================================================================
                // MUTUALIDADE: Se aceito (answer === true), vincula ambos os usuários
                // =================================================================
                if (newAnswer === true) {
                    console.log(`[MUTUALITY] Pedido aceito! Atualizando a lista 'myGuardians' de ambos os usuários...`);

                    const batch = admin.firestore().batch();

                    const applicantRef = admin.firestore().collection("users").doc(applicantId);
                    // const receiverRef = admin.firestore().collection("users").doc(receiverId);

                    // Adiciona o guardião (receiverId) ao solicitante
                    batch.update(applicantRef, {
                        myGuardians: admin.firestore.FieldValue.arrayUnion(receiverId),
                    });

                    // // Adiciona o solicitante (applicantId) ao guardião (Relação mútua)
                    // batch.update(receiverRef, {
                    //     myGuardians: admin.firestore.FieldValue.arrayUnion(applicantId),
                    // });

                    await batch.commit();
                    console.log(`[MUTUALITY_SUCCESS] 'myGuardians' atualizado com sucesso em ambos os perfis!`);
                }

                // =================================================================
                // ENVIO DA NOTIFICAÇÃO DE RESPOSTA
                // =================================================================
                const receiverDoc = await admin.firestore().collection("users").doc(receiverId).get();
                const receiverName = receiverDoc.exists ? receiverDoc.data()?.name || "O usuário" : "O usuário";

                const applicantDoc = await admin.firestore().collection("users").doc(applicantId).get();
                const applicantToken = applicantDoc.data()?.notificationToken;

                if (!applicantToken) {
                    console.warn(`[ORDER_WARN] Solicitante ${applicantId} não possui 'notificationToken' cadastrado.`);
                    return;
                }

                const isAccepted = newAnswer === true;
                const title = isAccepted ? "✅ Pedido Aceito!" : "❌ Pedido Recusado";
                const body = isAccepted
                    ? `${receiverName} aceitou o seu pedido de anjo guardião.`
                    : `${receiverName} recusou o seu pedido de anjo guardião.`;

                const payload: admin.messaging.Message = {
                    token: applicantToken,
                    notification: {
                        title: title,
                        body: body,
                    },
                    data: {
                        orderId: orderId,
                        receiverId: receiverId,
                        status: isAccepted ? "accepted" : "rejected",
                        type: "GUARDIAN_ORDER_RESPONSE",
                        click_action: "FLUTTER_NOTIFICATION_CLICK",
                    },
                    android: {
                        priority: "high",
                        notification: {
                            channelId: "high_importance_channel",
                            sound: "default",
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                contentAvailable: true,
                                sound: "default",
                            },
                        },
                    },
                };

                const response = await admin.messaging().send(payload);
                console.log(`[ORDER_FCM_SUCCESS] Notificação de resposta enviada para ${applicantId}. ID: ${response}`);
                return;
            }

            console.log(`[ORDER_SKIP] Atualização no pedido ${orderId} ignorada.`);

        } catch (error) {
            console.error(`[ORDER_FATAL_ERROR] Erro ao processar o pedido ${orderId}:`, error);
        }
    }
);

// -------------------------------------------------------------
// FUNÇÃO 3: Fechamento de emergências inativas
// -------------------------------------------------------------

// 1. Interfaces de Tipagem
interface LocationData {
    last_update: number;
    latitude: number;
    longitude: number;
    status: string;
}

interface EmergencyData {
    status: string;
    date?: string | number;
    guardians?: Record<string, unknown>;
    locations?: Record<string, LocationData>;
    [key: string]: unknown;
}

// 2. Cloud Function V2 Agendada
export const closeInactiveEmergencies = onSchedule(
    {
        schedule: "every 20 minutes",
        timeZone: "America/Sao_Paulo", // Fuso horário padrão
    },
    async () => {
        const db = getDatabase();
        const emergenciesRef = db.ref("emergencies");

        const snapshot = await emergenciesRef.once("value");

        if (!snapshot.exists()) {
            console.log("Nenhuma emergência encontrada no banco de dados.");
            return;
        }

        const updates: Record<string, string> = {};
        const now = Date.now();
        const TWENTY_MINUTES_IN_MS = 20 * 60 * 1000; // 20 minutos em ms

        // 3. Itera sobre cada /emergencies/{userId}
        snapshot.forEach((userSnapshot: DataSnapshot) => {
            const userId = userSnapshot.key;
            console.log(`Analisando emergências do usuário ${userId}.`);

            // 4. Itera sobre cada /emergencies/{userId}/{emergencyId}
            userSnapshot.forEach((emergencySnapshot: DataSnapshot) => {
                const emergencyId = emergencySnapshot.key;
                const emergencyData = emergencySnapshot.val() as EmergencyData | null;

                // Processa apenas emergências ativas que tenham locais cadastrados
                if (
                    emergencyData &&
                    emergencyData.status === "active" &&
                    emergencyData.locations
                ) {
                    console.log(`Emergência ${emergencyId} do usuário  ${userId} está ativa.`);

                    let latestLocationId: string | null = null;
                    let latestUpdate = 0;

                    const locations = emergencyData.locations;

                    // Busca a localização com o maior timestamp (last_update)
                    for (const [locId, locData] of Object.entries(locations)) {
                        if (locData.last_update && locData.last_update > latestUpdate) {
                            latestUpdate = locData.last_update;
                            latestLocationId = locId;
                        }
                    }

                    // Se a última localização foi atualizada há mais de 1 hora
                    if (latestLocationId && now - latestUpdate > TWENTY_MINUTES_IN_MS) {
                        console.log(
                            `[EXPIRADO] Fechando emergência ${emergencyId} do usuário ${userId}`
                        );

                        // Prepara a atualização atômica do status da emergência e da última localização
                        updates[`emergencies/${userId}/${emergencyId}/status`] = "closed";
                        updates[
                            `emergencies/${userId}/${emergencyId}/locations/${latestLocationId}/status`
                        ] = "closed";
                        console.log(`Emergência ${emergencyId} está inativa e será encerrada.`);

                    } else {
                        console.log(`Emergência ${emergencyId} ainda é válida.`);

                    }
                }

                return false; // Necessário no DataSnapshot.forEach para TypeScript não interromper a iteração
            });

            return false;
        });

        // 5. Aplica as alterações no banco de uma só vez
        if (Object.keys(updates).length > 0) {
            await db.ref().update(updates);
            console.log(
                `Sucesso: ${Object.keys(updates).length / 2} emergência(s) inativa(s) encerrada(s).`
            );
        } else {
            console.log("Nenhuma emergência inativa precisou ser fechada.");
        }
    }
);


