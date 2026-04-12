import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FortuneCategory {
  final String name;
  final int score; // 0~100
  final String description;
  final String icon;

  const FortuneCategory({
    required this.name,
    required this.score,
    required this.description,
    required this.icon,
  });
}

class DailyFortune {
  final DateTime date;
  final String overall;
  final int overallScore;
  final FortuneCategory love;
  final FortuneCategory money;
  final FortuneCategory health;
  final String luckyTime;
  final String luckyColor;
  final String luckyNumber;
  final String advice;

  const DailyFortune({
    required this.date,
    required this.overall,
    required this.overallScore,
    required this.love,
    required this.money,
    required this.health,
    required this.luckyTime,
    required this.luckyColor,
    required this.luckyNumber,
    required this.advice,
  });
}

class CompatibilityResult {
  final int score;
  final String grade;
  final String summary;
  final String loveAffinity;
  final String workAffinity;
  final String communicationStyle;
  final String advice;
  final List<String> strengths;
  final List<String> cautions;

  const CompatibilityResult({
    required this.score,
    required this.grade,
    required this.summary,
    required this.loveAffinity,
    required this.workAffinity,
    required this.communicationStyle,
    required this.advice,
    required this.strengths,
    required this.cautions,
  });
}

class MonthlyFortunePreview {
  final int month;
  final int year;
  final String headline;
  final int score;
  final String keyword;

  const MonthlyFortunePreview({
    required this.month,
    required this.year,
    required this.headline,
    required this.score,
    required this.keyword,
  });
}

class FortuneState {
  final DailyFortune? dailyFortune;
  final bool isDailyLoading;
  final String? dailyError;
  final CompatibilityResult? compatibilityResult;
  final bool isCompatibilityLoading;
  final String? compatibilityError;
  final List<MonthlyFortunePreview> monthlyPreviews;

  const FortuneState({
    this.dailyFortune,
    this.isDailyLoading = false,
    this.dailyError,
    this.compatibilityResult,
    this.isCompatibilityLoading = false,
    this.compatibilityError,
    this.monthlyPreviews = const [],
  });

  FortuneState copyWith({
    DailyFortune? dailyFortune,
    bool? isDailyLoading,
    String? dailyError,
    CompatibilityResult? compatibilityResult,
    bool? isCompatibilityLoading,
    String? compatibilityError,
    List<MonthlyFortunePreview>? monthlyPreviews,
    bool clearCompatibility = false,
    bool clearDailyError = false,
  }) {
    return FortuneState(
      dailyFortune: dailyFortune ?? this.dailyFortune,
      isDailyLoading: isDailyLoading ?? this.isDailyLoading,
      dailyError: clearDailyError ? null : (dailyError ?? this.dailyError),
      compatibilityResult: clearCompatibility ? null : (compatibilityResult ?? this.compatibilityResult),
      isCompatibilityLoading: isCompatibilityLoading ?? this.isCompatibilityLoading,
      compatibilityError: clearCompatibility ? null : (compatibilityError ?? this.compatibilityError),
      monthlyPreviews: monthlyPreviews ?? this.monthlyPreviews,
    );
  }
}

class FortuneNotifier extends StateNotifier<FortuneState> {
  FortuneNotifier() : super(const FortuneState()) {
    loadDailyFortune();
    _loadMonthlyPreviews();
  }

  DailyFortune? _cache;
  DateTime? _cacheDate;

