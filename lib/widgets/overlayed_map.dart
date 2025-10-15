import 'package:flutter/material.dart';
import '../models/map_spot.dart';

class OverlayedMap extends StatelessWidget {
  final int? activeId; 
  final Size baseSize; 
  final List<MapSpot> spots;
  final void Function(MapSpot)? onSpotTap;
  final int arvoresVisitadas;
  
  static const String baseAsset = 'lib/assets/img/mapa_cru.jpg';

  const OverlayedMap({
    super.key,
    required this.baseSize,
    required this.spots,
    this.activeId,
    this.onSpotTap,
    required this.arvoresVisitadas,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final w = c.maxWidth;
      final aspect = baseSize.width / baseSize.height;
      final h = w / aspect;

      return SizedBox(
        width: w,
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // fundo (mapa)
            Positioned.fill(
              child: Image.asset(baseAsset, fit: BoxFit.cover),
            ),

            ...spots.map((s) {
              final px = s.pos.dx * w;
              final py = s.pos.dy * h;
              const icon = 28.0;

              return Positioned(
                left: px - icon / 2,
                top: py - icon / 2,
                child: GestureDetector(
                  onTap: () => onSpotTap?.call(s),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (s.codigo == activeId) 
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2.5,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      Image.asset(_treeIconFor(s),
                          width: icon, height: icon),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }


  String _treeIconFor(MapSpot s) {
      final proximaOrdem = arvoresVisitadas + 1;
      
      final isVisited = s.ordem <= arvoresVisitadas; 
      
      final isNextFocus = s.ordem == proximaOrdem;         
      
      final variant = s.variant % 3 + 1;
      const baseDir = 'lib/assets/img';

      if (isVisited || isNextFocus) {
        return '$baseDir/arvore_${variant}.png'; 
      } 
      
      return '$baseDir/arvore_${variant}_cinza.png'; 
  }
}