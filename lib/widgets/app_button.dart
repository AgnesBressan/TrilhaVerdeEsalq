import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? width;
  final double? height;
  final bool haptics;               // vibração leve
  final double pressedScale;        // escala quando pressionado
  final Duration animDuration;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    this.radius = 20,
    this.width,
    this.height,
    this.haptics = true,
    this.pressedScale = 0.96,
    this.animDuration = const Duration(milliseconds: 90),
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: widget.onPressed == null
          ? null
          : () {
              if (widget.haptics) HapticFeedback.lightImpact();
              widget.onPressed!();
            },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          final base = AppColors.buttonBg;
          return states.contains(MaterialState.pressed)
              ? base.withOpacity(0.92)
              : base;
        }),
        elevation: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.pressed) ? 1 : 4),
        shadowColor:
            const MaterialStatePropertyAll(Colors.black54),
        padding: MaterialStatePropertyAll(widget.padding),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
        overlayColor:
            MaterialStatePropertyAll(Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        widget.label,
        style: const TextStyle(
          color: AppColors.buttonText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );

    final scaledBtn = AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1.0,
      duration: widget.animDuration,
      curve: Curves.easeOut,
      child: btn,
    );

    final wrapped = Listener(
      // não interfere no onPressed do ElevatedButton
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: scaledBtn,
    );

    if (widget.width != null || widget.height != null) {
      return SizedBox(width: widget.width, height: widget.height, child: wrapped);
    }
    return wrapped;
  }
}
