import * as admin from "firebase-admin";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";

// Inicializa o SDK Admin para acessar Firestore e FCM com acesso total de servidor
admin.initializeApp();

export const sendEmergencyNotificationOnUpdate = onDocumentUpdated(
    "emergencies/{emergencyId}",
    async (event) => {
        // Garante que o evento contém dados antes e depois da alteração
        if (!event.data) return;

        const previousData = event.data.before.data();
        const newData = event.data.after.data();

        // 1. Regra de Negócio: Só dispara a notificação se o status mudou para 'active'
        if (previousData.status !== "active" && newData.status === "active") {
            const victimId = newData.victimId;

            try {
                // 2. Busca os dados do usuário para pegar o FCM Token salvo no Firestore
                const userDoc = await admin.firestore().collection("users").doc(victimId).get();

                if (!userDoc.exists) {
                    console.log(`Usuário ${victimId} não encontrado.`);
                    return;
                }

                const userData = userDoc.data();
                const userToken = userData?.fcmToken;

                if (!userToken) {
                    console.log(`Usuário ${victimId} não possui token FCM cadastrado.`);
                    return;
                }

                // 3. Monta o Payload da Notificação High Priority para Android/iOS
                const payload: admin.messaging.Message = {
                    token: userToken,
                    notification: {
                        title: "🚨 Alerta de Emergência!",
                        body: `${userData?.name || "Um protegido"} acionou o botão de emergência!`,
                    },
                    data: {
                        emergencyId: event.params.emergencyId,
                        victimId: victimId,
                        type: "EMERGENCY_ALERT",
                    },
                    android: {
                        priority: "high",
                        notification: {
                            channelId: "emergency_shortcut_channel_v2", // O mesmo canal do Android do seu Flutter
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

                // 4. Dispara a notificação via FCM
                const response = await admin.messaging().send(payload);
                console.log("Notificação enviada com sucesso! ID:", response);

            } catch (error) {
                console.error("Erro ao processar envio de notificação:", error);
            }
        }
    }
);