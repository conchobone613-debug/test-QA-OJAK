import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _fullFormat = DateFormat('yyyy년 MM월 dd일', 'ko');
  static final DateFormat _shortFormat = DateFormat('yyyy.MM.dd', 'ko');
  static final DateFormat _monthDayFormat = DateFormat('MM월 dd일', 'ko');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'ko');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy.MM.dd HH:mm', 'ko');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  // ─── 포맷 ───

  static String formatFull(DateTime dt) => _fullFormat.format(dt);
  static String formatShort(DateTime dt) => _shortFormat.format(dt);
  static String formatMonthDay(DateTime dt) => _monthDayFormat.format(dt);
  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);
  static String formatIso(DateTime dt) => _isoFormat.format(dt);

  static String formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}개월 전';
    return '${(diff.inDays / 365).floor()}년 전';
  }

  static String formatChatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dtDate = DateTime(dt.year, dt.month, dt.day);

    if (dtDate == today) return formatTime(dt);
    if (dtDate == yesterday) return '어제';
    if (now.year == dt.year) return formatMonthDay(dt);
    return formatShort(dt);
  }

  // ─── 나이 계산 ───

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static int calculateKoreanAge(DateTime birthDate) {
    return DateTime.now().year - birthDate.year + 1;
  }

  static String ageLabel(DateTime birthDate) {
    final age = calculateAge(birthDate);
    return '$age세';
  }

  // ─── 양력 ↔ 음력 변환 ───
  // 간이 변환표(1900~2100) 사용. 정밀 변환은 외부 패키지 권장.

  static Map<String, dynamic> solarToLunar(DateTime solar) {
    // TODO: 완전한 음력 변환 테이블 구현 또는 lunar_calendar 패키지 연동
    // 현재는 근사값 반환 (실제 서비스에서는 정밀 라이브러리 사용 권장)
    return {
      'year': solar.year,
      'month': solar.month,
      'day': solar.day,
      'isLeapMonth': false,
      'note': 'approximate',
    };
  }

  static DateTime lunarToSolar(int lunarYear, int lunarMonth, int lunarDay, {bool isLeapMonth = false}) {
    // TODO: 완전한 양력 변환 테이블 구현 또는 lunar_calendar 패키지 연동
    return DateTime(lunarYear, lunarMonth, lunarDay);
  }

  static String formatLunarDate(int year, int month, int day, {bool isLeapMonth = false}) {
    final leapStr = isLeapMonth ? '(윤)' : '';
    return '음력 $year년 $leapStr${month}월 ${day}일';
  }

  // ─── 기타 유틸 ───

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static DateTime endOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

  static int daysBetween(DateTime a, DateTime b) {
    return startOfDay(b).difference(startOfDay(a)).inDays.abs();
  }

  static List<String> get zodiacSigns => ['양자리', '황소자리', '쌍둥이자리', '게자리', '사자자리', '처녀자리', '천칭자리', '전갈자리', '사수자리', '염소자리', '물병자리', '물고기자리'];

  static String getZodiacSign(DateTime birthDate) {
    final m = birthDate.month;
    final d = birthDate.day;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return '양자리';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return '황소자리';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 21)) return '쌍둥이자리';
    if ((m == 6 && d >= 22) || (m == 7 && d <= 22)) return '게자리';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return '사자자리';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return '처녀자리';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return '천칭자리';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return '전갈자리';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return '사수자리';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return '염소자리';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return '물병자리';
    return '물고기자리';
  }

  static String getChineseZodiac(int year) {
    const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
    return animals[year % 12];
  }

  static DateTime? parseIso(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}