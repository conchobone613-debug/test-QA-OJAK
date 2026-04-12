# HANDOFF.md

## 작업 요약
사주팔자 궁합 기반 데이팅 앱 "OJAK(오작)" MVP 신규 빌드. Flutter + Firebase + Gemini Flash 하이브리드 아키텍처.

## 현재 상태
기획 완료. Flutter 프로젝트 미생성. 오케스트레이터 첫 실행(신규 생성 모드) 대기 중.

## 핵심 참조 문서
- `docs/ojak_master_plan.md` — 전체 기획서 (앱 컨셉, 기술 아키텍처, 디자인 시스템, 화면 구성, 궁합 알고리즘, 수익 모델)

## 확정 아키텍처
- **Frontend**: Flutter 3.x + Riverpod + go_router + freezed
- **Backend**: Firebase (Auth, Firestore, Storage, Functions, FCM)
- **사주 엔진**: Firebase Functions + `@gracefullight/saju` npm
- **AI 해석**: Gemini 2.5 Flash API
- **결제**: RevenueCat

---

## 남은 과제 목록

### 과제 1: Flutter 프로젝트 초기화 + 의존성 설정
- **설명**: Flutter 프로젝트 생성 및 pubspec.yaml 의존성 추가. 프로젝트 기본 구조(lib/, functions/) 생성.
  - `flutter create` 으로 프로젝트 초기화 (org: com.ojak.app)
  - pubspec.yaml에 모든 의존성 추가 (riverpod, go_router, firebase, appinio_swiper, fl_chart, shimmer, cached_network_image, lottie, google_fonts, kakao_flutter_sdk, sign_in_with_apple, google_sign_in, purchases_flutter, image_picker, image_cropper, intl, freezed 등)
  - dev_dependencies 추가 (build_runner, riverpod_generator, freezed, json_serializable)
  - analysis_options.yaml 린트 설정
- **참조**: `docs/ojak_master_plan.md > 12. 주요 의존성`
- **수정 파일**: pubspec.yaml, analysis_options.yaml, lib/main.dart
- **파일 겹침**: 과제 3과 lib/main.dart 겹침
- **우선순위**: 🔴 높음
- **선행 과제**: 없음

### 과제 2: Firebase Functions 사주 계산 엔진
- **설명**: Firebase Functions 프로젝트 셋업 및 사주 원국 계산/궁합 점수 계산 함수 구현.
  - `functions/` 디렉토리 초기화 (TypeScript)
  - `@gracefullight/saju` 또는 `ssaju` npm 설치
  - `calculateSaju` — 생년월일시 → 사주 원국(8자) 변환
  - `calculateCompatibility` — 두 사주 원국 → 궁합 점수(1000점 만점) 계산
  - `sajuUtils` — 천간합/지지육합/삼합/방합/형충파해 판정 유틸
  - 궁합 등급 판정 (천생연분/최상궁합/좋은인연/보통궁합/조심지연)
- **참조**: `docs/ojak_master_plan.md > 2.1 사주 궁합 엔진`, `docs/ojak_master_plan.md > 11. 궁합 계산 알고리즘 상세`
- **수정 파일**: functions/package.json, functions/tsconfig.json, functions/src/index.ts, functions/src/saju/calculateSaju.ts, functions/src/saju/calculateCompatibility.ts, functions/src/saju/sajuUtils.ts
- **파일 겹침**: 과제 8과 functions/src/index.ts 겹침
- **우선순위**: 🔴 높음
- **선행 과제**: 없음

