import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  String nomeUsuario = 'Usuário';
  File? imagemPerfil;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final ultimo = prefs.getString('ultimo_usuario');
    final nome = prefs.getString('nome_usuario');

    // usa o último usuário conhecido (nickname) como saudação
    final display = (ultimo?.trim().isNotEmpty ?? false)
        ? ultimo!.trim()
        : (nome?.trim().isNotEmpty ?? false)
            ? nome!.trim()
            : 'Usuário';

    // tentativa de avatar salvo por nome (se existir no seu fluxo)
    final caminhoImagem = prefs.getString('imagem_perfil_$display');

    setState(() {
      nomeUsuario = display;
      if (caminhoImagem != null && File(caminhoImagem).existsSync()) {
        imagemPerfil = File(caminhoImagem);
      } else {
        imagemPerfil = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNav(current: BottomTab.home),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO
              const Text(
                'Trilha Verde',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.principal_title,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 15),

              // SAUDAÇÃO
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  children: [
                    const TextSpan(text: 'Olá, ', style: TextStyle(color: AppColors.explorer, fontFamily: 'Poppins')),
                    TextSpan(
                      text: '$nomeUsuario!',
                      style: const TextStyle(
                        color: AppColors.explorer, // verde
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins'
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // TEXTO "PREPARADO..."
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Preparado para conhecer a',
                    style: TextStyle(
                      color: AppColors.preparedText, // #EBA937
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Trilha das Árvores Úteis?',
                    style: TextStyle(
                      color: AppColors.preparedText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // BOTÃO "COMO JOGAR?"
              Center(
                child: SizedBox(
                  child: AppButton(
                    label: 'COMO JOGAR?',
                    onPressed: () => Navigator.pushNamed(context, '/tutorial'),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // BALÃO + MASCOTE
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Balão à direita
                    Positioned(
                      top: 10,
                      right: 3,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: w * 0.62),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: const BoxDecoration(
                          color: AppColors.speechBg32, // #A7C957 com 32%
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            bottomLeft: Radius.zero,    // << canto inferior ESQUERDO sem raio
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,   // garante o corte no canto “quadrado”
                        child: const Text(
                          'Clique para abrir o mapa\n'
                          'e começar a aventura!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.loginBg,        // (opcional) fica mais legível no balão
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Mascote à esquerda
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Image.asset(
                        'lib/assets/img/falando.png',
                        width: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // BOTÃO "ABRIR O MAPA"
              Center(
                child: SizedBox(
                  child: AppButton(
                    label: 'ABRIR O MAPA',
                    onPressed: () => Navigator.pushNamed(context, '/mapa'),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
