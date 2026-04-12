import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

export const processSwipe = functions.https.onCall(
  async (data: { targetUid: string; direction: "like" | "dislike" }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "인증이 필요합니다.");
    }

    const uid = context.auth.uid;
    const { targetUid, direction } = data;

    if (!targetUid || !direction) {
      throw new functions.https.HttpsError("invalid-argument", "targetUid와 direction이 필요합니다.");
    }

    // 스와이프 기록 저장
    await db
      .collection("users").doc(uid)
      .collection("swipes").doc(targetUid)
      .set({
        direction,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

    if (direction !== "like") {
      return { matched: false };
    }

    // 상대방이 나를 이미 좋아요 했는지 확인
    const reverseSwipe = await db
      .collection("users").doc(targetUid)
      .collection("swipes").doc(uid)
      .get();

    if (!reverseSwipe.exists || reverseSwipe.data()?.direction !== "like") {
      return { matched: false };
    }

    // 매칭 성립!
    const matchId = [uid, targetUid].sort().join("_");

    await db.collection("matches").doc(matchId).set({
      users: [uid, targetUid],
      matchedAt: admin.firestore.FieldValue.serverTimestamp(),
      status: "active",
      chatRoomId: matchId,
    });

    // 양쪽 유저의 matches 서브컬렉션에도 기록
    const batch = db.batch();
    batch.set(db.collection("users").doc(uid).collection("matches").doc(matchId), {
      matchedWith: targetUid,
      matchedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    batch.set(db.collection("users").doc(targetUid).collection("matches").doc(matchId), {
      matchedWith: uid,
      matchedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();

    // FCM 푸시 알림
    try {
      const targetUserDoc = await db.collection("users").doc(targetUid).get();
      const targetFcmToken = targetUserDoc.data()?.fcmToken;
      if (targetFcmToken) {
        await admin.messaging().send({
          token: targetFcmToken,
          notification: {
            title: "새로운 매칭! 💕",
            body: "누군가와 서로 좋아요를 눌렀어요! 지금 확인해보세요.",
          },
          data: {
            type: "match",
            matchId,
          },
        });
      }

      const userDoc = await db.collection("users").doc(uid).get();
      const userFcmToken = userDoc.data()?.fcmToken;
      if (userFcmToken) {
        await admin.messaging().send({
          token: userFcmToken,
          notification: {
            title: "새로운 매칭! 💕",
            body: "누군가와 서로 좋아요를 눌렀어요! 지금 확인해보세요.",
          },
          data: {
            type: "match",
            matchId,
          },
        });
      }
    } catch (err) {
      console.error("FCM 전송 실패:", err);
    }

    return { matched: true, matchId };
  }
);