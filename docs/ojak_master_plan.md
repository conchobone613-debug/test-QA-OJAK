# OJAK (오작) — 사주 기반 데이팅 앱 종합 기획서

> **"하늘이 정한 인연, 기술로 찾다"**
> 사주팔자 궁합을 핵심 매칭 알고리즘으로, AI가 해석하는 차세대 데이팅 플랫폼

---

## 1. 프로젝트 개요

### 1.1 앱 이름: **OJAK (오작)**
- 오작교(烏鵲橋) — 견우와 직녀를 잇는 까마귀·까치 다리
- "오행(五行)으로 작정(作定)하다"의 중의적 의미
- 영문 표기 자연스러움, 글로벌 확장 가능

### 1.2 핵심 가치 제안 (Value Proposition)
| 기존 데이팅앱 문제 | OJAK 해결책 |
|---|---|
| 외모 중심 스와이프 → 피상적 매칭 | 사주 궁합 점수로 내면 호환성 우선 |
| "왜 이 사람을 추천했는지" 설명 없음 | AI가 궁합 근거를 자연어로 해석 |
| 스와이프 피로도 → 이탈 | 하루 추천 5명 제한 + 궁합 스토리 제공 |
| 대화 시작의 어색함 | AI가 두 사람의 궁합 기반 대화 주제 추천 |
| 가짜 프로필, 신뢰 부족 | 본인인증 + 사주 입력 의무 → 진정성 필터 |

### 1.3 타겟 사용자
- **1차 타겟**: 25~39세 한국 미혼 남녀, 사주/운세에 흥미 있으나 전문 상담까지는 부담
- **2차 타겟**: 결혼 적령기 30대, 부모님 권유로 궁합을 보는 세대
- **3차 타겟**: K-문화 관심 해외 사용자 (영문 버전)

### 1.4 프로젝트 목적
- 업데이트된 Flutter 멀티에이전트 오케스트레이터 + QA 파이프라인 워크플로우를 실제 프로젝트로 검증
- 기획 → HANDOFF.md → 오케스트레이터 자동 빌드 → QA 검증의 E2E 프로세스 밸리데이션

---

## 2. 핵심 기능 설계

### 2.1 사주 궁합 엔진 (핵심 차별점)

#### 2.1.1 사주 원국 계산
- **입력**: 생년월일 + 태어난 시간 (시주 포함 8자 완성)
  - 시간 모름 → 시주 제외 6자 모드 (정확도 75% 표시)
- **계산 엔진**: Firebase Functions + `@gracefullight/saju` 또는 `ssaju` npm 패키지
  - 양력/음력 자동 변환
  - 절기 기반 월주 계산 (만세력)
  - 대운(10년 주기) 계산

#### 2.1.2 궁합 점수 알고리즘 (1000점 만점)

```
총점 = 일주 궁합(400) + 오행 조화(250) + 간지 상호작용(200) + 대운 시너지(100) + 특수 살(50)
```

| 카테고리 | 배점 | 세부 항목 |
|---|---|---|
| **일주 궁합** | 400점 | 일간 합(100), 일간 상생(80), 일지 육합(100), 일지 삼합(70), 일지 충(-50~0) |
| **오행 조화** | 250점 | 오행 보완도(100), 용신 보완(80), 오행 균형 시너지(70) |
| **간지 상호작용** | 200점 | 천간 5합(60), 지지 육합(50), 지지 삼합(40), 형충파해 감점(-50~0), 방합(50) |
| **대운 시너지** | 100점 | 현재 대운 조화(50), 향후 10년 흐름(50) |
| **특수 살** | 50점 | 도화살·역마살 등 특수 관계살(±25×2) |

#### 2.1.3 궁합 등급 시스템

| 등급 | 점수 범위 | 뱃지 | 설명 |
|---|---|---|---|
| 🌟 천생연분 | 850~1000 | 금색 빛 바운스 | 하늘이 점지한 인연 |
| 💎 최상궁합 | 700~849 | 보라 그라데이션 | 서로를 완성하는 관계 |
| 💚 좋은인연 | 550~699 | 초록 체크 | 노력하면 빛나는 관계 |
| 🔶 보통궁합 | 400~549 | 주황 물결 | 이해와 배려가 필요한 관계 |
| ⚡ 조심지연 | 0~399 | 회색 물음표 | 도전적이지만 성장의 기회 |

