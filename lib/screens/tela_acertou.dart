// lib/telas/tela_acertou.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class TelaAcertou extends StatefulWidget {
  const TelaAcertou({super.key});

  @override
  State<TelaAcertou> createState() => _TelaAcertouState();
}

class _TelaAcertouState extends State<TelaAcertou> {
  bool _finalizouTrilha = false;
  bool _handledArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledArgs) return;
    _handledArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    // O argumento 'finalizou' é apenas informativo agora. A navegação para /ganhou
    // é feita diretamente pela TelaQuiz.
    if (args is Map && args['finalizou'] == true) {
      _finalizouTrilha = true;
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
            // ===================== NUVENS =====================
            Positioned(
              top: 40,
              left: 200,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 96),
            ),
            Positioned(
              top: size.height * 0.30,
              left: 36,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 68),
            ),
            Positioned(
              top: size.height * 0.40,
              right: 36,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 110),
            ),
            Positioned(
              bottom: 200,
              left: 26,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 60),
            ),
            Positioned(
              bottom: 70,
              right: 30,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 64),
            ),
            Positioned(
              bottom: 20,
              left: 80,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 100),
            ),

            // ===================== CONTEÚDO =====================
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'VOCÊ ACERTOU,\nPARABÉNS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.explorer, // verde do app
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // mascote polegar
                    Image.asset(
                      'lib/assets/img/acertou.png',
                      width: 190,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 26),

                    // botões (sem _finalizouTrilha, pois a navegação já ocorreu)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          child: AppButton(
                            label: 'IR AO MAPA',
                            onPressed: () => Navigator.pushReplacementNamed(context, '/mapa'),
                          ),
                        ),
                        SizedBox(
                          child: AppButton(
                            label: 'PONTUAÇÃO',
                            onPressed: () => Navigator.pushReplacementNamed(context, '/pontuacao'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}