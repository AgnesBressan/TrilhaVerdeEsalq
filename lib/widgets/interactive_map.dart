import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trilha_verde_esalq/theme/app_colors.dart';
import '../models/map_spot.dart';

/// Mapa com zoom/pan e hotspots clicáveis.
/// Os hotspots usam raio adaptativo (para facilitar clique em pontos próximos).
/// O ANEL de destaque (activeId) agora aceita um raio FIXO em px da IMAGEM.
class InteractiveMap extends StatefulWidget {
  final String imageAsset;
  final Size imageSize; // tamanho nativo do PNG do mapa
  final List<MapSpot> spots;
  final void Function(MapSpot) onSpotTap;

  /// id do spot que deve aparecer destacado (anel)
  final String? activeId;

  /// Ajuste automático do raio (em px na IMAGEM) para cada spot (hitbox)
  final bool adaptiveHit;
  final double minHitPx;
  final double maxHitPx;
  final double hitRatio; // fração da menor distância

  /// === NOVO: tamanho fixo do ANEL (visual) em px da IMAGEM ===
  /// Se null, usa o mesmo raio dos hotspots. Recomendo 10–14.
  final double? activeRingRadiusPx;
  final double activeRingStroke;
  final Color activeRingColor;

  const InteractiveMap({
    super.key,
    required this.imageAsset,
    required this.imageSize,
    required this.spots,
    required this.onSpotTap,
    this.activeId,
    this.adaptiveHit = true,
    this.minHitPx = 18,
    this.maxHitPx = 34,
    this.hitRatio = 0.38,
    this.activeRingRadiusPx,              // <- novo (raio visual fixo)
    this.activeRingStroke = 2.5,          // <- novo (espessura do anel)
    this.activeRingColor = AppColors.principal_title, // novo
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  final _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Calcula um raio efetivo (px na imagem) para cada spot,
  // proporcional à menor distância até um vizinho (hitbox para toques).
  Map<String, double> _effectiveHits() {
    final W = widget.imageSize.width;
    final H = widget.imageSize.height;
    final out = <String, double>{};

    for (int i = 0; i < widget.spots.length; i++) {
      final si = widget.spots[i];
      final pi = Offset(si.pos.dx * W, si.pos.dy * H);

      double minD2 = double.infinity;
      for (int j = 0; j < widget.spots.length; j++) {
        if (i == j) continue;
        final sj = widget.spots[j];
        final pj = Offset(sj.pos.dx * W, sj.pos.dy * H);
        final d2 = (pi - pj).distanceSquared;
        if (d2 < minD2) minD2 = d2;
      }

      final minD = minD2.isFinite ? math.sqrt(minD2) : widget.maxHitPx * 2;
      final adaptive =
          (minD * widget.hitRatio).clamp(widget.minHitPx, widget.maxHitPx);
      out[si.id] = widget.adaptiveHit ? adaptive : si.hit;
    }
    return out;
  }

  // Debug: segure no mapa para logar coordenadas normalizadas
  void _onLongPressStart(LongPressStartDetails d) {
    if (!kDebugMode) return;
    final p = d.localPosition;
    final nx = (p.dx / widget.imageSize.width).clamp(0.0, 1.0);
    final ny = (p.dy / widget.imageSize.height).clamp(0.0, 1.0);
    debugPrint('👉 Offset(${nx.toStringAsFixed(4)}, ${ny.toStringAsFixed(4)})');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coordenada normalizada no console')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.imageSize.width;
    final h = widget.imageSize.height;
    final hits = _effectiveHits();

    return InteractiveViewer(
      minScale: 1,
      maxScale: 5,
      boundaryMargin: const EdgeInsets.all(64),
      transformationController: _controller,
      clipBehavior: Clip.none,
      child: GestureDetector(
        onLongPressStart: _onLongPressStart,
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(widget.imageAsset, fit: BoxFit.cover),
              ),

              // Áreas clicáveis (invisíveis)
              for (final s in widget.spots)
                Positioned(
                  left: s.pos.dx * w - hits[s.id]!,
                  top:  s.pos.dy * h - hits[s.id]!,
                  width: hits[s.id]! * 2,
                  height: hits[s.id]! * 2,
                  child: _SpotButton(
                    onTap: () => widget.onSpotTap(s),
                    child: Container(color: Colors.transparent),
                  ),
                ),

              // ANEL do spot ativo com raio FIXO (se fornecido)
              if (widget.activeId != null)
                ...widget.spots
                    .where((s) => s.id == widget.activeId)
                    .map((s) {
                  final r = widget.activeRingRadiusPx ?? hits[s.id]!;
                  return Positioned(
                    left: s.pos.dx * w - r,
                    top:  s.pos.dy * h - r,
                    width: r * 2,
                    height: r * 2,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.activeRingColor,
                            width: widget.activeRingStroke,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _SpotButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.circle,
        splashColor: Colors.white.withOpacity(0.08),
        highlightColor: Colors.white.withOpacity(0.05),
        child: child,
      ),
    );
  }
}