#### 2.1.4 AI 궁합 해석 (Gemini Flash 연동)
- 점수만이 아닌 **자연어 해석 리포트** 제공
- 예시:
  > "두 분의 일간이 갑기합(甲己合)을 이루고 있어요. 이것은 '中正之合'이라 불리며, 서로 다른 성향이 오히려 균형을 만들어내는 관계입니다. 갑목(甲木)의 올곧은 추진력과 기토(己土)의 부드러운 포용력이 만나 서로의 부족함을 채워줄 수 있어요."
- 카테고리별 해석: 연애 궁합 / 결혼 궁합 / 재물 궁합 / 대화 스타일

---

### 2.2 사용자 프로필

#### 2.2.1 기본 정보
- 닉네임 (실명 비공개)
- 프로필 사진 (최소 1장, 최대 6장)
- 생년월일시 (사주 계산용, **필수**)
- 성별, 키, 직업군
- 거주 지역 (시/도 단위)

#### 2.2.2 자기소개
- 자유 텍스트 (300자 제한)
- 관심사 태그 (최대 8개, 사전 정의 카테고리에서 선택)
- "나를 표현하는 한 문장" (50자 제한)

#### 2.2.3 사주 프로필 (자동 생성)
- 오행 차트 (레이더 차트 시각화)
- "나의 사주 성격" AI 요약 (3줄)
- 대표 오행 아이콘 (木🌳 火🔥 土🏔️ 金⚡ 水💧)
- 용신(用神) 표시 — "나에게 필요한 기운"

#### 2.2.4 이상형 설정
- 나이 범위
- 거리 범위
- 키 범위
- 궁합 최소 등급 필터 (기본: "보통궁합" 이상)

---

### 2.3 매칭 시스템

#### 2.3.1 추천 피드 — "오늘의 인연"
- **일일 5명 추천** (무료 사용자)
- 궁합 점수 상위 순으로 정렬
- 각 카드에 궁합 등급 뱃지 + 한 줄 궁합 코멘트
- 스와이프 UI (좋아요/패스/슈퍼좋아요)

#### 2.3.2 매칭 로직
```
추천 후보 필터링:
1. 이상형 조건 (나이, 거리, 키) → 1차 필터
2. 이미 스와이프한 사용자 제외 → 2차 필터
3. 사주 궁합 점수 계산 → 정렬
4. 상위 N명 추출 → 추천 카드
```

#### 2.3.3 상호 좋아요 → 매칭 성립
- User A가 User B에게 좋아요 → 대기
- User B도 User A에게 좋아요 → **매칭 성립!**
- 매칭 모먼트 연출: 오작교 애니메이션 + 궁합 점수 공개
- 양쪽에 FCM 푸시알림

#### 2.3.4 슈퍼좋아요 (프리미엄)
- 상대방에게 즉시 알림 + "궁합 미리보기" 전달
- 일일 1회 무료, 추가는 인앱 구매

---

### 2.4 채팅 시스템

#### 2.4.1 기본 채팅
- 매칭 성립 후 채팅방 자동 생성
- 텍스트 + 이미지 전송
- 읽음 확인
- 신고/차단 기능

#### 2.4.2 AI 대화 추천 — "궁합 토크"
- 매칭 시 AI가 두 사람의 궁합 기반 아이스브레이커 3개 생성
  > 예: "두 분 다 수(水) 기운이 강하시네요! 물놀이나 여행 좋아하세요?"
- 채팅방 상단에 "오늘의 궁합 토픽" 표시

#### 2.4.3 사진 교환 요청
- 처음에는 블러 처리된 프로필 사진 (선택적)
- 대화 N회 이후 "사진 공개 요청" 가능
- 상대 수락 시 고화질 공개

---

### 2.5 사주 콘텐츠 섹션 — "오늘의 운세"

#### 2.5.1 데일리 운세
- 매일 아침 푸시알림으로 오늘의 운세
- 연애운 / 재물운 / 건강운 / 행운의 시간
- Gemini AI가 사주 원국 + 당일 일진(日辰) 기반 생성

#### 2.5.2 월간/연간 운세
- 프리미엄 사용자 전용
- 대운 + 세운 + 월운 종합 분석

#### 2.5.3 궁합 리포트 (상세)
- 매칭된 상대와의 상세 궁합 리포트
- 연애 / 결혼 / 재물 / 자녀 / 건강 5개 카테고리
- PDF 다운로드 가능 (프리미엄)

