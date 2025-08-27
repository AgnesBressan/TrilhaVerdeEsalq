import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class TelaQuiz extends StatefulWidget {
  const TelaQuiz({super.key});

  @override
  State<TelaQuiz> createState() => _TelaQuizState();
}

class _TelaQuizState extends State<TelaQuiz> {
  final String pergunta = 'Pergunta';
  final String _corretaKey = 'A';
  static const int totalArvores = 13;

  late final List<_Opcao> _opcoes;

  @override
  void initState() {
    super.initState();
    final list = <_Opcao>[
      _Opcao(key: 'A', titulo: 'Item A', color: const Color(0xFF4F6F52)),
      _Opcao(key: 'B', titulo: 'Item B', color: const Color(0xFFA7C957)),
      _Opcao(key: 'C', titulo: 'Item C', color: const Color(0xFFEBA937)),
      _Opcao(key: 'D', titulo: 'Item E', color: const Color(0xFFA35E2D)),
      _Opcao(key: 'E', titulo: 'Item D', color: const Color(0xFF8B5E3C)),
    ]..shuffle(Random());
    _opcoes = list;
  }

  /// Salva +1 árvore lida e retorna o novo total salvo.
  Future<int> _registrarAcerto() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome_usuario') ?? 'Usuário';
    final key  = 'arvores_lidas_$nome';

    final lidas = prefs.getStringList(key) ?? <String>[];
    if (lidas.length < totalArvores) {
      lidas.add('Árvore ${lidas.length + 1}');
      await prefs.setStringList(key, lidas);
    }
    return (prefs.getStringList(key) ?? <String>[]).length;
  }

  void _onTapOpcao(_Opcao op) async {
    final acertou = op.key == _corretaKey;
    if (acertou) {
      final novoTotal = await _registrarAcerto();
      if (!mounted) return;

      if (novoTotal >= totalArvores) {
        Navigator.pushReplacementNamed(context, '/ganhou');
      } else {
        Navigator.pushReplacementNamed(context, '/acertou');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/errou');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // nuvens
            Positioned(top: 40, left: 24,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 96)),
            Positioned(top: 72, right: 32,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 72)),
            Positioned(top: size.height * 0.30, left: 36,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 68)),
            Positioned(top: size.height * 0.40, right: 36,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 110)),
            Positioned(bottom: 90, left: 26,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 60)),
            Positioned(bottom: 70, right: 30,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 64)),

            // painel central
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5DAC3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                pergunta,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Color(0xFF827B6D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            for (final op in _opcoes) ...[
                              _OpcaoTile(
                                titulo: op.titulo,
                                textColor: op.color,
                                bgColor: op.color.withOpacity(0.37),
                                onTap: () => _onTapOpcao(op),
                              ),
                              const SizedBox(height: 14),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Opcao {
  final String key;
  final String titulo;
  final Color color;
  const _Opcao({required this.key, required this.titulo, required this.color});
}

class _OpcaoTile extends StatelessWidget {
  final String titulo;
  final Color textColor;
  final Color bgColor;
  final VoidCallback onTap;
  const _OpcaoTile({
    required this.titulo,
    required this.textColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            titulo,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
