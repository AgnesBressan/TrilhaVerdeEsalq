// lib/models/usuario.dart

class Usuario {
  final String nickname;
  final String nome;
  final int? idade;
  final String? anoEscolar;
  final int numPontosVisitados;
  final String? fotoMime;

  Usuario({
    required this.nickname,
    required this.nome,
    this.idade,
    this.anoEscolar,
    required this.numPontosVisitados,
    this.fotoMime,
  });

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        nickname: j['nickname'] as String,
        nome: j['nome'] as String? ?? '',
        idade: j['idade'] as int?,
        anoEscolar: j['ano_escolar'] as String?,
        numPontosVisitados: (j['num_pontos_visitados'] as int?) ?? 0,
        fotoMime: j['foto_mime'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'nome': nome,
        if (idade != null) 'idade': idade,
        if (anoEscolar != null) 'ano_escolar': anoEscolar,
        'num_pontos_visitados': numPontosVisitados,
        if (fotoMime != null) 'foto_mime': fotoMime,
      };


  Usuario copyWith({
    String? nome,
    int? idade,
    String? anoEscolar,
    int? numPontosVisitados,
    String? fotoMime,
  }) {
    return Usuario(
      nickname: nickname,
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
      anoEscolar: anoEscolar ?? this.anoEscolar,
      numPontosVisitados: numPontosVisitados ?? this.numPontosVisitados,
      fotoMime: fotoMime ?? this.fotoMime,
    );
  }
}
