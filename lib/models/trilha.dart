class Trilha {
  final String nome;
  final int quantidadePontosInteresse; // combina com sua tabela

  Trilha({required this.nome, required this.quantidadePontosInteresse});

  factory Trilha.fromJson(Map<String, dynamic> j) => Trilha(
        nome: j['nome'] as String,
        quantidadePontosInteresse:
            (j['quantidade_pontos_interesse'] as num?)?.toInt() ?? 0,
      );
}