---

### 2.6 커뮤니티 — "오행톡"
- 같은 일간(日干) 기반 소그룹 채팅
  - 예: "갑목(甲木) 모여라", "정화(丁火) 수다방"
- 연애 상담 게시판
- "이런 궁합 어떤가요?" Q&A
- AI 역술사 챗봇 ("오작 선생")

---

## 3. 기술 아키텍처

### 3.1 시스템 구성도

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter App (Client)                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ Auth     │ │ Profile  │ │ Matching │ │ Chat             │ │
│  │ Screen   │ │ Screen   │ │ Feed     │ │ Screen           │ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────────────┘ │
│       │             │            │             │               │
│  ┌────┴─────────────┴────────────┴─────────────┴─────────┐    │
│  │              Riverpod State Management                 │    │
│  └────────────────────────┬───────────────────────────────┘    │
└───────────────────────────┼───────────────────────────────────┘
                            │
                   ┌────────┴────────┐
                   │   Firebase SDK   │
                   └────────┬────────┘
                            │
┌───────────────────────────┼───────────────────────────────────┐
│                    Firebase Backend                            │
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Auth        │  │ Firestore    │  │ Cloud Functions      │ │
│  │ (Kakao,     │  │ (Users,      │  │                      │ │
│  │  Apple,     │  │  Matches,    │  │ ┌──────────────────┐ │ │
│  │  Google)    │  │  Chats,      │  │ │ Saju Calculator  │ │ │
│  └─────────────┘  │  Swipes)     │  │ │ (@gracefullight/ │ │ │
│                    └──────────────┘  │ │  saju or ssaju)  │ │ │
│  ┌─────────────┐  ┌──────────────┐  │ └──────────────────┘ │ │
│  │ Storage     │  │ FCM          │  │ ┌──────────────────┐ │ │
│  │ (Profile    │  │ (Push        │  │ │ Gemini Flash API │ │ │
│  │  Images)    │  │  Notif.)     │  │ │ (AI 해석/운세)    │ │ │
│  └─────────────┘  └──────────────┘  │ └──────────────────┘ │ │
│                                      │ ┌──────────────────┐ │ │
│                                      │ │ Matching Engine  │ │ │
│                                      │ │ (궁합 계산+필터) │ │ │
│                                      │ └──────────────────┘ │ │
│                                      └──────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

### 3.2 기술 스택

| 레이어 | 기술 | 이유 |
|---|---|---|
| **Frontend** | Flutter 3.x (Dart) | 크로스플랫폼, 단일 코드베이스 |
| **상태관리** | Riverpod + freezed | 타입 안전, 코드 생성 |
| **라우팅** | go_router | 선언적 라우팅, 딥링크 |
| **Backend** | Firebase | 인증, DB, 스토리지, 함수 올인원 |
| **DB** | Firestore | 실시간 동기화, 스케일링 |
| **사주 엔진** | `@gracefullight/saju` (npm) | 한국 사주 특화, TypeScript |
| **AI 해석** | Gemini 2.5 Flash | 빠르고 저렴한 자연어 생성 |
| **푸시** | FCM | Firebase 네이티브 연동 |
| **결제** | RevenueCat | iOS/Android 구독 통합 |
| **이미지** | cached_network_image + shimmer | 부드러운 이미지 로딩 |
| **스와이프 UI** | appinio_swiper | Tinder 스타일 카드 스와이프 |

### 3.3 Firestore 데이터 모델

