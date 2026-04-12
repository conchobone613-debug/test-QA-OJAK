import { SajuWonGuk, SajuPillar, CHEONGAN, JIJI, Cheongan, Jiji } from "./sajuUtils";

export interface SajuInput {
  year: number;
  month: number;
  day: number;
  hour: number;
  isLunar?: boolean;
  gender?: "male" | "female";
}

export interface SajuResult {
  wonGuk: SajuWonGuk;
  raw: string;
  ilgan: Cheongan;
  ohengProfile: Record<string, number>;
}

// 연주 계산: (year - 4) % 60 → 천간/지지
function getYearPillar(year: number): SajuPillar {
  const idx = (year - 4) % 60;
  return {
    cheongan: CHEONGAN[idx % 10],
    jiji: JIJI[idx % 12],
  };
}

// 월주 계산: 연간에 따른 월주 천간 결정 + 월지 고정
function getMonthPillar(year: number, month: number): SajuPillar {
  const yearGanIdx = (year - 4) % 10;
  // 연간별 인월(1월) 천간 시작값
  const monthGanStartMap: Record<number, number> = {
    0: 2, // 갑 → 병인
    1: 4, // 을 → 무인
    2: 6, // 병 → 경인
    3: 8, // 정 → 임인
    4: 0, // 무 → 갑인
    5: 2, // 기 → 병인
    6: 4, // 경 → 무인
    7: 6, // 신 → 경인
    8: 8, // 임 → 임인
    9: 0, // 계 → 갑인
  };
  const startGan = monthGanStartMap[yearGanIdx];
  const monthOffset = month - 1; // 1월(인월)=0
  const ganIdx = (startGan + monthOffset) % 10;
  // 월지: 인(2)부터 시작
  const jijiIdx = (month + 1) % 12;

  return {
    cheongan: CHEONGAN[ganIdx],
    jiji: JIJI[jijiIdx],
  };
}

// 일주 계산: 기준일로부터 일진 계산
function getDayPillar(year: number, month: number, day: number): SajuPillar {
  // 기준: 1900년 1월 1일 = 경자일 (천간 6(경), 지지 0(자)) → 간지순서 36
  const baseDate = new Date(1900, 0, 1);
  const targetDate = new Date(year, month - 1, day);
  const diffDays = Math.floor((targetDate.getTime() - baseDate.getTime()) / (1000 * 60 * 60 * 24));
  const baseGanjiIdx = 36; // 경자
  const ganjiIdx = ((baseGanjiIdx + diffDays) % 60 + 60) % 60;

  return {
    cheongan: CHEONGAN[ganjiIdx % 10],
    jiji: JIJI[ganjiIdx % 12],
  };
}

// 시주 계산: 일간에 따른 시간 천간 + 시지
function getHourPillar(dayGanIdx: number, hour: number): SajuPillar {
  // 시지 결정 (24시간 → 12지지)
  const jijiMap: [number, number, Jiji][] = [
    [23, 1, "자"], [1, 3, "축"], [3, 5, "인"], [5, 7, "묘"],
    [7, 9, "진"], [9, 11, "사"], [11, 13, "오"], [13, 15, "미"],
    [15, 17, "신"], [17, 19, "유"], [19, 21, "술"], [21, 23, "해"],
  ];

  let hourJiji: Jiji = "자";
  let hourJijiIdx = 0;
  if (hour === 23 || hour < 1) {
    hourJiji = "자";
    hourJijiIdx = 0;
  } else {
    for (let i = 1; i < jijiMap.length; i++) {
      if (hour >= jijiMap[i][0] && hour < jijiMap[i][1]) {
        hourJiji = jijiMap[i][2];
        hourJijiIdx = i;
        break;
      }
    }
  }

  // 일간별 자시(子時) 천간 시작값
  const hourGanStartMap: Record<number, number> = {
    0: 0, // 갑·기 → 갑자
    1: 2, // 을·경 → 병자
    2: 4, // 병·신 → 무자
    3: 6, // 정·임 → 경자
    4: 8, // 무·계 → 임자
  };
  const startGan = hourGanStartMap[dayGanIdx % 5];
  const ganIdx = (startGan + hourJijiIdx) % 10;

  return {
    cheongan: CHEONGAN[ganIdx],
    jiji: hourJiji,
  };
}

export function calculateSaju(input: SajuInput): SajuResult {
  const { year, month, day, hour } = input;

  const yearPillar = getYearPillar(year);
  const monthPillar = getMonthPillar(year, month);
  const dayPillar = getDayPillar(year, month, day);

  const dayGanIdx = CHEONGAN.indexOf(dayPillar.cheongan);
  const hourPillar = getHourPillar(dayGanIdx, hour);

  const wonGuk: SajuWonGuk = {
    year: yearPillar,
    month: monthPillar,
    day: dayPillar,
    hour: hourPillar,
  };

  const raw =
    yearPillar.cheongan + yearPillar.jiji +
    monthPillar.cheongan + monthPillar.jiji +
    dayPillar.cheongan + dayPillar.jiji +
    hourPillar.cheongan + hourPillar.jiji;

  const { analyzeOhengDistribution } = require("./sajuUtils");
  const ohengProfile = analyzeOhengDistribution(wonGuk);

  return {
    wonGuk,
    raw,
    ilgan: dayPillar.cheongan,
    ohengProfile,
  };
}