// lib/models/pergunta.dart

class Pergunta {
  final int id;
  final int pontoInteresseCodigo;
  final String? enunciado;
  final String? itemA;
  final String? itemB;
  final String? itemC;
  final String? itemD;
  final String? texto;
  final String? audioUrl;
  final String respostaCorreta;
  final String? dica;
  final String? audioDicaUrl;

  Pergunta({
    required this.id,
    required this.pontoInteresseCodigo,
    this.enunciado,
    this.itemA,
    this.itemB,
    this.itemC,
    this.itemD,
    this.texto,
    this.audioUrl,
    required this.respostaCorreta,
    this.dica,
    this.audioDicaUrl,
  });

  factory Pergunta.fromJson(Map<String, dynamic> json) {
    return Pergunta(
      id: json['id'],
      pontoInteresseCodigo: json['ponto_interesse_codigo'],
      enunciado: json['enunciado'],
      itemA: json['item_a'],
      itemB: json['item_b'],
      itemC: json['item_c'],
      itemD: json['item_d'],
      texto: json['texto'],
      audioUrl: json['audio_url'],
      respostaCorreta: json['resposta_correta'],
      dica: json['dica'],
      audioDicaUrl: json['audio_dica_url'],
    );
  }
}
