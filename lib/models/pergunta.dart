// lib/models/pergunta.dart

class Pergunta {
  final int id;
  final String trilhaNome;
  final int arvoreCodigo;
  final String? enunciado;
  final String? itemA;
  final String? itemB;
  final String? itemC;
  final String? itemD;
  final String? itemE;
  final String? texto;
  final String? audioUrl;
  final String respostaCorreta; // <-- Nome corrigido para camelCase
  final String? dica;
  final String? audioDicaUrl;  // <-- Nome corrigido para camelCase

  Pergunta({
    required this.id,
    required this.trilhaNome,
    required this.arvoreCodigo,
    this.enunciado,
    this.itemA,
    this.itemB,
    this.itemC,
    this.itemD,
    this.itemE,
    this.texto,
    this.audioUrl,
    required this.respostaCorreta, // <-- Nome corrigido
    this.dica,
    this.audioDicaUrl,            // <-- Nome corrigido
  });

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id'],
      trilhaNome: json['trilha_nome'],
      arvoreCodigo: json['arvore_codigo'],
      enunciado: json['enunciado'],
      itemA: json['item_a'],
      itemB: json['item_b'],
      itemC: json['item_c'],
      itemD: json['item_d'],
      itemE: json['item_e'],
      texto: json['texto'],
      audioUrl: json['audio_url'],
      respostaCorreta: json['resposta_correta'], // Lê do JSON
      dica: json['dica'],
      audioDicaUrl: json['audio_dica_url'],      // Lê do JSON
    );
  }
}