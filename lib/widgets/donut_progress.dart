import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutProgress extends StatelessWidget {
  final double percent;       // 0..1
  final double size;
  final double strokeWidth;
  final double gapDegrees;    // abertura entre arcos
  final Color progressColor;
  final Color remainderColor;
  final Widget? center;

  const DonutProgress({
    super.key,
    required this.percent,
    required this.size,
    required this.strokeWidth,
    required this.progressColor,
    required this.remainderColor,
    this.gapDegrees = 22,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          percent: percent.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          gapRadians: gapDegrees * math.pi / 180.0,
          progress: progressColor,
          remainder: remainderColor,
        ),
        child: Center(child: center),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double percent;
  final double strokeWidth;
  final double gapRadians;
  final Color progress;
  final Color remainder;

  _DonutPainter({
    required this.percent,
    required this.strokeWidth,
    required this.gapRadians,
    required this.progress,
    required this.remainder,
  });

  static const double _eps = 1e-4;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final pPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = progress;

    final rPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = remainder;

    // casos extremos (sem gap)
    if (percent <= _eps) {
      canvas.drawCircle(center, radius, rPaint);
      return;
    }
    if (percent >= 1.0 - _eps) {
      canvas.drawCircle(center, radius, pPaint);
      return;
    }

    // intermediário: cresce ANTI-HORÁRIO (sweep negativo)
    final total = 2 * math.pi;
    final available = total - gapRadians;
    final progSweep = -(available * percent);        // negativo = anti-horário
    final remSweep  = -(available * (1 - percent));  // negativo = anti-horário

    double start = -math.pi / 2; // topo
    canvas.drawArc(rect, start, progSweep, false, pPaint);

    // anda mais no sentido anti-horário (negativo) e aplica o gap
    start += progSweep - gapRadians;
    canvas.drawArc(rect, start, remSweep, false, rPaint);
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.percent != percent ||
      old.strokeWidth != strokeWidth ||
      old.gapRadians != gapRadians ||
      old.progress != progress ||
      old.remainder != remainder;
}
