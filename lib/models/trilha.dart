class Trilha {
  final String nome;
  final int quantidadeArvores; // combina com sua tabela

  Trilha({required this.nome, required this.quantidadeArvores});

  factory Trilha.fromJson(Map<String, dynamic> j) => Trilha(
        nome: j['nome'] as String,
        quantidadeArvores: (j['quantidade_arvores'] as num?)?.toInt() ?? 0,
      );
}
