import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_cliente.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class TelaGanhou extends StatefulWidget {
  const TelaGanhou({super.key});

  @override
  State<TelaGanhou> createState() => _TelaGanhouState();
}

class _TelaGanhouState extends State<TelaGanhou> {
  final _api = ApiClient();
  bool _isResetting = false;
  // NOVO: Indica se o reset (automático ou manual) foi concluído.
  bool _progressReset = false; 
  // NOVO: Garante que a lógica de auto-reset só rode uma vez.
  bool _handledAutoReset = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledAutoReset) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    // Verifica se o TelaQuiz pediu um reset automático
    final shouldAutoReset = args is Map && args['autoReset'] == true;
    _handledAutoReset = true;

    if (shouldAutoReset) {
      // Executa o reset automaticamente em um microtask para não bloquear o build inicial
      Future.microtask(() => _executarReset(navigateAfter: false));
    }
  }
  
  // Lógica unificada para reset (usada pelo auto-reset e pelo botão)
  Future<void> _executarReset({required bool navigateAfter}) async {
    if (!mounted) return;
    // Apenas mostra o loader se o reset for manual (navigateAfter=true)
    if (navigateAfter) setState(() => _isResetting = true); 
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('ultimo_usuario');

      if (nickname != null) {
        // Chama a API para apagar os troféus
        await _api.reiniciarProgresso(nickname);
      }

      if (!mounted) return;

      if (navigateAfter) {
        // Opção 1: Clicou no botão "REINICIAR JOGO"
        Navigator.pushNamedAndRemoveUntil(context, '/principal', (r) => false);
      } else {
        // Opção 2: Reset automático após vitória
        setState(() {
          _progressReset = true; // Marca que o reset foi feito
          _isResetting = false; 
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reiniciar: $e')),
        );
      }
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  Future<void> _reiniciarJogo() async {
    // Se o reset já foi feito (via auto-reset), o botão navega.
    if (_progressReset) {
      Navigator.pushNamedAndRemoveUntil(context, '/principal', (r) => false);
      return;
    }
    
    // Caso contrário (se chegou aqui sem auto-reset), executa e navega
    await _executarReset(navigateAfter: true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ===== NUVENS (Mantidas) =====
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
                        // O botão é desabilitado se o reset está em andamento.
                        label: _isResetting
                            ? 'REINICIANDO...'
                            : (_progressReset ? 'IR PARA O INÍCIO' : 'REINICIAR JOGO'),
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