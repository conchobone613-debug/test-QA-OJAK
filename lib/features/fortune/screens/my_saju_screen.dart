import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class MySajuScreen extends StatefulWidget {
  const MySajuScreen({super.key});

  @override
  State<MySajuScreen> createState() => _MySajuScreenState();
}

class _MySajuScreenState extends State<MySajuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _sajuPillars = [
    {'heavenly': '甲', 'earthly': '子', 'element': '목(木)', 'color': '🟢'},
    {'heavenly': '丙', 'earthly': '午', 'element': '화(火)', 'color': '🔴'},
    {'heavenly': '庚', 'earthly': '申', 'element': '금(金)', 'color': '⚪'},
    {'heavenly': '壬', 'earthly': '辰', 'element': '수(水)', 'color': '🔵'},
  ];

  final Map<String, int> _elementScores = {
    '목(木)': 70,
    '화(火)': 85,
    '토(土)': 45,
    '금(金)': 60,
    '수(水)': 75,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0533), Color(0xFF0d1b4b), Color(0xFF0a2744)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSajuTab(),
                    _buildElementTab(),
                    _buildAnalysisTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            '내 사주 원국',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Text('🀄', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF9B59B6).withOpacity(0.5),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '사주 원국'),
                Tab(text: '오행 분석'),
                Tab(text: 'AI 성격 분석'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSajuTab() {
    final pillarLabels = ['년주', '월주', '일주', '시주'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('나의 사주 8자'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) => _SajuPillarCard(
              label: pillarLabels[i],
              heavenly: _sajuPillars[i]['heavenly']!,
              earthly: _sajuPillars[i]['earthly']!,
              element: _sajuPillars[i]['element']!,
              colorEmoji: _sajuPillars[i]['color']!,
            )),
          ),
          const SizedBox(height: 24),
          _sectionTitle('십성(十星) 분석'),
          const SizedBox(height: 12),
          ..._buildTenStarItems(),
          const SizedBox(height: 24),
          _sectionTitle('용신(用神)'),
          const SizedBox(height: 12),
          _buildUsefulGodCard(),
        ],
      ),
    );
  }

  List<Widget> _buildTenStarItems() {
    final stars = [
      {'name': '비겁(比劫)', 'desc': '자아 의식이 강하고 독립적인 성향'},
      {'name': '식상(食傷)', 'desc': '창의성과 표현력이 뛰어남'},
      {'name': '재성(財星)', 'desc': '실용적이고 현실적인 감각'},
      {'name': '관성(官星)', 'desc': '책임감과 규율을 중시'},
      {'name': '인성(印星)', 'desc': '학문과 직관력이 발달'},
    ];

    return stars.map((s) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _GlassContainer(
        child: Row(
          children: [
            Container(
              width: 8,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              s['name']!,
              style: const TextStyle(color: Color(0xFFD4A8FF), fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s['desc']!,
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    )).toList();
  }

  Widget _buildUsefulGodCard() {
    return _GlassContainer(
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '화(火) · 목(木)',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '火와 木의 기운이 당신에게 가장 유리한 에너지입니다. 붉은색 계열의 옷이나 동쪽 방향이 길합니다.',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('오행 에너지 분포'),
          const SizedBox(height: 20),
          Center(child: _OhangRadarChart(scores: _elementScores)),
          const SizedBox(height: 24),
          _sectionTitle('오행 상세 분석'),
          const SizedBox(height: 12),
          ..._elementScores.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ElementBar(name: e.key, score: e.value),
          )),
          const SizedBox(height: 24),
          _sectionTitle('오행 균형 조언'),
          const SizedBox(height: 12),
          _buildElementAdvice(),
        ],
      ),
    );
  }

  Widget _buildElementAdvice() {
    return _GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '토(土) 기운 보완 필요',
                style: TextStyle(color: Color(0xFFD4A8FF), fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '현재 토(土)의 기운이 약한 편입니다. 황토색 계열의 물건을 가까이 두거나, 안정감을 주는 취미 활동을 추천합니다. 규칙적인 생활 패턴을 유지하면 오행의 균형을 찾는 데 도움이 됩니다.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    final traits = [
      {'title': '핵심 성격', 'icon': '🌟', 'content': '당신은 직관력이 뛰어나고 창의적인 사고를 가진 사람입니다. 새로운 아이디어를 제시하는 것을 즐기며, 주변 사람들에게 영감을 주는 리더십을 갖추고 있습니다.'},
      {'title': '대인관계', 'icon': '🤝', 'content': '사람들과 쉽게 어울리는 친화력을 가지고 있지만, 때로는 혼자만의 시간이 필요합니다. 깊은 관계를 소중히 여기며 신뢰를 바탕으로 한 관계를 선호합니다.'},
      {'title': '직업 적성', 'icon': '💼', 'content': '창의성을 발휘할 수 있는 분야에서 두각을 나타냅니다. 예술, 기획, 교육, IT 관련 분야가 적합하며, 자유로운 분위기에서 최고의 성과를 냅니다.'},
      {'title': '연애 스타일', 'icon': '💕', 'content': '로맨틱하고 감성적인 면이 있어 상대방을 세심하게 배려합니다. 진정성 있는 교감을 중시하며, 이상적인 파트너십을 추구합니다.'},
      {'title': '재물 운용', 'icon': '💰', 'content': '직관적인 투자 감각이 있으나 충동적인 결정을 조심해야 합니다. 장기적인 계획을 세우고 꾸준히 저축하는 습관이 재물을 키우는 데 유리합니다.'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIBadge(),
          const SizedBox(height: 20),
          ...traits.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _AnalysisCard(
              title: t['title']!,
              icon: t['icon']!,
              content: t['content']!,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAIBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9B59B6).withOpacity(0.3),
                const Color(0xFF3498DB).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 사주 성격 분석',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '사주 원국을 바탕으로 AI가 분석한 성격 리포트입니다',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SajuPillarCard extends StatelessWidget {
  final String label;
  final String heavenly;
  final String earthly;
  final String element;
  final String colorEmoji;

  const _SajuPillarCard({
    required this.label,
    required this.heavenly,
    required this.earthly,
    required this.element,
    required this.colorEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 74,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                heavenly,
                style: const TextStyle(
                  color: Color(0xFFD4A8FF),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white.withOpacity(0.2),
              ),
              Text(
                earthly,
                style: const TextStyle(
                  color: Color(0xFF85C1E9),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                colorEmoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                element,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ElementBar extends StatelessWidget {
  final String name;
  final int score;

  const _ElementBar({required this.name, required this.score});

  Color get _elementColor {
    if (name.contains('목')) return const Color(0xFF2ECC71);
    if (name.contains('화')) return const Color(0xFFE74C3C);
    if (name.contains('토')) return const Color(0xFFF39C12);
    if (name.contains('금')) return const Color(0xFFBDC3C7);
    return const Color(0xFF3498DB);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: score / 100,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: _elementColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(color: _elementColor.withOpacity(0.5), blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$score%',
                style: TextStyle(color: _elementColor, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OhangRadarChart extends StatelessWidget {
  final Map<String, int> scores;

  const _OhangRadarChart({required this.scores});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: CustomPaint(
        painter: _RadarPainter(scores: scores),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Map<String, int> scores;

  _RadarPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final keys = scores.keys.toList();
    final n = keys.length;
    final angleStep = (2 * pi) / n;

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 4; level++) {
      final r = radius * level / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = -pi / 2 + i * angleStep;
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final angle = -pi / 2 + i * angleStep;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
        gridPaint,
      );
    }

    final dataPaint = Paint()
      ..color = const Color(0xFF9B59B6).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final dataStroke = Paint()
      ..color = const Color(0xFFD4A8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dataPath = Path();
    final values = scores.values.toList();
    for (int i = 0; i < n; i++) {
      final angle = -pi / 2 + i * angleStep;
      final r = radius * values[i] / 100;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) dataPath.moveTo(x, y);
      else dataPath.lineTo(x, y);
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, dataStroke);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final angle = -pi / 2 + i * angleStep;
      final labelR = radius + 18;
      final x = center.dx + labelR * cos(angle);
      final y = center.dy + labelR * sin(angle);

      textPainter.text = TextSpan(
        text: keys[i].substring(0, 1),
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnalysisCard extends StatefulWidget {
  final String title;
  final String icon;
  final String content;

  const _AnalysisCard({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  State<_AnalysisCard> createState() => _AnalysisCardState();
}

class _AnalysisCardState extends State<_AnalysisCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _expanded
                  ? Colors.white.withOpacity(0.13)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _expanded
                    ? const Color(0xFF9B59B6).withOpacity(0.5)
                    : Colors.white.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}