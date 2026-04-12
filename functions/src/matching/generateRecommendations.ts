import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { calculateSaju } from "../saju/calculateSaju";
import { calculateCompatibility } from "../saju/calculateCompatibility";
import { filterCandidate, UserProfile } from "./matchingUtils";

const db = admin.firestore();

interface RecommendationItem {
  uid: string;
  score: number;
  grade: string;
  gradeEmoji: string;
}

export const generateRecommendations = functions.https.onCall(
  async (data: { uid: string; limit?: number }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "인증이 필요합니다.");
    }

    const uid = data.uid || context.auth.uid;
    const limit = data.limit || 20;

    const userDoc = await db.collection("users").doc(uid).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "사용자를 찾을 수 없습니다.");
    }

    const userData = userDoc.data() as UserProfile;
    const userSaju = calculateSaju({
      year: userData.birthDate.year,
      month: userData.birthDate.month,
      day: userData.birthDate.day,
      hour: userData.birthDate.hour,
    });

    // 이미 스와이프한 사용자 목록
    const swipedSnap = await db
      .collection("users").doc(uid)
      .collection("swipes")
      .get();
    const swipedUids = new Set(swipedSnap.docs.map((d) => d.id));
    swipedUids.add(uid);

    // 후보 사용자 쿼리
    const targetGender = userData.preferences?.preferredGender ||
      (userData.gender === "male" ? "female" : "male");

    const candidatesSnap = await db
      .collection("users")
      .where("gender", "==", targetGender)
      .limit(200)
      .get();

    const recommendations: RecommendationItem[] = [];

    for (const doc of candidatesSnap.docs) {
      if (swipedUids.has(doc.id)) continue;

      const candidate = { uid: doc.id, ...doc.data() } as UserProfile;

      if (!filterCandidate(userData, candidate)) continue;
      if (!candidate.birthDate) continue;

      const candidateSaju = calculateSaju({
        year: candidate.birthDate.year,
        month: candidate.birthDate.month,
        day: candidate.birthDate.day,
        hour: candidate.birthDate.hour,
      });

      const compat = calculateCompatibility(userSaju.wonGuk, candidateSaju.wonGuk);

      recommendations.push({
        uid: doc.id,
        score: compat.totalScore,
        grade: compat.grade,
        gradeEmoji: compat.gradeEmoji,
      });
    }

    // 점수 내림차순 정렬 → 상위 N명
    recommendations.sort((a, b) => b.score - a.score);
    const topPicks = recommendations.slice(0, limit);

    // 추천 결과 저장
    await db.collection("users").doc(uid).collection("recommendations").doc("latest").set({
      items: topPicks,
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { recommendations: topPicks };
  }
);