```
users/
  {uid}/
    - displayName: string
    - birthDateTime: timestamp     // 생년월일시
    - gender: string
    - height: number
    - occupation: string
    - region: string
    - bio: string
    - interests: string[]
    - photos: string[]             // Storage URL
    - sajuPillar: {                // 사주 원국 (계산 결과 캐시)
        yearStem: string,  yearBranch: string,
        monthStem: string, monthBranch: string,
        dayStem: string,   dayBranch: string,
        hourStem: string,  hourBranch: string,
        fiveElements: { wood: num, fire: num, earth: num, metal: num, water: num },
        yongShin: string,           // 용신
        dayMaster: string           // 일간
      }
    - preferences: {
        ageRange: { min: num, max: num },
        distanceKm: number,
        heightRange: { min: num, max: num },
        minCompatGrade: string
      }
    - createdAt: timestamp
    - lastActive: timestamp
    - isPremium: boolean
    - dailySwipesRemaining: number
    - superLikesRemaining: number

swipes/
  {swiperUid}_{targetUid}/
    - swiperId: string
    - targetId: string
    - action: "like" | "pass" | "superlike"
    - compatibilityScore: number
    - createdAt: timestamp

matches/
  {matchId}/
    - participants: string[]       // [uid1, uid2]
    - compatibilityScore: number
    - compatibilityGrade: string
    - aiSummary: string            // AI 궁합 한 줄 코멘트
    - createdAt: timestamp
    - lastMessageAt: timestamp

chats/
  {matchId}/
    messages/
      {messageId}/
        - senderId: string
        - text: string
        - imageUrl: string?
        - readAt: timestamp?
        - createdAt: timestamp

dailyFortunes/
  {uid}_{date}/
    - fortune: {
        love: string,
        money: string,
        health: string,
        luckyTime: string,
        overallScore: number
      }
    - generatedAt: timestamp
```

---

## 4. 디자인 시스템

### 4.1 컬러 팔레트

| 용도 | 색상 | HEX | 의미 |
|---|---|---|---|
| **Primary** | Celestial Indigo | `#1B1464` | 밤하늘, 운명 |
| **Primary Light** | Twilight Purple | `#4A3A8F` | 은하수 |
| **Secondary** | Fortune Gold | `#D4AF37` | 금빛 인연 |
| **Accent** | Blossom Pink | `#FF6B8A` | 연애, 설렘 |
| **Background Dark** | Deep Sky | `#0A0E27` | 우주 배경 |
| **Background Card** | Night Glass | `#16213E` (opacity 0.85) | 글래스모피즘 |
| **Surface** | Starlight | `#1A1F3A` | 카드/시트 |
| **Text Primary** | Moon White | `#F0E6FF` | 가독성 |
| **Text Secondary** | Mist Gray | `#8B93B1` | 보조 텍스트 |
| **Success** | Jade Green | `#2DD4A8` | 매칭 성공 |
| **Warning** | Amber | `#FFB84D` | 주의 |
| **Error** | Ruby Red | `#FF4D6A` | 에러/경고 |

#### 오행(五行) 컬러

| 오행 | 색상 | HEX | 아이콘 |
|---|---|---|---|
| 木 (목) | Forest Green | `#2ECC71` | 🌳 |
| 火 (화) | Flame Red | `#E74C3C` | 🔥 |
| 土 (토) | Earth Brown | `#D4A574` | 🏔️ |
| 金 (금) | Silver Gold | `#F1C40F` | ⚡ |
| 水 (수) | Ocean Blue | `#3498DB` | 💧 |

#### 궁합 등급 컬러

| 등급 | 색상 | HEX |
|---|---|---|
| 천생연분 | Radiant Gold | `#FFD700` → `#FFA500` gradient |
| 최상궁합 | Royal Purple | `#9B59B6` → `#6C3483` gradient |
| 좋은인연 | Emerald | `#2ECC71` → `#27AE60` gradient |
| 보통궁합 | Warm Orange | `#F39C12` → `#E67E22` gradient |
| 조심지연 | Cool Gray | `#95A5A6` → `#7F8C8D` gradient |

### 4.2 타이포그래피

| 용도 | 폰트 | 사이즈 | 가중치 |
|---|---|---|---|
| 앱 타이틀 | Pretendard | 28sp | Bold (700) |
| 섹션 타이틀 | Pretendard | 22sp | SemiBold (600) |
| 카드 타이틀 | Pretendard | 18sp | SemiBold (600) |
| 본문 | Pretendard | 15sp | Regular (400) |
| 캡션 | Pretendard | 13sp | Regular (400) |
| 궁합 점수 | Outfit (영문 숫자) | 48sp | Bold (700) |
| 사주 한자 | Noto Serif KR | 20sp | Medium (500) |

### 4.3 디자인 원칙

1. **글래스모피즘**: 카드, 바텀시트, 모달에 `BackdropFilter` + 반투명 배경
2. **별빛 파티클**: 배경에 미세한 별 반짝임 애니메이션
3. **그라데이션 활용**: 궁합 등급별 그라데이션 뱃지, 버튼
4. **동양 모티프**: 오행 아이콘, 팔괘 패턴 (미니멀하게)
5. **마이크로 애니메이션**: 좋아요 → 하트 파티클, 매칭 → 오작교 브릿지 애니메이션
6. **다크 모드 기본**: 밤하늘/우주 테마로 다크 모드가 기본

