import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShimmerShape shape;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = ShimmerShape.rectangle,
  });

  const ShimmerLoading.circle({
    Key? key,
    required double size,
  }) : this(
          key: key,
          width: size,
          height: size,
          borderRadius: size / 2,
          shape: ShimmerShape.circle,
        );

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

enum ShimmerShape { rectangle, circle }

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const _baseColor = Color(0xFF1E2A4A);
  static const _highlightColor = Color(0xFF2A3A5A);
  static const _shimmerColor = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.shape == ShimmerShape.circle
                ? BorderRadius.circular(widget.width / 2)
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                _baseColor,
                _highlightColor,
                _shimmerColor.withOpacity(0.08),
                _highlightColor,
                _baseColor,
              ],
              stops: [
                0.0,
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;
  final int lineCount;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 120,
    this.lineCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: double.infinity, height: 16, borderRadius: 4),
          const SizedBox(height: 10),
          for (int i = 0; i < lineCount - 1; i++) ...[
            ShimmerLoading(
              width: i == lineCount - 2 ? 140 : double.infinity,
              height: 12,
              borderRadius: 4,
            ),
            if (i < lineCount - 2) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class ShimmerListView extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ShimmerListView({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 100,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i < itemCount - 1 ? spacing : 0),
          child: ShimmerCard(height: itemHeight),
        ),
      ),
    );
  }
}