### 과제 3: 디자인 시스템 (컬러, 타이포, 테마)
- **설명**: 앱 전체 디자인 토큰 정의. 다크 모드 기본, 밤하늘/우주 테마.
  - `app_colors.dart`: Primary(Celestial Indigo #1B1464), Secondary(Fortune Gold #D4AF37), Accent(Blossom Pink #FF6B8A), Background(#0A0E27), 오행 5색, 궁합 등급 5색
  - `app_text_styles.dart`: Pretendard 한글 + Outfit 영문 숫자 + Noto Serif KR 한자
  - `app_theme.dart`: ThemeData 다크 모드, 글래스모피즘 기본값
  - `app_gradients.dart`: 궁합 등급별 그라데이션
- **참조**: `docs/ojak_master_plan.md > 4. 디자인 시스템`
- **수정 파일**: lib/core/theme/app_colors.dart, lib/core/theme/app_text_styles.dart, lib/core/theme/app_theme.dart, lib/core/theme/app_gradients.dart, lib/main.dart, lib/app.dart
- **파일 겹침**: 과제 1과 lib/main.dart 겹침
- **우선순위**: 🔴 높음
- **선행 과제**: 과제 1

### 과제 4: 상수 및 사주 데이터 정의
- **설명**: 천간/지지/오행 상수, 앱 설정 상수 정의.
  - `saju_constants.dart`: 10천간(甲~癸), 12지지(子~亥), 5오행(木火土金水), 천간합 5쌍, 지지육합 6쌍, 지지삼합 4조, 형충파해 관계 테이블
  - `app_constants.dart`: 무료 일일 스와이프 수(5), 슈퍼좋아요 수(1), 추천 수 등
- **참조**: `docs/ojak_master_plan.md > 2.1 사주 궁합 엔진`
- **수정 파일**: lib/core/constants/saju_constants.dart, lib/core/constants/app_constants.dart
- **파일 겹침**: 없음
- **우선순위**: 🔴 높음
- **선행 과제**: 없음

### 과제 5: 라우터 설정 (go_router)
- **설명**: 전체 앱 라우팅 구조 정의. 모든 화면 경로 등록.
  - Splash → Onboarding → Login → ProfileSetup → Main(탭) 플로우
  - 메인 탭 5개: MatchFeed, Fortune, ChatList, Community, MyPage
  - 상세 화면 라우트: UserDetail, MatchSuccess, CompatibilityDetail, ChatRoom 등
  - 딥링크 지원
  - 인증 가드 (비로그인 → Login 리다이렉트)
- **참조**: `docs/ojak_master_plan.md > 5. 화면 구성`
- **수정 파일**: lib/core/router/app_router.dart
- **파일 겹침**: 없음
- **우선순위**: 🟡 보통
- **선행 과제**: 과제 1

### 과제 6: 공통 위젯 라이브러리
- **설명**: 앱 전체 재사용 위젯 구현.
  - `ojak_button.dart`: Primary(금빛 그라데이션), Secondary(금 테두리), Ghost 3종
  - `ojak_card.dart`: BackdropFilter 글래스모피즘 카드 (배경 #16213E opacity 0.85, border gold 0.2)
  - `glassmorphism_container.dart`: 범용 글래스모피즘 컨테이너
  - `ohaeng_icon.dart`: 오행 아이콘 위젯 (木🌳 火🔥 土🏔️ 金⚡ 水💧), size/color 파라미터
  - `compatibility_grade_badge.dart`: 궁합 5등급별 그라데이션 뱃지 (천생연분~조심지연)
  - `star_particle_background.dart`: CustomPainter 별빛 파티클 배경 애니메이션
  - `shimmer_loading.dart`: Shimmer 로딩 플레이스홀더
- **참조**: `docs/ojak_master_plan.md > 4.3 디자인 원칙`, `docs/ojak_master_plan.md > 2.1.3 궁합 등급 시스템`
- **수정 파일**: lib/shared/widgets/ojak_button.dart, lib/shared/widgets/ojak_card.dart, lib/shared/widgets/glassmorphism_container.dart, lib/shared/widgets/ohaeng_icon.dart, lib/shared/widgets/compatibility_grade_badge.dart, lib/shared/widgets/star_particle_background.dart, lib/shared/widgets/shimmer_loading.dart
- **파일 겹침**: 없음
- **우선순위**: 🔴 높음
- **선행 과제**: 과제 3

### 과제 7: 데이터 모델 (freezed)
- **설명**: Firestore 데이터 모델 + freezed 코드 생성 설정.
  - `user_profile.dart`: UserProfile (displayName, birthDateTime, gender, height, occupation, region, bio, interests, photos, sajuPillar, preferences, isPremium...)
  - `saju_profile.dart`: SajuPillar (yearStem/Branch, monthStem/Branch, dayStem/Branch, hourStem/Branch, fiveElements, yongShin, dayMaster)
  - `match.dart`: Match (participants, compatibilityScore, grade, aiSummary)
  - `compatibility_result.dart`: CompatibilityResult (score, grade, details[])
  - `message.dart`: Message (senderId, text, imageUrl, readAt, createdAt)
  - `five_elements.dart`: FiveElements (wood, fire, earth, metal, water)
  - JSON 직렬화 설정
- **참조**: `docs/ojak_master_plan.md > 3.3 Firestore 데이터 모델`
- **수정 파일**: lib/features/profile/models/user_profile.dart, lib/features/profile/models/saju_profile.dart, lib/features/matching/models/match.dart, lib/features/matching/models/compatibility_result.dart, lib/features/chat/models/message.dart, lib/shared/models/five_elements.dart
- **파일 겹침**: 없음
- **우선순위**: 🔴 높음
- **선행 과제**: 과제 1

### 과제 8: Firebase Functions — 매칭 엔진 + AI 해석
- **설명**: 추천 피드 생성, 스와이프 처리, 궁합 AI 해석 함수 구현.
  - `generateRecommendations.ts`: 이상형 조건 필터 → 궁합 점수 계산 → 상위 N명 추출
  - `processSwipe.ts`: 스와이프 기록 + 상호 좋아요 체크 → 매칭 성립 시 matches 컬렉션 생성 + FCM 푸시
  - `matchingUtils.ts`: 거리/나이/키 필터링 유틸
  - `generateInterpretation.ts`: Gemini Flash API 호출 → 궁합 자연어 해석 생성
  - `generateFortune.ts`: 일일/월간 운세 생성
  - `generateIcebreaker.ts`: 궁합 기반 대화 주제 3개 생성
  - `sendNotification.ts`: FCM 푸시 알림
- **참조**: `docs/ojak_master_plan.md > 9. Firebase Functions 구조`, `docs/ojak_master_plan.md > 부록: 궁합 해석 AI 프롬프트 가이드`
- **수정 파일**: functions/src/matching/generateRecommendations.ts, functions/src/matching/processSwipe.ts, functions/src/matching/matchingUtils.ts, functions/src/ai/generateInterpretation.ts, functions/src/ai/generateFortune.ts, functions/src/ai/generateIcebreaker.ts, functions/src/notification/sendNotification.ts, functions/src/index.ts
- **파일 겹침**: 과제 2와 functions/src/index.ts 겹침
- **우선순위**: 🟡 보통
- **선행 과제**: 과제 2

### 과제 9: 인증 화면 (Splash + Onboarding + Login)
- **설명**: 앱 진입 플로우 3개 화면 구현.
  - `splash_screen.dart`: 오작교 로고 + 별빛 파티클 배경, 자동 인증 체크 후 라우팅
  - `onboarding_screen.dart`: PageView 3장 — ① 사주 매칭 소개 ② 궁합 점수 설명 ③ CTA(시작하기)
  - `login_screen.dart`: 카카오(노랑)/Apple(흰)/Google(파랑) 소셜 로그인 3종 버튼, 글래스모피즘 카드 안에 배치
  - `auth_provider.dart`: Riverpod AuthNotifier (로그인 상태, 현재 사용자)
  - `auth_service.dart`: Firebase Auth + 카카오/Apple/Google SDK 연동
- **참조**: `docs/ojak_master_plan.md > 5.1 인증 플로우`
- **수정 파일**: lib/features/auth/screens/splash_screen.dart, lib/features/auth/screens/onboarding_screen.dart, lib/features/auth/screens/login_screen.dart, lib/features/auth/providers/auth_provider.dart, lib/features/auth/services/auth_service.dart
- **파일 겹침**: 없음
- **우선순위**: 🟡 보통
- **선행 과제**: 과제 3, 과제 5, 과제 6

### 과제 10: 프로필 설정 화면
- **설명**: 5단계 프로필 생성 플로우 + 사주 결과 화면.
  - `profile_setup_screen.dart`: Stepper 또는 PageView로 5단계 (기본정보 → 생년월일시 → 사진 → 자기소개 → 이상형)
  - `saju_loading_screen.dart`: 사주 계산 중 로딩 연출 (오행 로테이션 애니메이션 + "당신의 사주를 분석하고 있어요...")
  - `saju_result_screen.dart`: 사주 원국 요약 카드 (오행 레이더 차트 fl_chart + AI 성격 분석 3줄)
  - `profile_provider.dart`: ProfileNotifier (프로필 CRUD, Firestore 동기화)
  - `five_elements_chart.dart`: fl_chart RadarChart로 오행 분포 시각화
  - `saju_card.dart`: 사주 원국 8자 표시 카드 (한자 + 한글)
- **참조**: `docs/ojak_master_plan.md > 5.1 인증 플로우`, `docs/ojak_master_plan.md > 2.2 사용자 프로필`
- **수정 파일**: lib/features/profile/screens/profile_setup_screen.dart, lib/features/profile/screens/saju_loading_screen.dart, lib/features/profile/screens/saju_result_screen.dart, lib/features/profile/providers/profile_provider.dart, lib/features/profile/widgets/five_elements_chart.dart, lib/features/profile/widgets/saju_card.dart
- **파일 겹침**: 없음
- **우선순위**: 🟡 보통
- **선행 과제**: 과제 6, 과제 7

### 과제 11: 매칭 피드 (스와이프 카드)
- **설명**: 메인 홈 화면. 궁합 점수 기반 추천 카드 스와이프.
  - `match_feed_screen.dart`: appinio_swiper로 프로필 카드 스와이프 (좋아요/패스/슈퍼좋아요). 별빛 배경. 카드에 프로필 사진 + 닉네임 + 나이 + 궁합 등급 뱃지 + 한 줄 궁합 코멘트 표시.
  - `swipe_card.dart`: 개별 프로필 카드 위젯 (사진 위에 그라데이션 오버레이 + 정보)
  - `user_detail_screen.dart`: 카드 탭 시 상세 프로필 (사진 갤러리 + 자기소개 + 오행 차트 + 궁합 상세)
  - `match_success_screen.dart`: 매칭 성립 축하 화면 (오작교 브릿지 애니메이션 + 궁합 점수 대형 표시 + "대화 시작하기" CTA)
  - `compatibility_detail_screen.dart`: 궁합 상세 리포트 (카테고리별 점수 바 + AI 해석 텍스트)
  - `matching_provider.dart`: MatchingNotifier (추천 피드 로드, 스와이프 처리, 매칭 체크)
  - `match_animation.dart`: 오작교 브릿지 Lottie/CustomPainter 애니메이션
  - `compatibility_badge.dart`: 카드 내 궁합 뱃지 (등급별 색상 + 점수)
- **참조**: `docs/ojak_master_plan.md > 2.3 매칭 시스템`, `docs/ojak_master_plan.md > 5.3 상세 화면 목록 > 홈 탭`
- **수정 파일**: lib/features/matching/screens/match_feed_screen.dart, lib/features/matching/screens/user_detail_screen.dart, lib/features/matching/screens/match_success_screen.dart, lib/features/matching/screens/compatibility_detail_screen.dart, lib/features/matching/providers/matching_provider.dart, lib/features/matching/widgets/swipe_card.dart, lib/features/matching/widgets/match_animation.dart, lib/features/matching/widgets/compatibility_badge.dart
- **파일 겹침**: 없음
- **우선순위**: 🟡 보통
- **선행 과제**: 과제 6, 과제 7

### 과제 12: 채팅 시스템
- **설명**: 매칭 후 1:1 채팅 기능.
  - `chat_list_screen.dart`: 매칭된 채팅 목록 (최근 메시지 미리보기 + 궁합 뱃지 + 안 읽은 메시지 카운트)
  - `chat_room_screen.dart`: 1:1 채팅방 (텍스트 + 이미지 전송, 읽음 확인, Firestore 실시간 스트림)
  - `chat_bubble.dart`: 내 메시지(금색)/상대 메시지(보라색) 말풍선
  - `icebreaker_card.dart`: 채팅방 상단 "궁합 토크" 아이스브레이커 3개 카드
  - `chat_provider.dart`: ChatNotifier (채팅 목록 로드, 메시지 전송/수신, 실시간 리스너)
- **참조**: `docs/ojak_master_plan.md > 2.4 채팅 시스템`
- **수정 파일**: lib/features/chat/screens/chat_list_screen.dart, lib/features/chat/screens/chat_room_screen.dart, lib/features/chat/widgets/chat_bubble.dart, lib/features/chat/widgets/icebreaker_card.dart, lib/features/chat/providers/chat_provider.dart
- **파일 겹침**: 없음
- **우선순위**: 🟡 보통
- **선행 과제**: 과제 6, 과제 7

### 과제 13: 사주 콘텐츠 화면 (운세 탭)
- **설명**: 운세 + 내 사주 + 궁합 보기 기능.
  - `fortune_screen.dart`: 오늘의 운세 (연애운/재물운/건강운/행운의 시간) + 월간 운세 미리보기
  - `my_saju_screen.dart`: 내 사주 원국 상세 (8자 한자 표기 + 오행 레이더 차트 + AI 성격 분석)
  - `compatibility_check_screen.dart`: 직접 궁합 보기 (상대방 생년월일시 입력 → 궁합 결과)
  - `fortune_report_screen.dart`: 월간/연간 상세 운세 리포트 (프리미엄 잠금)
  - `fortune_provider.dart`: FortuneNotifier (일일 운세 로드/캐시, 수동 궁합 계산 요청)
  - `fortune_card.dart`: 운세 카드 위젯 (글래스모피즘 + 아이콘 + 운세 텍스트)
- **참조**: `docs/ojak_master_plan.md > 2.5 사주 콘텐츠 섹션`
- **수정 파일**: lib/features/fortune/screens/fortune_screen.dart, lib/features/fortune/screens/my_saju_screen.dart, lib/features/fortune/screens/compatibility_check_screen.dart, lib/features/fortune/screens/fortune_report_screen.dart, lib/features/fortune/providers/fortune_provider.dart, lib/features/fortune/widgets/fortune_card.dart
- **파일 겹침**: 없음
- **우선순위**: 🟡 보통
- **선행 과제**: 과제 6, 과제 7

### 과제 14: 마이페이지 + 설정
- **설명**: 프로필 관리, 설정, 구독 화면.
  - `my_page_screen.dart`: 프로필 요약 (사진 + 닉네임 + 사주 한 줄 + 오행 아이콘) + 설정 메뉴 리스트
  - `edit_profile_screen.dart`: 프로필 편집 (사진/닉네임/자기소개/관심사/이상형 수정)
  - `settings_screen.dart`: 앱 설정 (알림, 거리 설정, 로그아웃, 회원 탈퇴)
  - `subscription_screen.dart`: 구독 관리 (무료/Plus/Premium 비교표 + RevenueCat 결제)
  - `subscription_provider.dart`: SubscriptionNotifier (현재 구독 상태, 구매 처리)
  - `payment_service.dart`: RevenueCat SDK 연동 래퍼
- **참조**: `docs/ojak_master_plan.md > 5.3 > 마이페이지 탭`, `docs/ojak_master_plan.md > 6. 수익 모델`
- **수정 파일**: lib/features/profile/screens/my_page_screen.dart, lib/features/profile/screens/edit_profile_screen.dart, lib/features/subscription/screens/subscription_screen.dart, lib/features/subscription/providers/subscription_provider.dart, lib/features/subscription/services/payment_service.dart
- **파일 겹침**: 없음
- **우선순위**: 🟢 낮음
- **선행 과제**: 과제 6, 과제 7

### 과제 15: 커뮤니티 화면
- **설명**: 오행톡 소그룹 + 게시판 기능.
  - `community_screen.dart`: 게시글 피드 (인기/최신 정렬) + FAB(글 작성)
  - `post_detail_screen.dart`: 게시글 상세 + 댓글 리스트 + 댓글 작성
  - `create_post_screen.dart`: 글 작성 (텍스트 + 카테고리 태그)
  - `ohang_group_screen.dart`: 오행 기반 소그룹 채팅 (같은 일간끼리 그룹)
  - `community_provider.dart`: CommunityNotifier (게시글 CRUD, 댓글, 소그룹)
- **참조**: `docs/ojak_master_plan.md > 2.6 커뮤니티`
- **수정 파일**: lib/features/community/screens/community_screen.dart, lib/features/community/screens/post_detail_screen.dart, lib/features/community/screens/create_post_screen.dart, lib/features/community/screens/ohang_group_screen.dart, lib/features/community/providers/community_provider.dart
- **파일 겹침**: 없음
- **우선순위**: 🟢 낮음
- **선행 과제**: 과제 6, 과제 7

### 과제 16: 공통 서비스 + 유틸
- **설명**: 앱 전체 공유 서비스 및 유틸리티.
  - `firebase_service.dart`: Firestore/Storage/Functions 호출 래퍼 (에러 핸들링 포함)
  - `notification_service.dart`: FCM 초기화 + 토큰 관리 + 알림 핸들링
  - `validators.dart`: 입력값 검증 (닉네임, 생년월일, 자기소개 글자수 등)
  - `date_utils.dart`: 양력↔음력 변환, 나이 계산, 날짜 포맷
  - `settings_screen.dart`: 알림 설정, 로그아웃, 회원 탈퇴
  - `blocked_users_screen.dart`: 차단 사용자 관리
  - `notification_settings_screen.dart`: 알림 설정 관리
- **참조**: `docs/ojak_master_plan.md > 3.2 기술 스택`
- **수정 파일**: lib/shared/services/firebase_service.dart, lib/shared/services/notification_service.dart, lib/core/utils/validators.dart, lib/core/utils/date_utils.dart, lib/features/profile/screens/settings_screen.dart, lib/features/profile/screens/blocked_users_screen.dart, lib/features/profile/screens/notification_settings_screen.dart
- **파일 겹침**: 없음
- **우선순위**: 🟡 보통
- **선행 과제**: 과제 1

### 과제 17: 국제화 (i18n)
- **설명**: 한국어/영어 다국어 리소스 파일.
  - `app_ko.arb`: 한국어 번역 (모든 UI 텍스트)
  - `app_en.arb`: 영어 번역
  - l10n.yaml 설정
- **참조**: `docs/ojak_master_plan.md > 10. Flutter 프로젝트 구조 > l10n/`
- **수정 파일**: lib/l10n/app_ko.arb, lib/l10n/app_en.arb, l10n.yaml
- **파일 겹침**: 없음
- **우선순위**: 🟢 낮음
- **선행 과제**: 없음

---

## 과제 의존성 맵

```
과제 1 (프로젝트 초기화)
├── 과제 3 (디자인 시스템) ──┐
│   └── 과제 6 (공통 위젯) ──┤
│                             ├── 과제 9  (인증 화면)
│                             ├── 과제 10 (프로필 설정)
과제 5 (라우터) ──────────────┤── 과제 11 (매칭 피드)
                              ├── 과제 12 (채팅)
과제 7 (데이터 모델) ─────────┤── 과제 13 (운세 탭)
                              ├── 과제 14 (마이페이지)
                              └── 과제 15 (커뮤니티)

과제 2 (사주 엔진) ─── 과제 8 (매칭 엔진 + AI)

과제 4 (상수 정의) — 독립
과제 16 (공통 서비스) — 과제 1 이후
과제 17 (i18n) — 독립
```

## 병렬 실행 가능 그룹

| 그룹 | 과제 | 조건 |
|------|------|------|
| A | 과제 1, 2, 4, 17 | 최우선, 완전 병렬 가능 |
| B | 과제 3, 5, 7, 16 | 과제 1 완료 후 |
| C | 과제 6, 8 | 과제 3 + 과제 2 완료 후 |
| D | 과제 9, 10, 11, 12, 13, 14, 15 | 과제 6 + 과제 7 완료 후, 서로 간 병렬 가능 |

## 특이사항
- **QA 파이프라인 검증 목적**: 이 프로젝트는 업데이트된 QA 포함 워크플로우를 검증하기 위한 프로젝트. 코드 품질과 빌드 성공 여부를 중점 확인.
- **Firebase 프로젝트 미생성**: google-services.json / GoogleService-Info.plist 없이 빌드 가능하도록 초기 코드에 Firebase 초기화를 조건부로 처리할 것.
- **사주 npm 패키지 선택**: `@gracefullight/saju`를 우선 시도하되, 설치 실패 시 `ssaju` 패키지 대체.
- **오케스트레이터 merge 순서**: A → B → C → D 순서로 머지 (의존성 순).