---

## 5. 화면 구성 (Screen Map)

### 5.1 인증 플로우

```
SplashScreen
  ↓
OnboardingScreen (최초 1회)
  - 슬라이드 3장: 사주 매칭 소개
  ↓
LoginScreen
  - 카카오 / Apple / Google 로그인
  ↓
ProfileSetupScreen (최초 1회)
  - Step 1: 기본정보 (닉네임, 성별, 키, 직업)
  - Step 2: 생년월일시 입력 (사주 계산의 핵심!)
  - Step 3: 프로필 사진 (최소 1장)
  - Step 4: 자기소개 + 관심사
  - Step 5: 이상형 설정
  ↓
SajuLoadingScreen
  - 사주 계산 중 연출 (별자리 + 오행 회전 애니메이션)
  - "당신의 사주를 분석하고 있어요..."
  ↓
SajuResultScreen
  - 내 사주 요약 카드 (오행 차트 + AI 성격 분석)
  - "매칭을 시작하시겠어요?" CTA
```

### 5.2 메인 탭 구조 (BottomNavigationBar)

```
Tab 1: 홈 (추천 피드)        — MatchFeedScreen
Tab 2: 궁합 (사주 콘텐츠)    — FortuneScreen
Tab 3: 채팅                  — ChatListScreen
Tab 4: 커뮤니티              — CommunityScreen
Tab 5: 마이페이지            — MyPageScreen
```

### 5.3 상세 화면 목록

#### 홈 탭
| 화면 | 설명 |
|---|---|
| `MatchFeedScreen` | 스와이프 카드 피드 (궁합 점수 표시) |
| `UserDetailScreen` | 상대 프로필 상세 (사주 차트 포함) |
| `MatchSuccessScreen` | 매칭 성립 축하 (오작교 애니메이션) |
| `CompatibilityDetailScreen` | 상세 궁합 리포트 화면 |

#### 궁합 탭
| 화면 | 설명 |
|---|---|
| `FortuneScreen` | 오늘의 운세 + 연애운 |
| `MySajuScreen` | 내 사주 원국 상세 (오행 차트) |
| `CompatibilityCheckScreen` | 직접 궁합 보기 (생년월일 입력) |
| `FortuneReportScreen` | 월간/연간 운세 리포트 (프리미엄) |

#### 채팅 탭
| 화면 | 설명 |
|---|---|
| `ChatListScreen` | 매칭된 채팅 목록 |
| `ChatRoomScreen` | 1:1 채팅방 |
| `ChatProfileScreen` | 채팅 상대 프로필 (궁합 포함) |

#### 커뮤니티 탭
| 화면 | 설명 |
|---|---|
| `CommunityScreen` | 게시글 피드 |
| `PostDetailScreen` | 게시글 상세 + 댓글 |
| `CreatePostScreen` | 글 작성 |
| `OhangGroupScreen` | 오행 기반 소그룹 채팅 |

#### 마이페이지 탭
| 화면 | 설명 |
|---|---|
| `MyPageScreen` | 프로필 요약 + 옵션 |
| `EditProfileScreen` | 프로필 편집 |
| `SettingsScreen` | 앱 설정 |
| `SubscriptionScreen` | 구독 관리 (RevenueCat) |
| `BlockedUsersScreen` | 차단 사용자 목록 |
| `NotificationSettingsScreen` | 알림 설정 |

---

## 6. 수익 모델

### 6.1 구독 티어

| 티어 | 월 가격 | 기능 |
|---|---|---|
| **무료** | ₩0 | 일 5명 추천, 기본 궁합 점수, 일일 운세, 일 1회 슈퍼좋아요 |
| **OJAK Plus** | ₩9,900 | 일 15명 추천, 상세 궁합 리포트, 월간 운세, 일 3회 슈퍼좋아요, 누가 나를 좋아했는지 확인 |
| **OJAK Premium** | ₩19,900 | 무제한 추천, 모든 궁합 리포트 + PDF, 연간 운세, 무제한 슈퍼좋아요, 프로필 부스트, 읽음 확인 |