  Future<void> loadDailyFortune({bool forceRefresh = false}) async {
    final today = DateTime.now();
    final isSameDay = _cacheDate != null &&
        _cacheDate!.year == today.year &&
        _cacheDate!.month == today.month &&
        _cacheDate!.day == today.day;

    if (!forceRefresh && isSameDay && _cache != null) {
      state = state.copyWith(dailyFortune: _cache);
      return;
    }

    state = state.copyWith(isDailyLoading: true, clearDailyError: true);

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final fortune = _generateMockDailyFortune(today);
      _cache = fortune;
      _cacheDate = today;
      state = state.copyWith(
        dailyFortune: fortune,
        isDailyLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isDailyLoading: false,
        dailyError: '운세를 불러오는데 실패했습니다.',
      );
    }
  }

  Future<void> calculateCompatibility({
    required DateTime myBirthDate,
    required bool myIsMale,
    required DateTime partnerBirthDate,
    required bool partnerIsMale,
    DateTime? partnerBirthTime,
  }) async {
    state = state.copyWith(
      isCompatibilityLoading: true,
      clearCompatibility: true,
    );

    try {
      await Future.delayed(const Duration(seconds: 1));
      final result = _generateMockCompatibility(myBirthDate, partnerBirthDate);
      state = state.copyWith(
        compatibilityResult: result,
        isCompatibilityLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCompatibilityLoading: false,
        compatibilityError: '궁합 계산에 실패했습니다.',
      );
    }
  }

  void clearCompatibility() {
    state = state.copyWith(clearCompatibility: true);
  }

  void _loadMonthlyPreviews() {
    final now = DateTime.now();
    final previews = List.generate(3, (i) {
      final month = now.month + i;
      final year = now.year + (month > 12 ? 1 : 0);
      final actualMonth = month > 12 ? month - 12 : month;
      final rng = Random(actualMonth * 100 + year);
      final score = 60 + rng.nextInt(35);
      final keywords = ['변화', '성장', '안정', '도약', '인연', '재물', '건강'];
      return MonthlyFortunePreview(
        month: actualMonth,
        year: year,
        headline: _getMonthlyHeadline(score),
        score: score,
        keyword: keywords[rng.nextInt(keywords.length)],
      );
    });
    state = state.copyWith(monthlyPreviews: previews);
  }

  String _getMonthlyHeadline(int score) {
    if (score >= 85) return '최고의 한 달이 될 것입니다';
    if (score >= 70) return '활기차고 긍정적인 에너지가 흐릅니다';
    if (score >= 55) return '차분히 내실을 다지는 시기입니다';
    return '인내와 준비가 필요한 시기입니다';
  }

  DailyFortune _generateMockDailyFortune(DateTime date) {
    final rng = Random(date.day * 31 + date.month * 12);
    final overallScore = 55 + rng.nextInt(40);
    return DailyFortune(
      date: date,
      overall: _getOverallText(overallScore),
      overallScore: overallScore,
      love: FortuneCategory(
        name: '연애운',
        score: 50 + rng.nextInt(45),
        description: '마음을 솔직하게 표현하면 좋은 결과가 있을 것입니다.',
        icon: '💕',
      ),
      money: FortuneCategory(
        name: '재물운',
        score: 45 + rng.nextInt(50),
        description: '충동적인 지출을 조심하고 계획적인 소비를 추천합니다.',
        icon: '💰',
      ),
      health: FortuneCategory(
        name: '건강운',
        score: 60 + rng.nextInt(35),
        description: '규칙적인 식사와 충분한 수면이 중요한 하루입니다.',
        icon: '🌿',
      ),
      luckyTime: _getLuckyTime(rng),
      luckyColor: _getLuckyColor(rng),
      luckyNumber: '${rng.nextInt(9) + 1}',
      advice: '오늘은 새로운 시작을 두려워하지 마세요. 작은 용기가 큰 변화를 만듭니다.',
    );
  }

  String _getOverallText(int score) {
    if (score >= 85) return '오늘은 모든 일이 순조롭게 풀리는 대길(大吉)의 날입니다.';
    if (score >= 70) return '긍정적인 에너지가 넘치는 좋은 하루가 될 것입니다.';
    if (score >= 55) return '평온하고 안정적인 하루를 보내실 수 있습니다.';
    return '신중하게 행동하면 무난한 하루를 보낼 수 있습니다.';
  }

  String _getLuckyTime(Random rng) {
    final times = ['07:00~09:00', '09:00~11:00', '13:00~15:00', '15:00~17:00', '19:00~21:00'];
    return times[rng.nextInt(times.length)];
  }

  String _getLuckyColor(Random rng) {
    final colors = ['빨간색', '파란색', '초록색', '노란색', '보라색', '흰색', '주황색'];
    return colors[rng.nextInt(colors.length)];
  }

  CompatibilityResult _generateMockCompatibility(DateTime my, DateTime partner) {
    final rng = Random(my.day + partner.day * 3 + my.month * 7);
    final score = 55 + rng.nextInt(40);
    String grade;
    if (score >= 90) grade = '천생연분 ★★★★★';
    else if (score >= 80) grade = '좋은 인연 ★★★★';
    else if (score >= 70) grade = '좋은 궁합 ★★★';
    else if (score >= 60) grade = '보통 궁합 ★★';
    else grade = '노력이 필요 ★';

    return CompatibilityResult(
      score: score,
      grade: grade,
      summary: score >= 75
          ? '두 분의 기운이 서로를 보완하며 조화를 이룹니다.'
          : '서로 다른 점이 많지만 노력으로 극복할 수 있습니다.',
      loveAffinity: '${60 + rng.nextInt(35)}%',
      workAffinity: '${60 + rng.nextInt(35)}%',
      communicationStyle: ['솔직하고 직접적', '배려가 넘치는', '유머가 있는', '진지하고 깊은'][rng.nextInt(4)],
      advice: '서로의 다름을 인정하고 존중하는 자세가 관계를 더욱 풍요롭게 합니다.',
      strengths: ['감정적 유대감이 강합니다', '서로에 대한 신뢰가 높습니다'],
      cautions: ['의사소통 방식의 차이를 좁혀가세요', '가끔 오해가 생길 수 있으니 대화를 늘리세요'],
    );
  }
}

final fortuneProvider = StateNotifierProvider<FortuneNotifier, FortuneState>((ref) {
  return FortuneNotifier();
});