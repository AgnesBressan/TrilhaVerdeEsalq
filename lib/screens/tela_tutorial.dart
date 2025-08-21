// lib/screens/tela_tutorial.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class TelaTutorial extends StatelessWidget {
  const TelaTutorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instruções',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.principal_title,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 15),

              // Subtítulo
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(text: 'Olá explorador, bem-vindo a\n'),
                    TextSpan(
                      text: 'Trilha Verde',
                      style: TextStyle(
                        color: AppColors.explorer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Aqui você vai se divertir aprendendo sobre a natureza. Veja como jogar:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.preparedText, // laranja
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Painel de instruções
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: BoxDecoration(
                  color: AppColors.panelBg, // E5DAC3
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TutorialStep(
                      num: 1,
                      titulo: 'Entre no mapa',
                      texto:
                          'Abra o mapa e veja o caminho que você deve seguir.',
                    ),
                    _TutorialStep(
                      num: 2,
                      titulo: 'Selecionar árvore',
                      texto:
                          'Veja qual a sua próxima árvore e clique nela para ler o QR Code.',
                    ),
                    _TutorialStep(
                      num: 3,
                      titulo: 'Ler QR Code',
                      texto:
                          'Leia o QR Code da árvore com a câmera e aprenda mais sobre ela para responder à pergunta.',
                    ),
                    _TutorialStep(
                      num: 4,
                      titulo: 'Responder a pergunta',
                      texto:
                          'Responda a pergunta; caso não acerte, ouça a dica. Caso acerte você receberá um troféu.',
                    ),
                    _TutorialStep(
                      num: 5,
                      titulo: 'Ganhe troféus',
                      texto:
                          'Visitando árvores e acertando suas perguntas você acumula troféus na área de pontuação.',
                    ),
                    _TutorialStep(
                      num: 6,
                      titulo: 'Percorra toda a trilha',
                      texto:
                          'Visite todas as árvores da trilha e ganhe o jogo.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botão VOLTAR
              Center(
                child: SizedBox(
                  width: 160,
                  child: AppButton(
                    label: 'VOLTAR',
                    onPressed: () => Navigator.pop(context),
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

class _TutorialStep extends StatelessWidget {
  final int num;
  final String titulo;
  final String texto;

  const _TutorialStep({
    required this.num,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$num. ',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    color: AppColors.principal_title,
                  ),
                ),
                TextSpan(
                  text: titulo,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    color: AppColors.principal_title,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
