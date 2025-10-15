import 'dart:math' as math;
import 'package:flutter/material.dart';

// Classe principal (mantém o nome DonutProgress para não quebrar a TelaPontuacao)
class DonutProgress extends StatelessWidget {
  final double percent;       // 0..1
  final double size;
  final double strokeWidth;
  final double gapDegrees;    // Não será mais usado, mas mantido para compatibilidade
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
    this.gapDegrees = 26,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos um novo painter simples e mais robusto
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadialPainter(
          percent: percent.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          progressColor: progressColor,
          remainderColor: remainderColor,
        ),
        child: Center(child: center),
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double percent;
  final double strokeWidth;
  final Color progressColor;
  final Color remainderColor;

  _RadialPainter({
    required this.percent,
    required this.strokeWidth,
    required this.progressColor,
    required this.remainderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerOffset = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: centerOffset, radius: radius);

    // Pintura para o fundo (remainderColor - Marrom)
    final remainderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round // Usamos round para uma aparência moderna
      ..color = remainderColor;

    // Pintura para o progresso (progressColor - Verde)
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = progressColor;

    // Pintura para a saliência (Ponta Verde) - Cor mais clara para destaque
    final capPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = progressColor; // Cor do progresso

    // 1. Desenha o círculo de fundo (Marrom)
    // Usamos um Sweep de 2 * math.pi para cobrir quase o círculo todo (elimina o gap)
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, remainderPaint);

    // 2. Desenha o arco de progresso (Verde)
    // O arco cresce HORÁRIO (sweep positivo)
    final progSweepAngle = 2 * math.pi * percent;
    final startAngle = -math.pi / 2; // Começa no topo (12 horas)

    canvas.drawArc(rect, startAngle, progSweepAngle, false, progressPaint);

    // 3. Desenha a saliência na ponta final do progresso (Verde)
    if (percent > 0.0) {
      // Calcula o ângulo final
      final endProgAngle = startAngle + progSweepAngle;

      // Converte o ângulo final para coordenadas cartesianas para posicionar o círculo
      final capX = centerOffset.dx + radius * math.cos(endProgAngle);
      final capY = centerOffset.dy + radius * math.sin(endProgAngle);
      
      // Desenha o círculo na ponta final
      canvas.drawCircle(Offset(capX, capY), strokeWidth / 2, capPaint);
    }
  }

  @override
  bool shouldRepaint(_RadialPainter old) =>
      old.percent != percent ||
      old.strokeWidth != strokeWidth ||
      old.progressColor != progressColor ||
      old.remainderColor != remainderColor;
}