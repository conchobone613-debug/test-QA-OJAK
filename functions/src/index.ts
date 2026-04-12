import * as admin from "firebase-admin";

admin.initializeApp();

// Saju engine
export { calculateSaju } from "./saju/calculateSaju";
export { calculateCompatibility } from "./saju/calculateCompatibility";

// Saju Cloud Functions
import * as functions from "firebase-functions";
import { calculateSaju as calcSaju } from "./saju/calculateSaju";
import { calculateCompatibility as calcCompat } from "./saju/calculateCompatibility";

export const getSaju = functions.https.onCall(
  async (data: { year: number; month: number; day: number; hour: number }, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "인증이 필요합니다.");
    }
    const result = calcSaju(data);
    return result;
  }
);

export const getCompatibility = functions.https.onCall(
  async (
    data: {
      personA: { year: number; month: number; day: number; hour: number };
      personB: { year: number; month: number; day: number; hour: number };
    },
    context
  ) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "인증이 필요합니다.");
    }
    const sajuA = calcSaju(data.personA);
    const sajuB = calcSaju(data.personB);
    const result = calcCompat(sajuA.wonGuk, sajuB.wonGuk);
    return {
      personA: sajuA,
      personB: sajuB,
      compatibility: result,
    };
  }
);

// Matching engine
export { generateRecommendations } from "./matching/generateRecommendations";
export { processSwipe } from "./matching/processSwipe";

// AI interpretation
export { generateInterpretation } from "./ai/generateInterpretation";
export { generateFortune } from "./ai/generateFortune";
export { generateIcebreaker } from "./ai/generateIcebreaker";

// Notifications
export { sendNotification } from "./notification/sendNotification";