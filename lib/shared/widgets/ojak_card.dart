import 'dart:ui';
import 'package:flutter/material.dart';

class OjakCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showGoldBorder;
  final double elevation;

  static const _bgColor = Color(0xFF16213E);
  static const _goldBorder = Color(0xFFFFD700);

  const OjakCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.width,
    this.height,
    this.onTap,
    this.showGoldBorder = false,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(this.borderRadius);

    Widget card = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: _bgColor.withOpacity(0.85),
            borderRadius: borderRadius,
            border: Border.all(
              color: showGoldBorder
                  ? _goldBorder.withOpacity(0.6)
                  : _goldBorder.withOpacity(0.2),
              width: showGoldBorder ? 1.5 : 1.0,
            ),
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: elevation * 4,
                      offset: Offset(0, elevation),
                    ),
                  ]
                : null,
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}