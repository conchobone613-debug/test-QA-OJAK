import 'package:flutter/material.dart';

enum OjakButtonType { primary, secondary, ghost }

class OjakButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final OjakButtonType type;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isLoading;

  const OjakButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = OjakButtonType.primary,
    this.width,
    this.height = 52,
    this.icon,
    this.isLoading = false,
  });

  factory OjakButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    double? width,
    IconData? icon,
    bool isLoading = false,
  }) =>
      OjakButton(
        key: key,
        label: label,
        onPressed: onPressed,
        type: OjakButtonType.primary,
        width: width,
        icon: icon,
        isLoading: isLoading,
      );

  factory OjakButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    double? width,
    IconData? icon,
  }) =>
      OjakButton(
        key: key,
        label: label,
        onPressed: onPressed,
        type: OjakButtonType.secondary,
        width: width,
        icon: icon,
      );

  factory OjakButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    double? width,
    IconData? icon,
  }) =>
      OjakButton(
        key: key,
        label: label,
        onPressed: onPressed,
        type: OjakButtonType.ghost,
        width: width,
        icon: icon,
      );

  @override
  State<OjakButton> createState() => _OjakButtonState();
}

class _OjakButtonState extends State<OjakButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  static const _goldStart = Color(0xFFFFD700);
  static const _goldEnd = Color(0xFFB8860B);
  static const _goldBorder = Color(0xFFFFD700);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textGold = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    switch (widget.type) {
      case OjakButtonType.primary:
        return _PrimaryButton(
          label: widget.label,
          icon: widget.icon,
          isLoading: widget.isLoading,
          width: widget.width,
          height: widget.height,
          enabled: widget.onPressed != null,
        );
      case OjakButtonType.secondary:
        return _SecondaryButton(
          label: widget.label,
          icon: widget.icon,
          width: widget.width,
          height: widget.height,
          enabled: widget.onPressed != null,
        );
      case OjakButtonType.ghost:
        return _GhostButton(
          label: widget.label,
          icon: widget.icon,
          width: widget.width,
          height: widget.height,
          enabled: widget.onPressed != null,
        );
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final bool enabled;

  static const _goldStart = Color(0xFFFFD700);
  static const _goldEnd = Color(0xFFB8860B);
  static const _textDark = Color(0xFF1A1A2E);

  const _PrimaryButton({
    required this.label,
    this.icon,
    this.isLoading = false,
    this.width,
    required this.height,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [_goldStart, _goldEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF888888), Color(0xFF555555)],
                ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _goldStart.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(_textDark),
                  ),
                )
              : _ButtonContent(label: label, icon: icon, color: _textDark),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final double? width;
  final double height;
  final bool enabled;

  static const _goldBorder = Color(0xFFFFD700);
  static const _textGold = Color(0xFFFFD700);

  const _SecondaryButton({
    required this.label,
    this.icon,
    this.width,
    required this.height,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _goldBorder,
            width: 1.5,
          ),
        ),
        child: Center(
          child: _ButtonContent(label: label, icon: icon, color: _textGold),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final double? width;
  final double height;
  final bool enabled;

  static const _textWhite = Color(0xFFE8E8E8);

  const _GhostButton({
    required this.label,
    this.icon,
    this.width,
    required this.height,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _ButtonContent(label: label, icon: icon, color: _textWhite),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const _ButtonContent({
    required this.label,
    this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}