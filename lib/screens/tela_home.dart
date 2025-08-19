import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/home_action_button.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        top: true,
        bottom: false, // painel encosta no fundo
        child: Stack(
          children: [
            // Mascote
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'lib/assets/img/ola.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Painel inferior (encostado nas laterais e fundo, cantos só no topo)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, 22, 24, 24 + bottom),
                decoration: const BoxDecoration(
                  color: AppColors.panelBg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        'Bem Vindo',
                        style: TextStyle(
                          color: AppColors.welcome,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Pequeno Explorador',
                        style: TextStyle(
                          color: AppColors.explorer,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botão LOGIN (largo/alto)
                    HomeActionButton(
                      label: 'LOGIN',
                      background: AppColors.loginBg,
                      textColor: Colors.black87,
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                    ),
                    const SizedBox(height: 16),

                    // Texto auxiliar alinhado à esquerda
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Não possui cadastro?',
                        style: TextStyle(
                          color: AppColors.explorer, // #4F6F52
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botão CADASTRO (largo/alto)
                    HomeActionButton(
                      label: 'CADASTRO',
                      background: AppColors.cadastroBg,
                      textColor: Colors.black87,
                      onPressed: () => Navigator.pushNamed(context, '/cadastro'),
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
