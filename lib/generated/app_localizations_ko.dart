// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '오작 - 오픈 작업 관리';

  @override
  String get appSubtitle => '효율적인 작업 추적 및 협업';

  @override
  String get homeTitle => '홈';

  @override
  String get projectsTitle => '프로젝트';

  @override
  String get tasksTitle => '작업';

  @override
  String get settingsTitle => '설정';

  @override
  String get profileTitle => '프로필';

  @override
  String get loginTitle => '로그인';

  @override
  String get logoutTitle => '로그아웃';

  @override
  String get signupTitle => '회원가입';

  @override
  String get welcome => '환영합니다';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get name => '이름';

  @override
  String get submitButton => '제출';

  @override
  String get cancelButton => '취소';

  @override
  String get saveButton => '저장';

  @override
  String get deleteButton => '삭제';

  @override
  String get editButton => '수정';

  @override
  String get createButton => '생성';

  @override
  String get backButton => '뒤로';

  @override
  String get nextButton => '다음';

  @override
  String get searchPlaceholder => '검색...';

  @override
  String get noResults => '결과가 없습니다';

  @override
  String get loading => '로딩 중...';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get warning => '경고';

  @override
  String get info => '정보';

  @override
  String get confirmation => '확인';

  @override
  String get confirmDelete => '정말로 삭제하시겠습니까?';

  @override
  String get confirmLogout => '로그아웃 하시겠습니까?';

  @override
  String get emptyState => '데이터가 없습니다';

  @override
  String get retry => '다시 시도';

  @override
  String get close => '닫기';

  @override
  String get done => '완료';

  @override
  String get pending => '대기 중';

  @override
  String get inProgress => '진행 중';

  @override
  String get completed => '완료됨';

  @override
  String get archived => '보관됨';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get selectTime => '시간 선택';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get languageKo => '한국어';

  @override
  String get languageEn => 'English';

  @override
  String get darkMode => '다크 모드';

  @override
  String get lightMode => '라이트 모드';

  @override
  String get systemTheme => '시스템 테마';

  @override
  String get notifications => '알림';

  @override
  String get notificationSettings => '알림 설정';

  @override
  String get enableNotifications => '알림 활성화';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get emailNotifications => '이메일 알림';

  @override
  String get aboutApp => '앱 정보';

  @override
  String get version => '버전';

  @override
  String get termsOfService => '이용약관';

  @override
  String get privacyPolicy => '개인정보처리방침';

  @override
  String get feedback => '피드백';

  @override
  String get contactUs => '문의하기';

  @override
  String get projectName => '프로젝트 이름';

  @override
  String get projectDescription => '프로젝트 설명';

  @override
  String get createProject => '프로젝트 생성';

  @override
  String get editProject => '프로젝트 수정';

  @override
  String get deleteProject => '프로젝트 삭제';

  @override
  String get taskTitle => '작업 제목';

  @override
  String get taskDescription => '작업 설명';

  @override
  String get dueDate => '마감일';

  @override
  String get priority => '우선순위';

  @override
  String get high => '높음';

  @override
  String get medium => '중간';

  @override
  String get low => '낮음';

  @override
  String get assignee => '담당자';

  @override
  String assignedTo(String name) {
    return '담당: $name';
  }

  @override
  String get createdAt => '생성일';

  @override
  String get updatedAt => '수정일';

  @override
  String get completedAt => '완료일';

  @override
  String get members => '멤버';

  @override
  String get addMember => '멤버 추가';

  @override
  String get removeMember => '멤버 제거';

  @override
  String get role => '역할';

  @override
  String get admin => '관리자';

  @override
  String get member => '멤버';

  @override
  String get viewer => '뷰어';

  @override
  String get invalidEmail => '유효하지 않은 이메일입니다';

  @override
  String get passwordTooShort => '비밀번호는 6자 이상이어야 합니다';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get emailAlreadyExists => '이미 존재하는 이메일입니다';

  @override
  String get userNotFound => '사용자를 찾을 수 없습니다';

  @override
  String get unauthorizedAccess => '접근 권한이 없습니다';

  @override
  String get networkError => '네트워크 오류가 발생했습니다';

  @override
  String get unknownError => '알 수 없는 오류가 발생했습니다';

  @override
  String get tryAgain => '다시 시도하세요';

  @override
  String get offline => '오프라인 상태입니다';

  @override
  String get online => '온라인 상태입니다';
}
