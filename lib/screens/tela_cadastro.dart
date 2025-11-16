import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../widgets/home_action_button.dart';
import '../models/usuario.dart';
import '../services/api_cliente.dart';

class ApiConflictError implements Exception {} 

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  final _anoCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  bool _saving = false;

  final _api = ApiClient();

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _nickCtrl.dispose();
    _anoCtrl.dispose();
    _idadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    
    final idadeInt = int.tryParse(_idadeCtrl.text.trim());
    if (idadeInt == null) return; 
    setState(() => _saving = true);

    final usuario = Usuario(
      nickname: _nickCtrl.text.trim(),
      nome: _nomeCtrl.text.trim(),
      idade: idadeInt,
      anoEscolar: _anoCtrl.text.trim(),
      numArvoresVisitadas: 0,
    );

    try {
      await _api.salvarUsuario(usuario);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ultimo_usuario', usuario.nickname);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/principal', arguments: usuario);
    } on ApiConflictError catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este nickname já está em uso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      borderSide: const BorderSide(color: Color(0xFFA7C957), width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.explorer, size: 30),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                ),
              ),
            ),
            
            Positioned(top: 36, left: 26,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 96)),
            Positioned(top: 86, right: 34,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 72)),
            Positioned(bottom: 40, left: 24,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 60)),

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
                    child: SingleChildScrollView( // Usar SingleChildScrollView para evitar overflow em telas pequenas
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10.0, bottom: 6.0),
                              child: Text('Cadastro',
                                style: TextStyle(
                                  color: AppColors.welcome,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const Text('Nome', style: TextStyle(color: AppColors.explorer, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nomeCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: _fieldDecoration('Seu nome'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                          ),
                          const SizedBox(height: 14),

                          const Text('Nickname', style: TextStyle(color: AppColors.explorer, fontWeight: FontWeight.w700)),
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

                          const Text('Idade', style: TextStyle(color: AppColors.explorer, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _idadeCtrl, // NOVO CONTROLADOR
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration('Digite sua idade'),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, // Aceita apenas dígitos
                              LengthLimitingTextInputFormatter(3),     // Limita a 3 dígitos (até 999 anos)
                            ],
                            validator: (v) {
                              final age = int.tryParse(v?.trim() ?? '');
                              if (age == null || age <= 0 || age > 99) return 'Idade inválida (máx 99)';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const Text('Ano escolar', style: TextStyle(color: AppColors.explorer, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _anoCtrl,
                            decoration: _fieldDecoration('Ex.: 5º ano, 7º ano...'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o ano escolar' : null,
                          ),
                          const SizedBox(height: 20),

                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 220,
                              child: HomeActionButton(
                                label: _saving ? 'CADASTRANDO...' : 'CADASTRAR',
                                background: AppColors.explorer,
                                textColor: Colors.black87,
                                onPressed: () {
                                  if (_saving) return;
                                  _onCadastrar();
                                },
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
            ),
          ],
        ),
      ),
    );
  }
}
