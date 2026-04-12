import {
  SajuWonGuk,
  analyzeRelationships,
  analyzeOhengDistribution,
  getOheng,
  isOhengSangSaeng,
  isOhengSangGeuk,
  getYinYang,
  RelationshipAnalysis,
} from "./sajuUtils";

export interface CompatibilityResult {
  totalScore: number;
  grade: string;
  gradeEmoji: string;
  categories: {
    cheonganScore: number;
    jijiScore: number;
    ohengScore: number;
    yinyangScore: number;
    ilganScore: number;
  };
  relationships: RelationshipAnalysis;
  description: string;
}

export type CompatibilityGrade =
  | "천생연분"
  | "최상궁합"
  | "좋은인연"
  | "보통궁합"
  | "조심지연";

function getGrade(score: number): { grade: CompatibilityGrade; emoji: string } {
  if (score >= 900) return { grade: "천생연분", emoji: "💕" };
  if (score >= 750) return { grade: "최상궁합", emoji: "❤️" };
  if (score >= 550) return { grade: "좋은인연", emoji: "😊" };
  if (score >= 350) return { grade: "보통궁합", emoji: "🤝" };
  return { grade: "조심지연", emoji: "⚠️" };
}

function getGradeDescription(grade: CompatibilityGrade): string {
  switch (grade) {
    case "천생연분":
      return "하늘이 맺어준 인연! 서로의 부족함을 완벽하게 채워주는 최고의 궁합입니다.";
    case "최상궁합":
      return "매우 좋은 궁합입니다. 함께할수록 서로에게 긍정적인 에너지를 줍니다.";
    case "좋은인연":
      return "좋은 인연입니다. 서로 노력하면 더욱 깊은 관계로 발전할 수 있습니다.";
    case "보통궁합":
      return "평범한 궁합이지만, 서로의 차이를 이해하면 좋은 관계를 유지할 수 있습니다.";
    case "조심지연":
      return "서로 다른 점이 많아 갈등이 생길 수 있지만, 이해와 배려로 극복할 수 있습니다.";
  }
}

// 천간 궁합 점수 (최대 250점)
function calcCheonganScore(rel: RelationshipAnalysis): number {
  let score = 125; // 기본점
  score += rel.cheonganHap * 40;
  score -= rel.cheonganChung * 35;
  return Math.max(0, Math.min(250, score));
}

// 지지 궁합 점수 (최대 350점)
function calcJijiScore(rel: RelationshipAnalysis): number {
  let score = 150; // 기본점
  score += rel.jijiYukHap * 45;
  score += rel.jijiSamHap * 35;
  score += rel.jijiBangHap * 25;
  score -= rel.jijiChung * 40;
  score -= rel.jijiHyung * 30;
  score -= rel.jijiPa * 20;
  score -= rel.jijiHae * 15;
  return Math.max(0, Math.min(350, score));
}

// 오행 균형 점수 (최대 200점)
function calcOhengScore(a: SajuWonGuk, b: SajuWonGuk): number {
  const distA = analyzeOhengDistribution(a);
  const distB = analyzeOhengDistribution(b);

  let score = 100;

  // 상호보완성: A에게 부족한 오행을 B가 보충
  const ohengKeys = ["목", "화", "토", "금", "수"];
  for (const oh of ohengKeys) {
    const aVal = distA[oh];
    const bVal = distB[oh];
    if (aVal === 0 && bVal >= 2) score += 15;
    if (bVal === 0 && aVal >= 2) score += 15;
    if (aVal >= 1 && bVal >= 1) score += 5;
  }

  // 합산 분포 균형 보너스
  const combined: Record<string, number> = {};
  for (const oh of ohengKeys) {
    combined[oh] = distA[oh] + distB[oh];
  }
  const values = Object.values(combined);
  const max = Math.max(...values);
  const min = Math.min(...values);
  if (max - min <= 2) score += 20;

  return Math.max(0, Math.min(200, score));
}

// 음양 조화 점수 (최대 100점)
function calcYinyangScore(a: SajuWonGuk, b: SajuWonGuk): number {
  const aYY = getYinYang(a.day.cheongan);
  const bYY = getYinYang(b.day.cheongan);

  let score = 50;
  // 일간 음양이 다르면 조화 보너스
  if (aYY !== bYY) score += 30;

  // 연간 음양 조화
  if (getYinYang(a.year.cheongan) !== getYinYang(b.year.cheongan)) score += 10;
  if (getYinYang(a.month.cheongan) !== getYinYang(b.month.cheongan)) score += 10;

  return Math.max(0, Math.min(100, score));
}

// 일간 관계 점수 (최대 100점)
function calcIlganScore(a: SajuWonGuk, b: SajuWonGuk): number {
  const aOh = getOheng(a.day.cheongan);
  const bOh = getOheng(b.day.cheongan);

  let score = 50;
  if (aOh === bOh) score += 20; // 같은 오행 비화
  if (isOhengSangSaeng(aOh, bOh)) score += 35;
  if (isOhengSangGeuk(aOh, bOh)) score -= 25;

  return Math.max(0, Math.min(100, score));
}

export function calculateCompatibility(
  a: SajuWonGuk,
  b: SajuWonGuk
): CompatibilityResult {
  const relationships = analyzeRelationships(a, b);

  const cheonganScore = calcCheonganScore(relationships);
  const jijiScore = calcJijiScore(relationships);
  const ohengScore = calcOhengScore(a, b);
  const yinyangScore = calcYinyangScore(a, b);
  const ilganScore = calcIlganScore(a, b);

  const totalScore = Math.min(
    1000,
    cheonganScore + jijiScore + ohengScore + yinyangScore + ilganScore
  );

  const { grade, emoji } = getGrade(totalScore);

  return {
    totalScore,
    grade,
    gradeEmoji: emoji,
    categories: {
      cheonganScore,
      jijiScore,
      ohengScore,
      yinyangScore,
      ilganScore,
    },
    relationships,
    description: getGradeDescription(grade),
  };
}