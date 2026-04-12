import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export interface NotificationPayload {
  targetUid: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

export async function sendPushNotification(payload: NotificationPayload): Promise<boolean> {
  try {
    const userDoc = await db.collection("users").doc(payload.targetUid).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      console.log(`FCM 토큰 없음: ${payload.targetUid}`);
      return false;
    }

    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data || {},
      android: {
        priority: "high",
        notification: {
          channelId: "ojak_default",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    });

    // 알림 기록 저장
    await db.collection("users").doc(payload.targetUid).collection("notifications").add({
      title: payload.title,
      body: payload.body,
      data: payload.data || {},
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return true;
  } catch (err) {
    console.error("푸시 알림 전송 실패:", err);
    return false;
  }
}

export const sendNotification = functions.https.onCall(
  async (data: NotificationPayload, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "인증이 필요합니다.");
    }

    const success = await sendPushNotification(data);
    return { success };
  }
);

// 매칭 알림 전용
export async function sendMatchNotification(
  uid: string,
  matchedWithName: string,
  matchId: string
): Promise<void> {
  await sendPushNotification({
    targetUid: uid,
    title: "새로운 매칭이 성립됐어요! 💕",
    body: `${matchedWithName}님과 서로 좋아요를 눌렀어요!`,
    data: { type: "match", matchId },
  });
}

// 메시지 알림 전용
export async function sendMessageNotification(
  targetUid: string,
  senderName: string,
  message: string,
  chatRoomId: string
): Promise<void> {
  await sendPushNotification({
    targetUid,
    title: `${senderName}님의 메시지`,
    body: message.length > 50 ? message.substring(0, 50) + "..." : message,
    data: { type: "message", chatRoomId },
  });
}

// 일일 운세 알림
export async function sendDailyFortuneNotification(targetUid: string): Promise<void> {
  await sendPushNotification({
    targetUid,
    title: "오늘의 운세가 도착했어요! 🌟",
    body: "사주로 보는 오늘의 운세를 확인해보세요.",
    data: { type: "fortune" },
  });
}