### 6.2 인앱 구매 (1회성)
| 아이템 | 가격 | 설명 |
|---|---|---|
| 슈퍼좋아요 5개 | ₩4,900 | 일회성 충전 |
| 상세 궁합 리포트 1건 | ₩3,900 | 특정 상대와의 상세 분석 |
| 프로필 부스트 (24시간) | ₩2,900 | 추천 우선 노출 |

### 6.3 결제 시스템
- **RevenueCat** 통합 (iOS App Store + Google Play)
- 7일 무료 체험 (Plus/Premium)
- 연간 구독 20% 할인

---

## 7. 안전 및 신뢰 시스템

### 7.1 본인 인증
- 휴대폰 번호 인증 (SMS)
- 프로필 사진 AI 검증 (실제 인물 여부)

### 7.2 신고/차단
- 부적절한 메시지 신고
- 사용자 차단 (양방향 차단)
- 신고 3회 누적 → 자동 제재

### 7.3 개인정보 보호
- 생년월일시는 사주 계산에만 사용, 직접 노출 안 함
- 실명 비공개, 닉네임 시스템
- 위치 정보는 시/도 단위만 공개
- 사진 스크린샷 방지 (선택적)

---

## 8. MVP → 풀 버전 로드맵

### Phase 1: MVP (오케스트레이터 자동 빌드 대상)
- [x] Flutter 프로젝트 초기화 + 디자인 시스템
- [ ] Firebase 인증 (카카오/Apple/Google)
- [ ] 프로필 생성 + 사주 계산
- [ ] 매칭 피드 (스와이프 카드)
- [ ] 궁합 점수 계산 (Firebase Functions)
- [ ] 매칭 로직 + 성립 화면
- [ ] 기본 채팅
- [ ] 오늘의 운세

### Phase 2: 고도화
- [ ] AI 궁합 해석 (Gemini 연동)
- [ ] 프리미엄 구독 (RevenueCat)
- [ ] 상세 궁합 리포트
- [ ] 푸시 알림

### Phase 3: 커뮤니티
- [ ] 오행톡 소그룹
- [ ] 게시판/Q&A
- [ ] AI 역술사 챗봇

### Phase 4: 성장
- [ ] 영문 국제화 (i18n)
- [ ] 프로필 사진 AI 검증
- [ ] 대운 기반 장기 궁합 분석
- [ ] 데이트 코스 추천 (궁합 + 위치 기반)

---

## 9. Firebase Functions 구조

```
functions/
├── src/
│   ├── saju/
│   │   ├── calculateSaju.ts          // 사주 원국 계산
│   │   ├── calculateCompatibility.ts  // 궁합 점수 계산
│   │   └── sajuUtils.ts              // 오행/천간/지지 유틸
│   ├── matching/
│   │   ├── generateRecommendations.ts // 추천 피드 생성
│   │   ├── processSwipe.ts           // 스와이프 처리 + 매칭 체크
│   │   └── matchingUtils.ts          // 필터링 유틸
│   ├── ai/
│   │   ├── generateInterpretation.ts  // Gemini 궁합 해석
│   │   ├── generateFortune.ts        // 일일/월간 운세 생성
│   │   └── generateIcebreaker.ts     // 대화 주제 추천
│   ├── notification/
│   │   └── sendNotification.ts       // FCM 푸시
│   └── index.ts                      // 함수 엔트리포인트
├── package.json
└── tsconfig.json
```

---

