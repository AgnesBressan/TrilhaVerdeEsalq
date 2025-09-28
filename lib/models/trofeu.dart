// lib/models/trofeu.dart
class Trofeu {
  final String usuarioNickname; // pode ficar não-nulo com default ""
  final String trilhaNome;      // idem
  final int arvoreCodigo;       // default 0
  final String arvoreNome;      // default "Árvore Removida"

  Trofeu({
    required this.usuarioNickname,
    required this.trilhaNome,
    required this.arvoreCodigo,
    required this.arvoreNome,
  });

  factory Trofeu.fromJson(Map<String, dynamic> json) {
    final usuario = (json['usuario_nickname'] ?? json['nickname']) as String? ?? '';
    final trilha  = (json['trilha_nome'] ?? json['trilha']) as String? ?? '';
    final codigo  = (json['arvore_codigo'] as num?)?.toInt() ?? 0;
    final nome    = (json['arvore_nome'] as String?)?.trim();
    return Trofeu(
      usuarioNickname: usuario,
      trilhaNome: trilha,
      arvoreCodigo: codigo,
      arvoreNome: (nome != null && nome.isNotEmpty) ? nome : 'Árvore Removida',
    );
  }
}
