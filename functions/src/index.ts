import * as admin from "firebase-admin";
import { onValueCreated } from "firebase-functions/v2/database";

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
                        console.warn(`[WARN] Guardião ${doc.id} não possui 'fcmToken' cadastrado.`);
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