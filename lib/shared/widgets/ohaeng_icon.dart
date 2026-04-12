import 'package:flutter/material.dart';

enum OhaengElement { wood, fire, earth, metal, water }

class OhaengIcon extends StatelessWidget {
  final OhaengElement element;
  final double size;
  final Color? color;
  final bool showLabel;
  final TextStyle? labelStyle;

  static const _elementData = {
    OhaengElement.wood: _OhaengData(
      emoji: '🌳',
      label: '목',
      koreanName: '木',
      defaultColor: Color(0xFF4CAF50),
    ),
    OhaengElement.fire: _OhaengData(
      emoji: '🔥',
      label: '화',
      koreanName: '火',
      defaultColor: Color(0xFFFF5722),
    ),
    OhaengElement.earth: _OhaengData(
      emoji: '🏔️',
      label: '토',
      koreanName: '土',
      defaultColor: Color(0xFF795548),
    ),
    OhaengElement.metal: _OhaengData(
      emoji: '⚡',
      label: '금',
      koreanName: '金',
      defaultColor: Color(0xFFFFD700),
    ),
    OhaengElement.water: _OhaengData(
      emoji: '💧',
      label: '수',
      koreanName: '水',
      defaultColor: Color(0xFF2196F3),
    ),
  };

  const OhaengIcon({
    super.key,
    required this.element,
    this.size = 32,
    this.color,
    this.showLabel = false,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final data = _elementData[element]!;
    final effectiveColor = color ?? data.defaultColor;

    if (!showLabel) {
      return _EmojiIcon(emoji: data.emoji, size: size);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EmojiIcon(emoji: data.emoji, size: size),
        const SizedBox(height: 4),
        Text(
          data.koreanName,
          style: labelStyle ??
              TextStyle(
                color: effectiveColor,
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  static Color colorOf(OhaengElement element) =>
      _elementData[element]!.defaultColor;

  static String emojiOf(OhaengElement element) =>
      _elementData[element]!.emoji;

  static String labelOf(OhaengElement element) =>
      _elementData[element]!.label;
}

class _EmojiIcon extends StatelessWidget {
  final String emoji;
  final double size;

  const _EmojiIcon({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: TextStyle(fontSize: size),
    );
  }
}

class _OhaengData {
  final String emoji;
  final String label;
  final String koreanName;
  final Color defaultColor;

  const _OhaengData({
    required this.emoji,
    required this.label,
    required this.koreanName,
    required this.defaultColor,
  });
}

class OhaengBadge extends StatelessWidget {
  final OhaengElement element;
  final double size;

  const OhaengBadge({super.key, required this.element, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = OhaengIcon.colorOf(element);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Center(
        child: OhaengIcon(element: element, size: size * 0.55),
      ),
    );
  }
}