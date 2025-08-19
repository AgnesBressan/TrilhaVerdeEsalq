import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/home_action_button.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _nickController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    final nick = _nickController.text.trim();
    await prefs.setString('nome_usuario', nick);
    await prefs.setString('ultimo_usuario', nick);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/principal');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // <-- CORRETO

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Nuvens
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

            // Painel central
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  decoration: BoxDecoration(
                    color: AppColors.panelBg,              // #E5DAC3
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Entre com seu',
                          style: TextStyle(
                            color: AppColors.welcome,       // #A35E2D
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Nickname',
                          style: TextStyle(
                            color: AppColors.explorer,      // #4F6F52
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _nickController,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onLogin(),
                          decoration: InputDecoration(
                            hintText: 'Seu apelido',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.15)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFA7C957), width: 2),
                            ),
                          ),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Informe um nickname';
                            if (t.length > 24) return 'Máximo 24 caracteres';
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: 220, // central, como no Figma
                          child: HomeActionButton(
                            label: _saving ? 'ENTRANDO...' : 'LOGIN',
                            background: AppColors.loginBg,
                            textColor: Colors.black87,
                            onPressed: _saving ? () {} : _onLogin,
                            height: 52,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
