import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FiveElementsChart extends StatefulWidget {
  final Map<String, double> elements;
  final double size;

  const FiveElementsChart({
    super.key,
    required this.elements,
    this.size = 260,
  });

  @override
  State<FiveElementsChart> createState() => _FiveElementsChartState();
}

class _FiveElementsChartState extends State<FiveElementsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const _elementOrder = ['목', '화', '토', '금', '수'];
  static const _elementColors = {
    '목': Color(0xFF4CAF50),
    '화': Color(0xFFE53935),
    '토': Color(0xFFFF9800),
    '금': Color(0xFFB0BEC5),
    '수': Color(0xFF1E88E5),
  };
  static const _elementHanja = {
    '목': '木',
    '화': '火',
    '토': '土',
    '금': '金',
    '수': '水',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<RadarDataSet> _buildDataSets(double t) {
    final values = _elementOrder
        .map((e) => widget.elements[e] ?? 0.0)
        .toList();

    return [
      RadarDataSet(
        fillColor: const Color(0xFFE8B84B).withOpacity(0.2 * t),
        borderColor: const Color(0xFFE8B84B).withOpacity(t),
        borderWidth: 2,
        entryRadius: 4,
        dataEntries: values
            .map((v) => RadarEntry(value: v * t))
            .toList(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: RadarChart(
            RadarChartData(
              dataSets: _buildDataSets(_animation.value),
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(color: Colors.white12, width: 1),
              gridBorderData: const BorderSide(color: Colors.white12, width: 0.5),
              tickBorderData: const BorderSide(color: Colors.transparent),
              ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
              tickCount: 5,
              getTitle: (index, angle) {
                final key = _elementOrder[index];
                final color = _elementColors[key] ?? Colors.white;
                final hanja = _elementHanja[key] ?? '';
                return RadarChartTitle(
                  text: '$hanja\n$key',
                  angle: 0,
                  positionPercentageOffset: 0.15,
                );
              },
              titleTextStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              titlePositionPercentageOffset: 0.2,
            ),
          ),
        );
      },
    );
  }
}

class FiveElementsBarChart extends StatelessWidget {
  final Map<String, double> elements;

  const FiveElementsBarChart({super.key, required this.elements});

  static const _elementOrder = ['목', '화', '토', '금', '수'];
  static const _elementColors = {
    '목': Color(0xFF4CAF50),
    '화': Color(0xFFE53935),
    '토': Color(0xFFFF9800),
    '금': Color(0xFFB0BEC5),
    '수': Color(0xFF1E88E5),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _elementOrder.map((key) {
        final value = elements[key] ?? 0.0;
        final color = _elementColors[key] ?? Colors.white;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(key,
                    style: TextStyle(color: color, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 800),
                  builder: (_, v, __) {
                    return LinearProgressIndicator(
                      value: v,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}