// lib/models/trofeu.dart
class Trofeu {
  final String usuarioNickname;
  final int pontoInteresseCodigo;
  final String pontoInteresseNome; // default "Ponto Removido"

  Trofeu({
    required this.usuarioNickname,
    required this.pontoInteresseCodigo,
    required this.pontoInteresseNome,
  });

  factory Trofeu.fromJson(Map<String, dynamic> json) {
    final usuario = (json['usuario_nickname'] ?? json['nickname']) as String? ?? '';
    final codigo = (json['ponto_interesse_codigo'] as num?)?.toInt() ?? 0;
    final nome = (json['ponto_interesse_nome'] ?? json['nome']) as String?;
    return Trofeu(
      usuarioNickname: usuario,
      pontoInteresseCodigo: codigo,
      pontoInteresseNome:
          (nome != null && nome.trim().isNotEmpty) ? nome.trim() : 'Ponto Removido',
    );
  }
}
