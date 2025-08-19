import 'package:flutter/material.dart';

class HomeActionButton extends StatefulWidget {
  final String label;
  final Color background;
  final Color textColor;
  final VoidCallback onPressed;
  final double height;

  const HomeActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
    required this.onPressed,
    this.height = 56,
  });

  @override
  State<HomeActionButton> createState() => _HomeActionButtonState();
}

class _HomeActionButtonState extends State<HomeActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.background,
        elevation: _pressed ? 0 : 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: widget.textColor,
        overlayColor: Colors.black.withOpacity(0.06),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        widget.label,
        style: TextStyle(
          color: widget.textColor,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
    );

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 90),
          scale: _pressed ? 0.97 : 1.0,
          child: btn,
        ),
      ),
    );
  }
}
