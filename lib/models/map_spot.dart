import 'package:flutter/material.dart';

/// Ponto clicável no mapa (coordenadas normalizadas 0..1 em relação à imagem).
class MapSpot {
  final String id;          // ex.: "arvore_3"
  final String titulo;      // ex.: "Árvore 3"
  final Offset pos;         // ex.: Offset(0.42, 0.68)
  final double hit;         // raio default do clique (px da imagem)

  const MapSpot({
    required this.id,
    required this.titulo,
    required this.pos,
    this.hit = 26,
  });
}
