// lib/models/arvore.dart

class Arvore {
  final String trilhaNome;
  final int codigo;
  final String nome;
  final String? especie; // String? é mais seguro que String
  final bool ativa;
  final double? posX;
  final double? posY;
  final String? fotoUrl; // Adicionado campo que faltava
  final int quantidadePerguntas; // Adicionado campo que faltava

  Arvore({
    required this.trilhaNome,
    required this.codigo,
    required this.nome,
    this.especie,
    required this.ativa,
    this.posX,
    this.posY,
    this.fotoUrl,
    this.quantidadePerguntas = 0,
  });

  // [NOVO] Esta função converte qualquer tipo de dado (String, int, double) para double.
  // É a forma mais segura de lidar com o JSON.
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // [CORRIGIDO] Agora o fromJson usa a função _parseDouble para evitar o erro.
  factory Arvore.fromJson(Map<String, dynamic> j) {
    return Arvore(
      trilhaNome: j['trilha_nome'],
      codigo: (j['codigo'] as num).toInt(),
      nome: j['nome'] ?? '',
      especie: j['especie'],
      ativa: j['ativa'] == true,
      posX: _parseDouble(j['pos_x']),
      posY: _parseDouble(j['pos_y']),
      fotoUrl: j['foto_url'],
      quantidadePerguntas: (j['quantidade_perguntas'] as num?)?.toInt() ?? 0,
    );
  }
}