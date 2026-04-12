class AppConstants {
  // 일일 리소스 한도
  static const int dailySwipeLimit = 5; // 무료 일일 스와이프 수
  static const int dailySuperLikeCount = 1; // 슈퍼좋아요 수
  static const int dailyRecommendationCount = 3; // 일일 추천 수

  // 월간 리소스 한도
  static const int monthlySuperLikeCount = 20; // 월간 슈퍼좋아요 누적
  static const int monthlyRecommendationCount = 50; // 월간 추천 누적

  // 타이머 (ms)
  static const int swipeResetTimerMs = 86400000; // 24시간 (86400초)
  static const int resourceResetTimerMs = 2592000000; // 30일

  // 프로필 기본값
  static const int maxPhotoCount = 6; // 최대 사진 개수
  static const int maxBioLength = 300; // 자기소개 최대 글자
  static const int minAgeRange = 18; // 최소 검색 나이
  static const int maxAgeRange = 99; // 최대 검색 나이
  static const int defaultAgeRangeMin = 25;
  static const int defaultAgeRangeMax = 45;
  static const int defaultSearchDistance = 50; // km

  // 매칭 설정
  static const int minProfileCompletePercent = 50; // 매칭 허용 최소 프로필 완성도
  static const int profileCompletePhotoThreshold = 2; // 프로필 완성도: 최소 사진 수
  static const int messageExpiryDays = 30; // 메시지 삭제 일수

  // 사주 궁합 점수
  static const int maxCompatibilityScore = 100;
  static const int minCompatibilityScore = 0;
  static const int compatibilityThresholdGood = 70; // 좋음 이상 점수
  static const int compatibilityThresholdExcellent = 85; // 우수 이상 점수

  // 알림 설정
  static const bool defaultNotificationEnabled = true;
  static const bool defaultMessageNotification = true;
  static const bool defaultMatchNotification = true;
  static const bool defaultMarketingNotification = false;

  // API/서버 설정
  static const String apiBaseUrl = 'https://api.ojak.app'; // TODO: 실제 URL로 변경
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryCount = 3;
  static const int retryDelayMs = 1000;

  // 앱 버전
  static const String appVersion = '0.1.0';
  static const int buildNumber = 1;

  // 에러 메시지
  static const String errorNetworkMessage = '네트워크 연결을 확인해주세요.';
  static const String errorServerMessage = '서버 오류가 발생했습니다.';
  static const String errorInvalidInput = '입력값이 올바르지 않습니다.';
  static const String errorUnauthorized = '인증이 필요합니다.';

  // 사주 데이터 캐시
  static const int sajuDataCacheDurationMinutes = 60; // 1시간
  static const int compatibilityResultCacheDurationMinutes = 30; // 30분
}