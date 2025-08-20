// lib/screens/tela_pontuacao.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/donut_progress.dart';

class TelaPontuacao extends StatefulWidget {
  const TelaPontuacao({super.key});

  @override
  State<TelaPontuacao> createState() => _TelaPontuacaoState();
}

class _TelaPontuacaoState extends State<TelaPontuacao> {
  List<String> arvoresLidas = [];
  final int totalArvores = 13; // ajuste se seu total mudar
  String _prefsKey = 'arvores_lidas_Usuário';

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome_usuario') ?? 'Usuário';
    _prefsKey = 'arvores_lidas_$nome';
    setState(() {
      arvoresLidas = prefs.getStringList(_prefsKey) ?? [];
    });
  }

  // ---------- utilitários de debug ----------
  Future<void> _seedProgress(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final capped = count.clamp(0, totalArvores);
    final list = List.generate(capped, (i) => 'Árvore ${i + 1}');
    await prefs.setStringList(_prefsKey, list);
    setState(() => arvoresLidas = list);
  }

  Future<void> _clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    setState(() => arvoresLidas = []);
  }

  void _showDebugSheet() {
    if (!kDebugMode) return; // só no debug
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Debug de Pontuação',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => _seedProgress(3),
                  child: const Text('+3'),
                ),
                ElevatedButton(
                  onPressed: () => _seedProgress(10),
                  child: const Text('+10'),
                ),
                ElevatedButton(
                  onPressed: () => _seedProgress(totalArvores),
                  child: const Text('Preencher tudo'),
                ),
                OutlinedButton(
                  onPressed: _clearProgress,
                  child: const Text('Limpar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    final lidas = arvoresLidas.length;
    final percent = (lidas / totalArvores).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNav(current: BottomTab.pontuacao),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: _showDebugSheet, // segure no título para ver o menu
                child: const Text(
                  'Pontuação',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.principal_title,
                    height: 1.05,
                  ),
                ),
              ),
              const SizedBox(height: 80),

              // Donut central
              Center(
                child: DonutProgress(
                  percent: percent,
                  size: 200,
                  strokeWidth: 24,
                  progressColor: AppColors.loginBg,   // verde
                  remainderColor: AppColors.buttonBg, // marrom
                  gapDegrees: 26,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$lidas/$totalArvores',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Árvores\nobservadas',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, height: 1.1),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Grid de badges / troféus (3 colunas)
              if (arvoresLidas.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: arvoresLidas.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final titulo = arvoresLidas[index];
                    return _BadgeItem(title: titulo);
                  },
                )
              else
                const Center(
                  child: Text(
                    'Você ainda não observou nenhuma árvore.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String title;
  const _BadgeItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.emoji_events_rounded,
            size: 40, color: AppColors.preparedText),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
