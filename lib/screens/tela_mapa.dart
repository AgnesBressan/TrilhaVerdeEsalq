import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav.dart';
import '../theme/app_colors.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  String? imagePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome_usuario') ?? 'usuário';
    final chaveArvores = 'arvores_lidas_$nome';
    final arvoresLidas = prefs.getStringList(chaveArvores) ?? [];
    final qtdArvoresLidas = arvoresLidas.length + 1;

    setState(() {
      if (qtdArvoresLidas == 0) {
        imagePath = 'lib/assets/img/planta(1).png';
      } else if (qtdArvoresLidas > 0 && qtdArvoresLidas < 28) {
        final numImagem = qtdArvoresLidas + 1;
        imagePath = 'lib/assets/img/planta($numImagem).png';
      } else {
        imagePath = 'lib/assets/img/planta(1).png';
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BD600), // fundo verde
      bottomNavigationBar: const BottomNav(current: BottomTab.mapa),
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : (imagePath == null)
                  ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Comece a jogar para ver sua progressão no mapa!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // base de exibição centralizada (deixe com margens)
                        final baseWidth = constraints.maxWidth * 0.9;
                        // razão do PNG do mapa (~395x574)
                        const aspect = 395 / 574;
                        final baseHeight = baseWidth / aspect;

                        return InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 5.0,
                          boundaryMargin: const EdgeInsets.all(48),
                          clipBehavior: Clip.none,
                          child: SizedBox(
                            width: baseWidth,
                            height: baseHeight,
                            child: Image.asset(
                              imagePath!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
