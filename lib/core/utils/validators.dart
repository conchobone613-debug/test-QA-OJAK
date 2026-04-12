class Validators {
  Validators._();

  static const int nicknameMinLength = 2;
  static const int nicknameMaxLength = 10;
  static const int bioMaxLength = 200;
  static const int heightMin = 140;
  static const int heightMax = 220;
  static const int weightMin = 30;
  static const int weightMax = 200;

  static String? nickname(String? value) {
    if (value == null || value.trim().isEmpty) return '닉네임을 입력해 주세요.';
    final trimmed = value.trim();
    if (trimmed.length < nicknameMinLength) return '닉네임은 ${nicknameMinLength}자 이상이어야 합니다.';
    if (trimmed.length > nicknameMaxLength) return '닉네임은 ${nicknameMaxLength}자 이하여야 합니다.';
    final regex = RegExp(r'^[가-힣a-zA-Z0-9_]+$');
    if (!regex.hasMatch(trimmed)) return '닉네임에 사용할 수 없는 문자가 포함되어 있습니다.';
    return null;
  }

  static String? bio(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > bioMaxLength) return '자기소개는 ${bioMaxLength}자 이하여야 합니다.';
    return null;
  }

  static String? birthDate(DateTime? value) {
    if (value == null) return '생년월일을 입력해 주세요.';
    final now = DateTime.now();
    final age = now.year - value.year - ((now.month < value.month || (now.month == value.month && now.day < value.day)) ? 1 : 0);
    if (age < 18) return '만 18세 이상만 가입할 수 있습니다.';
    if (age > 100) return '올바른 생년월일을 입력해 주세요.';
    return null;
  }

  static String? birthDateString(String? value) {
    if (value == null || value.trim().isEmpty) return '생년월일을 입력해 주세요.';
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(value)) return '생년월일 형식은 YYYY-MM-DD 입니다.';
    try {
      final dt = DateTime.parse(value);
      return birthDate(dt);
    } catch (_) {
      return '올바른 날짜를 입력해 주세요.';
    }
  }

  static String? height(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return '숫자를 입력해 주세요.';
    if (parsed < heightMin || parsed > heightMax) return '키는 ${heightMin}~${heightMax}cm 사이여야 합니다.';
    return null;
  }

  static String? weight(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return '숫자를 입력해 주세요.';
    if (parsed < weightMin || parsed > weightMax) return '몸무게는 ${weightMin}~${weightMax}kg 사이여야 합니다.';
    return null;
  }

  static String? required(String? value, {String fieldName = '이 항목'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName을(를) 입력해 주세요.';
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return '전화번호를 입력해 주세요.';
    final regex = RegExp(r'^010\d{8}$');
    if (!regex.hasMatch(value.replaceAll('-', '').trim())) return '올바른 전화번호를 입력해 주세요.';
    return null;
  }

  static String? maxLength(String? value, int max, {String fieldName = '내용'}) {
    if (value == null) return null;
    if (value.length > max) return '$fieldName은(는) ${max}자 이하여야 합니다.';
    return null;
  }

  static bool isValidImageExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext);
  }
}