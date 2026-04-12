import * as functions from "firebase-functions";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { CompatibilityResult } from "../saju/calculateCompatibility";

const getGeminiModel = () => {
  const apiKey = functions.config().gemini?.apikey || process.env.GEMINI_API_KEY || "";
  const genAI = new GoogleGenerativeAI(apiKey);
  return genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
};

export interface IcebreakerInput {
  compatibility: CompatibilityResult;
  personAGender: string;
  personBGender: string;
}

export const generateIcebreaker = functions.https.onCall(
  async (data: IcebreakerInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "인증이 필요합니다.");
    }

    const model = getGeminiModel();

    const prompt = `당신은 소개팅/매칭 앱의 대화 도우미입니다.

두 사람의 사주 궁합 정보를 바탕으로 자연스럽고 재미있는 대화 주제 3개를 추천해주세요.

## 궁합 정보
- 총점: ${data.compatibility.totalScore}/1000
- 등급: ${data.compatibility.grade}
- 천간합: ${data.compatibility.relationships.cheonganHap}개
- 지지육합: ${data.compatibility.relationships.jijiYukHap}개

## 조건
- 사주/궁합 관련 재미있는 이야기를 포함
- 가벼우면서도 서로를 알아갈 수 있는 주제
- 각 주제는 1~2문장
- 이모지를 적절히 사용

JSON 배열로 반환:
["주제1", "주제2", "주제3"]`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();

    try {
      const jsonMatch = text.match(/\[[\s\S]*\]/);
      if (jsonMatch) {
        const topics: string[] = JSON.parse(jsonMatch[0]);
        return { topics: topics.slice(0, 3) };
      }
    } catch (e) {
      console.error("Icebreaker JSON 파싱 실패:", e);
    }

    return {
      topics: [
        "서로의 MBTI와 사주가 얼마나 맞는지 비교해볼까요? 🔮",
        "요즘 가장 행복했던 순간은 언제인가요? 😊",
        "함께 가보고 싶은 여행지가 있나요? ✈️",
      ],
    };
  }
);