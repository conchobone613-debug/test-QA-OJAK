import * as functions from "firebase-functions";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { CompatibilityResult } from "../saju/calculateCompatibility";
import { SajuWonGuk } from "../saju/sajuUtils";

const getGeminiModel = () => {
  const apiKey = functions.config().gemini?.apikey || process.env.GEMINI_API_KEY || "";
  const genAI = new GoogleGenerativeAI(apiKey);
  return genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
};

export interface InterpretationInput {
  personA: { name?: string; wonGuk: SajuWonGuk; gender: string };
  personB: { name?: string; wonGuk: SajuWonGuk; gender: string };
  compatibility: CompatibilityResult;
}

export async function generateInterpretationText(
  input: InterpretationInput
): Promise<string> {
  const model = getGeminiModel();

  const prompt = `당신은 한국 전통 사주 궁합 전문가입니다. 따뜻하고 희망적인 어조로 궁합 해석을 작성해주세요.

## 사주 정보
- A(${input.personA.gender}): 연주(${input.personA.wonGuk.year.cheongan}${input.personA.wonGuk.year.jiji}) 월주(${input.personA.wonGuk.month.cheongan}${input.personA.wonGuk.month.jiji}) 일주(${input.personA.wonGuk.day.cheongan}${input.personA.wonGuk.day.jiji}) 시주(${input.personA.wonGuk.hour.cheongan}${input.personA.wonGuk.hour.jiji})
- B(${input.personB.gender}): 연주(${input.personB.wonGuk.year.cheongan}${input.personB.wonGuk.year.jiji}) 월주(${input.personB.wonGuk.month.cheongan}${input.personB.wonGuk.month.jiji}) 일주(${input.personB.wonGuk.day.cheongan}${input.personB.wonGuk.day.jiji}) 시주(${input.personB.wonGuk.hour.cheongan}${input.personB.wonGuk.hour.jiji})

## 궁합 결과
- 총점: ${input.compatibility.totalScore}/1000
- 등급: ${input.compatibility.grade} ${input.compatibility.gradeEmoji}
- 천간 점수: ${input.compatibility.categories.cheonganScore}
- 지지 점수: ${input.compatibility.categories.jijiScore}
- 오행 점수: ${input.compatibility.categories.ohengScore}
- 음양 점수: ${input.compatibility.categories.yinyangScore}
- 일간 점수: ${input.compatibility.categories.ilganScore}

## 관계 분석
- 천간합: ${input.compatibility.relationships.cheonganHap}개
- 지지육합: ${input.compatibility.relationships.jijiYukHap}개
- 지지삼합: ${input.compatibility.relationships.jijiSamHap}개
- 지지충: ${input.compatibility.relationships.jijiChung}개
- 지지형: ${input.compatibility.relationships.jijiHyung}개

다음 구조로 300~500자 내로 작성해주세요:
1. 전체 궁합 요약 (2~3문장)
2. 강점 분석 (서로에게 좋은 점)
3. 주의점 (갈등 요소와 해결 방법)
4. 조언 (관계 발전을 위한 한마디)

부정적인 결과더라도 희망적이고 건설적인 조언으로 마무리하세요.`;

  const result = await model.generateContent(prompt);
  const response = result.response;
  return response.text();
}

export const generateInterpretation = functions.https.onCall(
  async (data: InterpretationInput, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "인증이 필요합니다.");
    }

    const text = await generateInterpretationText(data);
    return { interpretation: text };
  }
);