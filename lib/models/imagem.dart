// lib/models/imagem.dart
class Imagem {
  final int pontoInteresseCodigo;
  final String url;
  final String? legenda;
  final String? fonte;

  Imagem({
    required this.pontoInteresseCodigo,
    required this.url,
    this.legenda,
    this.fonte,
  });

  factory Imagem.fromJson(Map<String, dynamic> j) => Imagem(
        pontoInteresseCodigo: (j['ponto_interesse_codigo'] as num).toInt(),
        url: j['url'] as String? ?? '',
        legenda: j['legenda'] as String?,
        fonte: j['fonte'] as String?,
      );
}
