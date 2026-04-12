import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double blurX;
  final double blurY;
  final Color backgroundColor;
  final double backgroundOpacity;
  final Color borderColor;
  final double borderOpacity;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  static const _defaultBg = Color(0xFF16213E);
  static const _defaultBorder = Color(0xFFFFD700);

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.blurX = 10,
    this.blurY = 10,
    this.backgroundColor = _defaultBg,
    this.backgroundOpacity = 0.7,
    this.borderColor = _defaultBorder,
    this.borderOpacity = 0.2,
    this.borderWidth = 1.0,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
          child: Container(
            width: width,
            height: height,
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gradient == null
                  ? backgroundColor.withOpacity(backgroundOpacity)
                  : null,
              gradient: gradient,
              borderRadius: radius,
              border: Border.all(
                color: borderColor.withOpacity(borderOpacity),
                width: borderWidth,
              ),
              boxShadow: boxShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}