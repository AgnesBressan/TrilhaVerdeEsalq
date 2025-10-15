// lib/screens/tela_pontuacao.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Nossas importações
import '../models/trofeu.dart';
import '../models/usuario.dart'; // <-- IMPORTANTE: Importar o modelo Usuario
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

  // Estado da tela
  bool _isLoading = true;
  Usuario? _usuario; // <-- NOVO: Armazena os dados do usuário
  List<Trofeu> trofeus = [];
  int totalArvores = 0;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('ultimo_usuario');
      final String trilhaPadrao = 'Árvores Úteis'; // Use a trilha correta

      if (nickname == null) {
        setState(() => _isLoading = false);
        return;
      }

      // NOVO: Busca todas as árvores ATIVAS para obter a contagem total correta
      final arvoreListAtivas = await _api.listarArvores(
        trilha: trilhaPadrao, 
        ativas: true,
      );

      // ALTERADO: Busca troféus e dados do usuário em paralelo
      final resultados = await Future.wait([
        _api.listarTrofeus(nickname),
        _api.obterUsuario(nickname),
      ]);

      if (!mounted) return;
      setState(() {
        trofeus = resultados[0] as List<Trofeu>;
        totalArvores = arvoreListAtivas.length; // <--- USAMOS O TAMANHO DA LISTA ATIVA!
        _usuario = resultados[1] as Usuario?;
      });
    } catch (e) {
      // ... (tratamento de erro)
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showDebugSheet() {
    if (!kDebugMode) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funções de debug precisam ser adaptadas para o backend.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ALTERADO: Usa a contagem de árvores do objeto Usuario, com fallback para o tamanho da lista
    final lidas = _usuario?.numArvoresVisitadas ?? trofeus.length;
    final percent = (totalArvores > 0) ? (lidas / totalArvores).clamp(0.0, 1.0) : 0.0;

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
                    GestureDetector(
                      onLongPress: _showDebugSheet,
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
                    if (trofeus.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: trofeus.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (context, index) {
                          // ALTERADO: Usa o nome da árvore (arvoreNome) para uma melhor UX
                          final titulo = trofeus[index].arvoreNome;
                          return _BadgeItem(title: titulo);
                        },
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            'Você ainda não observou nenhuma árvore.',
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
        const Icon(Icons.emoji_events_rounded, size: 40, color: AppColors.preparedText),
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