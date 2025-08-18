import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaPontuacao extends StatefulWidget {
  const TelaPontuacao({super.key});

  @override
  State<TelaPontuacao> createState() => _TelaPontuacaoState();
}

class _TelaPontuacaoState extends State<TelaPontuacao> {
  String nomeUsuario = 'Usuário';
  List<String> arvoresLidas = [];
  final int totalArvores = 13;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome_usuario') ?? 'Usuário';
    final chaveArvores = 'arvores_lidas_$nome';

    setState(() {
      nomeUsuario = nome;
      arvoresLidas = prefs.getStringList(chaveArvores) ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalLidas = arvoresLidas.length;
    final double percentual = totalLidas / totalArvores;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF90E0D4),
        elevation: 0,
        toolbarHeight: 100,
        title: Image.asset('lib/assets/img/logo.png', height: 50),
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[200],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Pontuação de $nomeUsuario',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),

            CircularPercentIndicator(
              radius: 100,
              lineWidth: 20,
              percent: percentual.clamp(0.0, 1.0),
              progressColor: Colors.teal,
              backgroundColor: Colors.redAccent,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$totalLidas/$totalArvores',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Árvores\nobservadas',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: arvoresLidas.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                return _buildTrofeu(arvoresLidas[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrofeu(String titulo) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_events, size: 48),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
