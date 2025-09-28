import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_cliente.dart'; // [NOVO] Importa o cliente da API
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class TelaGanhou extends StatefulWidget { // [ALTERADO] Para StatefulWidget
  const TelaGanhou({super.key});

  @override
  State<TelaGanhou> createState() => _TelaGanhouState();
}

class _TelaGanhouState extends State<TelaGanhou> {
  final _api = ApiClient();
  bool _isResetting = false; // [NOVO] Estado para o botão

  // [LÓGICA CORRIGIDA]
  Future<void> _reiniciarJogo() async {
    setState(() => _isResetting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('ultimo_usuario');

      if (nickname != null) {
        // Chama a API para apagar os troféus do backend
        await _api.reiniciarProgresso(nickname);
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/principal', (r) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reiniciar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
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
            // ===== NUVENS =====
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

            // ===== CONTEÚDO =====
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'VOCÊ VISITOU TODAS AS\nÁRVORES E',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.explorer,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GANHOU O JOGO\nPARABÉNS!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.explorer,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Image.asset(
                      'lib/assets/img/ganhou.png',
                      width: 210,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: 200,
                      child: AppButton(
                        // [ALTERADO] Lógica do botão
                        label: _isResetting ? 'REINICIANDO...' : 'REINICIAR JOGO',
                        onPressed: _isResetting ? null : _reiniciarJogo,
                      ),
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