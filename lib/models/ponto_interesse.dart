// lib/models/ponto_interesse.dart
class PontoInteresse {
  final String? trilhaNome; // presente quando vem de uma listagem por trilha
  final int codigo;
  final String nome;
  final int ordem; // presente quando vem de uma listagem por trilha
  final String tipo; // 'arvore' | 'predio_historico'
  final bool ativa;
  final String? especie;
  final String? familia;
  final String? origem;
  final String? tipoOrigem;
  final String? qrcodeUrl;
  final int quantidadePerguntas;
  final double? latitude;
  final double? longitude;

  PontoInteresse({
    this.trilhaNome,
    required this.codigo,
    required this.nome,
    this.ordem = 999,
    required this.tipo,
    required this.ativa,
    this.especie,
    this.familia,
    this.origem,
    this.tipoOrigem,
    this.qrcodeUrl,
    this.quantidadePerguntas = 0,
    this.latitude,
    this.longitude,
  });

  bool get isArvore => tipo == 'arvore';
  bool get isPredioHistorico => tipo == 'predio_historico';

  // Só pontos com coordenadas aparecem no mapa — e o QR code só é lido a
  // partir do mapa. Pontos sem coordenadas não entram na contagem da trilha.
  bool get temCoordenadas => latitude != null && longitude != null;

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory PontoInteresse.fromJson(Map<String, dynamic> j) {
    return PontoInteresse(
      trilhaNome: j['trilha_nome'] as String?,
      codigo: (j['codigo'] as num).toInt(),
      nome: j['nome'] ?? '',
      ordem: (j['ordem'] as num?)?.toInt() ?? 999,
      tipo: (j['tipo'] as String?) ?? 'arvore',
      ativa: j['ativa'] == true,
      especie: j['a_especie'] as String?,
      familia: j['a_familia'] as String?,
      origem: j['a_origem'] as String?,
      tipoOrigem: j['a_tipo_origem'] as String?,
      qrcodeUrl: j['qrcode_url'] as String?,
      quantidadePerguntas: (j['quantidade_perguntas'] as num?)?.toInt() ?? 0,
      latitude: _parseDouble(j['latitude']),
      longitude: _parseDouble(j['longitude']),
    );
  }
}