## 10. Flutter 프로젝트 구조

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_colors.dart           // 컬러 팔레트
│   │   ├── app_text_styles.dart      // 타이포그래피
│   │   ├── app_theme.dart            // ThemeData
│   │   └── app_gradients.dart        // 궁합 등급 그라데이션
│   ├── constants/
│   │   ├── saju_constants.dart       // 천간/지지/오행 상수
│   │   └── app_constants.dart        // 앱 설정 상수
│   ├── router/
│   │   └── app_router.dart           // go_router 설정
│   └── utils/
│       ├── validators.dart           // 입력값 검증
│       └── date_utils.dart           // 날짜/음양력 변환
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   └── login_screen.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── services/
│   │       └── auth_service.dart
│   ├── profile/
│   │   ├── screens/
│   │   │   ├── profile_setup_screen.dart
│   │   │   ├── saju_loading_screen.dart
│   │   │   ├── saju_result_screen.dart
│   │   │   ├── edit_profile_screen.dart
│   │   │   └── my_page_screen.dart
│   │   ├── providers/
│   │   │   └── profile_provider.dart
│   │   ├── models/
│   │   │   ├── user_profile.dart
│   │   │   └── saju_profile.dart
│   │   └── widgets/
│   │       ├── five_elements_chart.dart    // 오행 레이더 차트
│   │       └── saju_card.dart
│   ├── matching/
│   │   ├── screens/
│   │   │   ├── match_feed_screen.dart
│   │   │   ├── user_detail_screen.dart
│   │   │   ├── match_success_screen.dart
│   │   │   └── compatibility_detail_screen.dart
│   │   ├── providers/
│   │   │   └── matching_provider.dart
│   │   ├── models/
│   │   │   ├── match.dart
│   │   │   └── compatibility_result.dart
│   │   └── widgets/
│   │       ├── swipe_card.dart
│   │       ├── compatibility_badge.dart
│   │       └── match_animation.dart        // 오작교 애니메이션
│   ├── chat/
│   │   ├── screens/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_room_screen.dart
│   │   ├── providers/
│   │   │   └── chat_provider.dart
│   │   ├── models/
│   │   │   └── message.dart
│   │   └── widgets/
│   │       ├── chat_bubble.dart
│   │       └── icebreaker_card.dart
│   ├── fortune/
│   │   ├── screens/
│   │   │   ├── fortune_screen.dart
│   │   │   ├── my_saju_screen.dart
│   │   │   ├── compatibility_check_screen.dart
│   │   │   └── fortune_report_screen.dart
│   │   ├── providers/
│   │   │   └── fortune_provider.dart
│   │   └── widgets/
│   │       └── fortune_card.dart
│   ├── community/
│   │   ├── screens/
│   │   │   ├── community_screen.dart
│   │   │   ├── post_detail_screen.dart
│   │   │   ├── create_post_screen.dart
│   │   │   └── ohang_group_screen.dart
│   │   └── providers/
│   │       └── community_provider.dart
│   └── subscription/
│       ├── screens/
│       │   └── subscription_screen.dart
│       ├── providers/
│       │   └── subscription_provider.dart
│       └── services/
│           └── payment_service.dart
├── shared/
│   ├── widgets/
│   │   ├── ojak_button.dart
│   │   ├── ojak_card.dart
│   │   ├── glassmorphism_container.dart
│   │   ├── ohaeng_icon.dart               // 오행 아이콘
│   │   ├── compatibility_grade_badge.dart  // 궁합 등급 뱃지
│   │   ├── star_particle_background.dart   // 별빛 배경
│   │   └── shimmer_loading.dart
│   ├── models/
│   │   └── five_elements.dart
│   └── services/
│       ├── firebase_service.dart
│       └── notification_service.dart
└── l10n/
    ├── app_ko.arb
    └── app_en.arb
