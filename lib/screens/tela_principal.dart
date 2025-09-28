import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_cliente.dart';        // <-- usa sua API
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});
  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final _api = ApiClient();

  String _nomeUsuario = 'Usuário';
  File? _avatarFile;            // desktop/mobile
  Uint8List? _avatarBytes;      // web/qualquer
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1) tenta pegar do backend
      final me = await _api.fetchMe();           // { email, nome, vinculo } ou null
      final avatar = await _api.fetchAvatar();   // bytes ou null

      if (me != null) {
        _nomeUsuario = (me['nome'] as String?)?.trim().isNotEmpty == true
            ? (me['nome'] as String).trim()
            : // fallback: se não tiver "nome", usa último nickname salvo
              (prefs.getString('ultimo_usuario') ??
                  prefs.getString('nome_usuario') ??
                  'Usuário');
      } else {
        // 2) fallback local (sem backend/logado)
        final ultimo = prefs.getString('ultimo_usuario');
        final nome = prefs.getString('nome_usuario');
        _nomeUsuario = (ultimo?.trim().isNotEmpty ?? false)
            ? ultimo!.trim()
            : (nome?.trim().isNotEmpty ?? false)
                ? nome!.trim()
                : 'Usuário';
      }

    
    } catch (e) {
      // silencioso: se der ruim no backend, continua com fallback
      final prefs = await SharedPreferences.getInstance();
      final ultimo = prefs.getString('ultimo_usuario');
      final nome = prefs.getString('nome_usuario');
      _nomeUsuario = (ultimo?.trim().isNotEmpty ?? false)
          ? ultimo!.trim()
          : (nome?.trim().isNotEmpty ?? false)
              ? nome!.trim()
              : 'Usuário';
      _avatarFile = null;
      _avatarBytes = null;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNav(current: BottomTab.home),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // Saudação + avatar (opcional)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 18, color: Colors.black87),
                              children: [
                                const TextSpan(
                                  text: 'Olá, ',
                                  style: TextStyle(color: AppColors.explorer, fontFamily: 'Poppins'),
                                ),
                                TextSpan(
                                  text: '$_nomeUsuario!',
                                  style: const TextStyle(
                                    color: AppColors.explorer,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Preparado para conhecer a',
                          style: TextStyle(
                            color: AppColors.preparedText,
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

                    Center(
                      child: SizedBox(
                        child: AppButton(
                          label: 'COMO JOGAR?',
                          onPressed: () => Navigator.pushNamed(context, '/tutorial'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Balão de fala + mascote
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            right: 3,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: w * 0.62),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: const BoxDecoration(
                                color: AppColors.speechBg32,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.zero,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: const Text(
                                'Clique para abrir o mapa\n'
                                'e começar a aventura!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.loginBg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
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
