import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class TelaDicas extends StatelessWidget {
  const TelaDicas({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            {};
    final arvoreId = args['arvoreId'] as String? ?? 'desconhecida';
    final titulo   = args['titulo'] as String? ?? 'Árvore';
    final numero   = args['numero'] as int?;
    final qr       = args['qr'] as String?; // se quiser usar

    final nomeArvore = numero != null ? 'Árvore $numero' : titulo;

    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título “Parabéns…”
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Parabéns, ',
                      style: TextStyle(
                        color: AppColors.explorer,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                    const TextSpan(
                      text: 'você leu o qr code da seguinte árvore:',
                      style: TextStyle(
                        color: AppColors.explorer,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nome da árvore
              Text(
                nomeArvore,
                style: const TextStyle(
                  color: AppColors.preparedText, // laranja
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  height: 1.05,
                ),
              ),

              const SizedBox(height: 50),

              // BALÃO + MASCOTE (mesma base da home)
              SizedBox(
                height: 210,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 3,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: w * 0.70),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          color: AppColors.speechBg32,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.zero, // canto inf. esquerdo sem raio
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const Text(
                          'Vamos conhecer um pouco\nmais sobre a árvore?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.loginBg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Image.asset(
                        'lib/assets/img/falando.png',
                        width: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Descrição (placeholder)
              const Text(
                'Lorem ipsum is simply dummy text of the printing and typesetting industry. '
                'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, '
                'when an unknown printer took a galley of type and scrambled it to make a type specimen book. '
                'It has survived not only five centuries, but also the leap into electronic typesetting, '
                'remaining essentially unchanged.',
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: Color(0xFF4B4B4B),
                ),
              ),

              const SizedBox(height: 30),

              // Caixa de áudio (UI simples)
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.panelBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão play
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Play de áudio'),
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded,
                              color: AppColors.play),
                        ),
                      ),
                      // Waveform (imagem)
                      Image.asset(
                        'lib/assets/img/sound.png',
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botão "RESPONDER A PERGUNTA"
              Center(
                child: AppButton(
                  label: 'RESPONDER A PERGUNTA',
                  onPressed: () => Navigator.pushNamed(context, '/quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