```

---

## 11. 궁합 계산 알고리즘 상세 (Firebase Functions)

### 11.1 의사코드

```typescript
function calculateCompatibility(userA: SajuPillar, userB: SajuPillar): CompatibilityResult {
  let score = 0;
  const details: Detail[] = [];

  // ═══ 1. 일주 궁합 (400점 만점) ═══

  // 1-1. 일간 합 (天干合) — 100점
  if (isCheonganHap(userA.dayStem, userB.dayStem)) {
    score += 100;
    details.push({ category: "일주", item: "일간 천간합", score: 100,
      desc: `${userA.dayStem}${userB.dayStem} 합 — 정신적 유대가 깊음` });
  }

  // 1-2. 일간 상생 — 80점
  else if (isSangsaeng(userA.dayStem, userB.dayStem)) {
    score += 80;
    details.push({ ... });
  }

  // 1-3. 일지 육합 (地支六合) — 100점
  if (isYukhap(userA.dayBranch, userB.dayBranch)) {
    score += 100;
    details.push({ ... });
  }

  // 1-4. 일지 삼합 — 70점
  else if (isSamhap(userA.dayBranch, userB.dayBranch)) {
    score += 70;
  }

  // 1-5. 일지 충 — 감점
  if (isChung(userA.dayBranch, userB.dayBranch)) {
    score -= 50;
    details.push({ ... negative ... });
  }

  // ═══ 2. 오행 조화 (250점 만점) ═══

  // 2-1. 오행 보완도 — 100점
  const elementBalance = calculateElementComplement(userA.fiveElements, userB.fiveElements);
  score += elementBalance; // 0~100

  // 2-2. 용신 보완 — 80점
  if (userA.yongShin === dominantElement(userB) || userB.yongShin === dominantElement(userA)) {
    score += 80;
  }

  // 2-3. 오행 균형 시너지 — 70점
  const combinedBalance = calculateCombinedBalance(userA.fiveElements, userB.fiveElements);
  score += Math.round(combinedBalance * 70);

  // ═══ 3. 간지 상호작용 (200점 만점) ═══

  // 연·월·시 기둥의 천간합, 지지합, 형충파해를 전수 비교
  for (const pillar of ["year", "month", "hour"]) {
    score += evaluatePillarInteraction(userA[pillar], userB[pillar]);
  }

  // ═══ 4. 대운 시너지 (100점 만점) ═══
  score += evaluateDaeunSynergy(userA, userB); // 0~100

  // ═══ 5. 특수 살 (50점 만점, ±25×2) ═══
  score += evaluateSpecialSal(userA, userB); // -50 ~ +50

  // 최종 클램프
  score = Math.max(0, Math.min(1000, score));

  const grade = getGrade(score);

  return { score, grade, details };
}
```

### 11.2 궁합 등급 판정

```typescript
function getGrade(score: number): CompatibilityGrade {
  if (score >= 850) return { grade: "천생연분", emoji: "🌟", color: "#FFD700" };
  if (score >= 700) return { grade: "최상궁합", emoji: "💎", color: "#9B59B6" };
  if (score >= 550) return { grade: "좋은인연", emoji: "💚", color: "#2ECC71" };
  if (score >= 400) return { grade: "보통궁합", emoji: "🔶", color: "#F39C12" };
  return { grade: "조심지연", emoji: "⚡", color: "#95A5A6" };
}
```

---

## 12. 주요 의존성 (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  freezed_annotation: ^2.4.0

  # Routing
  go_router: ^14.0.0

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_messaging: ^15.0.0
  cloud_functions: ^5.0.0

  # UI
  appinio_swiper: ^7.0.0           # 스와이프 카드
  fl_chart: ^0.68.0                 # 오행 레이더 차트
  shimmer: ^3.0.0                   # 로딩 shimmer
  cached_network_image: ^3.3.0
  lottie: ^3.0.0                    # 애니메이션
  google_fonts: ^6.2.0

  # Auth
  kakao_flutter_sdk: ^1.9.0
  sign_in_with_apple: ^6.1.0
  google_sign_in: ^6.2.0

  # Payment
  purchases_flutter: ^8.0.0         # RevenueCat

  # Utils
  image_picker: ^1.0.0
  image_cropper: ^7.0.0
  intl: ^0.19.0
  json_annotation: ^4.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  flutter_lints: ^4.0.0
```

---

## 부록: 궁합 해석 AI 프롬프트 가이드

### Gemini Flash에 전달할 프롬프트 템플릿

```
당신은 명리학 전문가이자 연애 상담사입니다.
두 사람의 사주 궁합 분석 결과를 바탕으로, 따뜻하고 긍정적인 톤으로 해석해주세요.

[사용자 A 사주]
- 일간: {dayStemA}
- 일지: {dayBranchA}
- 오행 분포: 목{woodA} 화{fireA} 토{earthA} 금{metalA} 수{waterA}
- 용신: {yongShinA}

[사용자 B 사주]
- 일간: {dayStemB}
- 일지: {dayBranchB}
- 오행 분포: 목{woodB} 화{fireB} 토{earthB} 금{metalB} 수{waterB}
- 용신: {yongShinB}

[궁합 분석 결과]
- 총점: {totalScore}/1000
- 등급: {grade}
- 주요 포인트: {details}

위 결과를 바탕으로 다음을 작성해주세요:
1. 한 줄 요약 (30자 이내)
2. 연애 궁합 해석 (3-5문장)
3. 결혼 궁합 해석 (3-5문장)
4. 서로에게 줄 수 있는 조언 (각 2문장)
5. 두 사람의 행운의 데이트 장소 1곳

톤: 따뜻하고 긍정적, 부정적 요소도 "성장의 기회"로 프레이밍
길이: 총 500자 이내
```

---

*이 기획서는 OJAK 데이팅 앱의 MVP 개발을 위한 종합 가이드입니다. 오케스트레이터 HANDOFF.md 작성 시 이 문서의 각 섹션을 참조합니다.*
