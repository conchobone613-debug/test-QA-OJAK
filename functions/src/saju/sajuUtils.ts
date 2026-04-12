export const CHEONGAN = ["갑", "을", "병", "정", "무", "기", "경", "신", "임", "계"] as const;
export const JIJI = ["자", "축", "인", "묘", "진", "사", "오", "미", "신", "유", "술", "해"] as const;

export type Cheongan = typeof CHEONGAN[number];
export type Jiji = typeof JIJI[number];

export interface SajuPillar {
  cheongan: Cheongan;
  jiji: Jiji;
}

export interface SajuWonGuk {
  year: SajuPillar;
  month: SajuPillar;
  day: SajuPillar;
  hour: SajuPillar;
}

export const OHENG_MAP: Record<string, string> = {
  "갑": "목", "을": "목",
  "병": "화", "정": "화",
  "무": "토", "기": "토",
  "경": "금", "신": "금",
  "임": "수", "계": "수",
  "자": "수", "축": "토",
  "인": "목", "묘": "목",
  "진": "토", "사": "화",
  "오": "화", "미": "토",
  "신": "금", "유": "금",
  "술": "토", "해": "수",
};

export function getOheng(char: string): string {
  return OHENG_MAP[char] || "";
}

// 천간합 (갑기, 을경, 병신, 정임, 무계)
const CHEONGAN_HAP_PAIRS: [Cheongan, Cheongan][] = [
  ["갑", "기"], ["을", "경"], ["병", "신"], ["정", "임"], ["무", "계"],
];

export function isCheonganHap(a: Cheongan, b: Cheongan): boolean {
  return CHEONGAN_HAP_PAIRS.some(
    ([x, y]) => (a === x && b === y) || (a === y && b === x)
  );
}

// 천간충 (갑경, 을신, 병임, 정계)
const CHEONGAN_CHUNG_PAIRS: [Cheongan, Cheongan][] = [
  ["갑", "경"], ["을", "신"], ["병", "임"], ["정", "계"],
];

export function isCheonganChung(a: Cheongan, b: Cheongan): boolean {
  return CHEONGAN_CHUNG_PAIRS.some(
    ([x, y]) => (a === x && b === y) || (a === y && b === x)
  );
}

// 지지육합
const JIJI_YUKHAP_PAIRS: [Jiji, Jiji][] = [
  ["자", "축"], ["인", "해"], ["묘", "술"], ["진", "유"], ["사", "신"], ["오", "미"],
];

export function isJijiYukHap(a: Jiji, b: Jiji): boolean {
  return JIJI_YUKHAP_PAIRS.some(
    ([x, y]) => (a === x && b === y) || (a === y && b === x)
  );
}

// 지지삼합
const JIJI_SAMHAP_GROUPS: Jiji[][] = [
  ["신", "자", "진"], // 수국
  ["해", "묘", "미"], // 목국
  ["인", "오", "술"], // 화국
  ["사", "유", "축"], // 금국
];

export function isJijiSamHap(a: Jiji, b: Jiji): boolean {
  return JIJI_SAMHAP_GROUPS.some(
    (group) => group.includes(a) && group.includes(b) && a !== b
  );
}

export function getJijiSamHapElement(a: Jiji, b: Jiji): string | null {
  const elements = ["수", "목", "화", "금"];
  for (let i = 0; i < JIJI_SAMHAP_GROUPS.length; i++) {
    if (JIJI_SAMHAP_GROUPS[i].includes(a) && JIJI_SAMHAP_GROUPS[i].includes(b) && a !== b) {
      return elements[i];
    }
  }
  return null;
}

// 지지방합
const JIJI_BANGHAP_GROUPS: Jiji[][] = [
  ["인", "묘", "진"], // 동방목
  ["사", "오", "미"], // 남방화
  ["신", "유", "술"], // 서방금
  ["해", "자", "축"], // 북방수
];

export function isJijiBangHap(a: Jiji, b: Jiji): boolean {
  return JIJI_BANGHAP_GROUPS.some(
    (group) => group.includes(a) && group.includes(b) && a !== b
  );
}

// 지지충 (자오, 축미, 인신, 묘유, 진술, 사해)
const JIJI_CHUNG_PAIRS: [Jiji, Jiji][] = [
  ["자", "오"], ["축", "미"], ["인", "신"], ["묘", "유"], ["진", "술"], ["사", "해"],
];

export function isJijiChung(a: Jiji, b: Jiji): boolean {
  return JIJI_CHUNG_PAIRS.some(
    ([x, y]) => (a === x && b === y) || (a === y && b === x)
  );
}

