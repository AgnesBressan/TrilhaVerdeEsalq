import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../widgets/home_action_button.dart';

// NEW: cliente HTTP da API
import '../services/api_cliente.dart';
// (Opcional) se você quiser passar o objeto para a próxima tela
import '../models/usuario.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _nickController = TextEditingController();
  final _api = ApiClient();

  bool _saving = false;

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final nick = _nickController.text.trim();

    try {
      // tenta buscar no banco
      final Usuario? user = await _api.obterUsuario(nick);

      if (user != null) {
        // guarda só o último usuário localmente (qualquer outra info vem da API)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ultimo_usuario', nick);

        if (!mounted) return;
        // se quiser, passe o user como argumento
        Navigator.pushReplacementNamed(context, '/principal', arguments: user);
        return;
      }

      // se não existe, oferece ir para cadastro
      if (!mounted) return;
      final bool? cadastrar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Usuário não encontrado'),
          content: Text('O nickname "$nick" ainda não existe. Deseja cadastrar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      );

      if (cadastrar == true && mounted) {
        // vai para cadastro já com o nickname digitado
        Navigator.pushReplacementNamed(
          context,
          '/cadastro',
          arguments: {'nickname': nick},
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao entrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
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
            // Nuvens
            Positioned(
              top: 40,
              left: 24,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 96),
            ),
            Positioned(
              top: 72,
              right: 32,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 72),
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
              bottom: 90,
              left: 26,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 60),
            ),
            Positioned(
              bottom: 70,
              right: 30,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 64),
            ),

            // Painel central
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  decoration: BoxDecoration(
                    color: AppColors.panelBg,
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
                            color: AppColors.welcome,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Nickname',
                          style: TextStyle(
                            color: AppColors.explorer,
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
                            hintText: 'Seu nickname',
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
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(
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
                          width: 220,
                          child: HomeActionButton(
                            label: _saving ? 'ENTRANDO...' : 'LOGIN',
                            background: AppColors.loginBg,
                            textColor: Colors.black87,
                            // sempre passar função não-nula
                            onPressed: () {
                              if (_saving) return;
                              _onLogin();
                            },
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
