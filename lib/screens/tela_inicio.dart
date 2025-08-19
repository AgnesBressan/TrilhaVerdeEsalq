import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_button.dart';
import '../theme/app_colors.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  String? ultimoUsuario;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    ultimoUsuario = prefs.getString('ultimo_usuario');
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: true,
              bottom: false, // <- cola o frame no rodapé
              child: Stack(
                children: [
                  // ======= FUNDO (montanhas) grudado ao rodapé =======
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'lib/assets/img/frame_inicio.png',
                      fit: BoxFit.fitWidth, // ocupa toda a largura
                      width: size.width,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),

                  // ======= NUVENS =======
                  Positioned(
                    top: 56,
                    left: 20,
                    child: Image.asset(
                      'lib/assets/img/grande_nuvem.png',
                      width: 100,
                    ),
                  ),
                  Positioned(
                    top: 118,
                    right: 30,
                    child: Image.asset(
                      'lib/assets/img/pequena_nuvem.png',
                      width: 72,
                    ),
                  ),
                  Positioned(
                    top: 250,
                    left: 30,
                    child: Image.asset(
                      'lib/assets/img/grande_nuvem.png',
                      width: 72,
                    ),
                  ),

                  // ======= LOGO + TÍTULO (centralizados) =======
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo maior
                        Image.asset(
                          'lib/assets/img/logo_new.png',
                          width: 180,
                          height: 180,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Trilha Verde',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.title,
                            letterSpacing: 0
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 16 + bottomInset, // encosta mas respeita gesto/safe inset
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AppButton(
                        label: 'COMEÇAR',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
