import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/trofeu.dart';
import '../models/usuario.dart';
import '../services/api_cliente.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/donut_progress.dart';

class TelaPontuacao extends StatefulWidget {
  const TelaPontuacao({super.key});

  @override
  State<TelaPontuacao> createState() => _TelaPontuacaoState();
}

class _TelaPontuacaoState extends State<TelaPontuacao> {
  final _api = ApiClient();

  bool _isLoading = true;
  Usuario? _usuario;
  List<Trofeu> _trofeusDaTrilha = []; // só troféus da trilha selecionada
  int _totalArvoresDaTrilha = 0;
  String? _trilhaSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('ultimo_usuario');
      final trilha = prefs.getString('trilha_selecionada');

      setState(() => _trilhaSelecionada = trilha);

      if (nickname == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Se não há trilha selecionada, carrega só os dados do usuário
      if (trilha == null || trilha.isEmpty) {
        final usuario = await _api.obterUsuario(nickname);
        if (!mounted) return;
        setState(() {
          _usuario = usuario;
          _trofeusDaTrilha = [];
          _totalArvoresDaTrilha = 0;
        });
        return;
      }

      // Busca árvores da trilha, todos os troféus e dados do usuário em paralelo
      final resultados = await Future.wait([
        _api.listarArvores(trilha: trilha, ativas: true),
        _api.listarTrofeus(nickname),
        _api.obterUsuario(nickname),
      ]);

      final arvoresDaTrilha = resultados[0] as List;
      final todosTrofeus = resultados[1] as List<Trofeu>;
      final usuario = resultados[2] as Usuario?;

      // Filtra troféus apenas da trilha selecionada
      final trofeusDaTrilha = todosTrofeus
          .where((t) => t.trilhaNome == trilha)
          .toList();

      if (!mounted) return;
      setState(() {
        _usuario = usuario;
        _trofeusDaTrilha = trofeusDaTrilha;
        _totalArvoresDaTrilha = arvoresDaTrilha.length;
      });
    } catch (e) {
      debugPrint('Erro ao carregar pontuação: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lidas = _trofeusDaTrilha.length;
    final total = _totalArvoresDaTrilha;
    final percent = total > 0
        ? (lidas / total).clamp(0.0, 1.0)
        : 0.0;
    final semTrilha =
        _trilhaSelecionada == null || _trilhaSelecionada!.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNav(current: BottomTab.pontuacao),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Título ──────────────────────────────────
                    const Text(
                      'Pontuação',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppColors.principal_title,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Badge da trilha selecionada ─────────────
                    if (!semTrilha)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.speechBg32,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.route,
                                size: 15, color: AppColors.loginBg),
                            const SizedBox(width: 6),
                            Text(
                              _trilhaSelecionada!,
                              style: const TextStyle(
                                color: AppColors.loginBg,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (semTrilha)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Nenhuma trilha selecionada. '
                                'Vá à tela principal e escolha uma.',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 48),

                    // ── Donut de progresso ──────────────────────
                    Center(
                      child: DonutProgress(
                        percent: percent,
                        size: 200,
                        strokeWidth: 24,
                        progressColor: AppColors.loginBg,
                        remainderColor: AppColors.buttonBg,
                        gapDegrees: 26,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              semTrilha ? '-' : '$lidas/$total',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Árvores\nobservadas',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 13, height: 1.1),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Troféus da trilha ───────────────────────
                    if (!semTrilha) ...[
                      Text(
                        'Troféus conquistados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (_trofeusDaTrilha.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _trofeusDaTrilha.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (context, index) {
                          final titulo =
                              _trofeusDaTrilha[index].arvoreNome;
                          return _BadgeItem(title: titulo);
                        },
                      )
                    else if (!semTrilha)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Você ainda não observou nenhuma árvore\nnesta trilha.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
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
        const Icon(Icons.emoji_events_rounded,
            size: 40, color: AppColors.preparedText),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}