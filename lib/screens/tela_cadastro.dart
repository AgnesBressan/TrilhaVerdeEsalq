// lib/screens/tela_cadastro.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/home_action_button.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  final _anoCtrl  = TextEditingController();
  int? _idade;
  bool _saving = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _nickCtrl.dispose();
    _anoCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome_usuario', _nomeCtrl.text.trim());
    await prefs.setString('nickname_usuario', _nickCtrl.text.trim());
    await prefs.setInt('idade_usuario', _idade!);
    await prefs.setString('ano_escolar_usuario', _anoCtrl.text.trim());
    // mantém o mesmo comportamento do login: usa o nickname como último usuário
    await prefs.setString('ultimo_usuario', _nickCtrl.text.trim());

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/principal');
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFA7C957), width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // NUVENS (mesmos assets das outras telas)
            Positioned(
              top: 36,
              left: 26,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 96),
            ),
            Positioned(
              top: 86,
              right: 34,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 72),
            ),
            Positioned(
              bottom: 40,
              left: 24,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 60),
            ),

            // PAINEL CENTRAL
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  decoration: BoxDecoration(
                    color: AppColors.panelBg, // #E5DAC3
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'Cadastro',
                            style: TextStyle(
                              color: AppColors.welcome, // #A35E2D
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Nome',
                          style: TextStyle(
                            color: AppColors.explorer, // #4F6F52
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nomeCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: _fieldDecoration('Seu nome'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Informe o nome'
                                  : null,
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Nickname',
                          style: TextStyle(
                            color: AppColors.explorer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nickCtrl,
                          decoration: _fieldDecoration('Seu nickname no app'),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Informe um nickname';
                            if (t.length > 24) return 'Máximo 24 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Idade',
                          style: TextStyle(
                            color: AppColors.explorer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _idade,
                          decoration: _fieldDecoration('Selecione sua idade'),
                          items: List.generate(
                            58, // 3..60
                            (i) {
                              final age = 3 + i;
                              return DropdownMenuItem(
                                value: age,
                                child: Text(age.toString()),
                              );
                            },
                          ),
                          onChanged: (v) => setState(() => _idade = v),
                          validator: (v) =>
                              v == null ? 'Selecione a idade' : null,
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Ano escolar',
                          style: TextStyle(
                            color: AppColors.explorer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _anoCtrl,
                          decoration: _fieldDecoration('Ex.: 5º ano, 7º ano...'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Informe o ano escolar'
                                  : null,
                        ),
                        const SizedBox(height: 20),

                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 220,
                            child: HomeActionButton(
                              label:
                                  _saving ? 'CADASTRANDO...' : 'CADASTRAR',
                              background: AppColors.cadastroBg,
                              textColor: Colors.black87,
                              onPressed: _saving ? () {} : _onCadastrar,
                              height: 52,
                            ),
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
