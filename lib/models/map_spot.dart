// lib/models/map_spot.dart
import 'package:flutter/material.dart';
import 'arvore.dart';

class MapSpot {
  final int codigo; 
  final String titulo;
  final Offset pos; 
  final int variant; 
  final bool enabled; 
  final int ordem;

  const MapSpot({
    required this.codigo,
    required this.titulo,
    required this.pos,
    this.variant = 1,
    this.enabled = true,
    required this.ordem,
  });

  factory MapSpot.fromArvore(Arvore arvore) {
    final posX = arvore.posX ?? 0.0; 
    final posY = arvore.posY ?? 0.0;
    
    final isEnabled = arvore.ativa; 
    final variant = arvore.codigo % 3 + 1; 

    return MapSpot(
      codigo: arvore.codigo,
      titulo: arvore.nome,
      pos: Offset(posX, posY), 
      variant: variant,
      enabled: isEnabled,
      ordem: arvore.ordem, // <-- Mapeia o campo ordem
    );
  }
}