// 지지형
const JIJI_HYUNG_PAIRS: [Jiji, Jiji][] = [
  ["인", "사"], ["사", "신"], ["인", "신"], // 삼형
  ["축", "술"], ["술", "미"], ["축", "미"], // 삼형
  ["자", "묘"],                             // 무례지형
  ["진", "진"], ["오", "오"], ["유", "유"], ["해", "해"], // 자형
];

export function isJijiHyung(a: Jiji, b: Jiji): boolean {
  return JIJI_HYUNG_PAIRS.some(
    ([x, y]) => (a === x && b === y) || (a === y && b === x)
  );
}

// 지지파
const JIJI_PA_PAIRS: [Jiji, Jiji][] = [
  ["자", "유"], ["축", "진"], ["인", "해"], ["묘", "오"], ["사", "신"], ["술", "미"],
];

export function isJijiPa(a: Jiji, b: Jiji): boolean {
  return JIJI_PA_PAIRS.some(
    ([x, y]) => (a === x && b === y) || (a === y && b === x)
  );
}

// 지지해
const JIJI_HAE_PAIRS: [Jiji, Jiji][] = [
  ["자", "미"], ["축", "오"], ["인", "사"], ["묘", "진"], ["신", "해"], ["유", "술"],
];

export function isJijiHae(a: Jiji, b: Jiji): boolean {
  return JIJI_HAE_PAIRS.some(
    ([x, y]) => (a === x && b === y) || (a === y && b === x)
  );
}

// 오행 상생 관계
const OHENG_SANGSAENG: Record<string, string> = {
  "목": "화", "화": "토", "토": "금", "금": "수", "수": "목",
};

export function isOhengSangSaeng(a: string, b: string): boolean {
  return OHENG_SANGSAENG[a] === b || OHENG_SANGSAENG[b] === a;
}

// 오행 상극 관계
const OHENG_SANGGEUK: Record<string, string> = {
  "목": "토", "토": "수", "수": "화", "화": "금", "금": "목",
};

export function isOhengSangGeuk(a: string, b: string): boolean {
  return OHENG_SANGGEUK[a] === b || OHENG_SANGGEUK[b] === a;
}

// 오행 분석 (사주원국의 오행 분포)
export function analyzeOhengDistribution(won: SajuWonGuk): Record<string, number> {
  const dist: Record<string, number> = { "목": 0, "화": 0, "토": 0, "금": 0, "수": 0 };
  const allChars = [
    won.year.cheongan, won.year.jiji,
    won.month.cheongan, won.month.jiji,
    won.day.cheongan, won.day.jiji,
    won.hour.cheongan, won.hour.jiji,
  ];
  for (const c of allChars) {
    const oh = getOheng(c);
    if (oh) dist[oh]++;
  }
  return dist;
}

// 음양 판정
export function isYang(cheongan: Cheongan): boolean {
  return ["갑", "병", "무", "경", "임"].includes(cheongan);
}

export function getYinYang(cheongan: Cheongan): "양" | "음" {
  return isYang(cheongan) ? "양" : "음";
}

export interface RelationshipAnalysis {
  cheonganHap: number;
  cheonganChung: number;
  jijiYukHap: number;
  jijiSamHap: number;
  jijiBangHap: number;
  jijiChung: number;
  jijiHyung: number;
  jijiPa: number;
  jijiHae: number;
}

export function analyzeRelationships(a: SajuWonGuk, b: SajuWonGuk): RelationshipAnalysis {
  const result: RelationshipAnalysis = {
    cheonganHap: 0, cheonganChung: 0,
    jijiYukHap: 0, jijiSamHap: 0, jijiBangHap: 0,
    jijiChung: 0, jijiHyung: 0, jijiPa: 0, jijiHae: 0,
  };

  const pillarsA = [a.year, a.month, a.day, a.hour];
  const pillarsB = [b.year, b.month, b.day, b.hour];

  for (const pa of pillarsA) {
    for (const pb of pillarsB) {
      if (isCheonganHap(pa.cheongan, pb.cheongan)) result.cheonganHap++;
      if (isCheonganChung(pa.cheongan, pb.cheongan)) result.cheonganChung++;
      if (isJijiYukHap(pa.jiji, pb.jiji)) result.jijiYukHap++;
      if (isJijiSamHap(pa.jiji, pb.jiji)) result.jijiSamHap++;
      if (isJijiBangHap(pa.jiji, pb.jiji)) result.jijiBangHap++;
      if (isJijiChung(pa.jiji, pb.jiji)) result.jijiChung++;
      if (isJijiHyung(pa.jiji, pb.jiji)) result.jijiHyung++;
      if (isJijiPa(pa.jiji, pb.jiji)) result.jijiPa++;
      if (isJijiHae(pa.jiji, pb.jiji)) result.jijiHae++;
    }
  }

  return result;
}