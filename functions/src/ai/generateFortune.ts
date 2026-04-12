import * as functions from "firebase-functions";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { SajuWonGuk } from "../saju/sajuUtils";

const getGeminiModel = () => {
  const apiKey = functions.config().gemini?.apikey || process.env.GEMINI_API_KEY || "";
  const genAI = new GoogleGenerativeAI(apiKey);
  return genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
};

export interface FortuneInput {
  wonGuk: SajuWonGuk;
  type: "daily" | "monthly";
  date: string; // YYYY-MM-DD
  gender: string;
}

export interface FortuneResult {
  overall: string;
  love: string;
  career: string;
  health: string;
  luckyColor: string;
  luckyNumber: number;
  rating: number; // 1-5
}

export const generateFortune = functions.https.onCall(
  async (data: FortuneInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "인증이 필요합니다.");
    }

    const model = getGeminiModel();
    const typeLabel = data.type === "daily" ? "오늘" : "이번 달";

    const prompt = `당신은 한국 전통 사주 운세 전문가입니다.

## 사주 원국
- 연주: ${data.wonGuk.year.cheongan}${data.wonGuk.year.jiji}
- 월주: ${data.wonGuk.month.cheongan}${data.wonGuk.month.jiji}
- 일주: ${data.wonGuk.day.cheongan}${data.wonGuk.day.jiji}
- 시주: ${data.wonGuk.hour.cheongan}${data.wonGuk.hour.jiji}
- 성별: ${data.gender}
- 날짜: ${data.date}

${typeLabel}의 운세를 JSON 형식으로 작성해주세요:
{
  "overall": "종합운 (2~3문장)",
  "love": "연애운 (1~2문장)",
  "career": "직장/학업운 (1~2문장)",
  "health": "건강운 (1문장)",
  "luckyColor": "행운의 색 (한 단어)",
  "luckyNumber": 행운의 숫자 (1~99),
  "rating": 전체 운세 등급 (1~5)
}

따뜻하고 긍정적인 어조로 작성하세요. JSON만 반환하세요.`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();

    try {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const fortune: FortuneResult = JSON.parse(jsonMatch[0]);
        return { fortune };
      }
    } catch (e) {
      console.error("Fortune JSON 파싱 실패:", e);
    }

    return {
      fortune: {
        overall: text,
        love: "",
        career: "",
        health: "",
        luckyColor: "파랑",
        luckyNumber: 7,
        rating: 3,
      } as FortuneResult,
    };
  }
);