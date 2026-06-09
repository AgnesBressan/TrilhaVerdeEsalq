import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_cliente.dart';      
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';
import '../models/trilha.dart';  // Importando o modelo de Trilha

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});
  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final _api = ApiClient();

  String _nomeUsuario = 'Usuário';
  File? _avatarFile;         
  Uint8List? _avatarBytes;    
  bool _loading = true;

  // Para armazenar as trilhas disponíveis
  List<Trilha> _trilhas = [];
  String? _trilhaSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _carregarTrilhas();
    _carregarTrilhaSelecionada();  // Carregar trilha selecionada ao iniciar
  }

  // Carregar dados do usuário
  Future<void> _carregarDados() async {
    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      prefs.setString('trilha_selecionada', _trilhaSelecionada!);

      final me = await _api.fetchMe();       
      final avatar = await _api.fetchAvatar(); 

      if (me != null) {
        _nomeUsuario = (me['nome'] as String?)?.trim().isNotEmpty == true
            ? (me['nome'] as String).trim()
            : 
              (prefs.getString('ultimo_usuario') ??
                  prefs.getString('nome_usuario') ??
                  'Usuário');
      } else {
        final ultimo = prefs.getString('ultimo_usuario');
        final nome = prefs.getString('nome_usuario');
        _nomeUsuario = (ultimo?.trim().isNotEmpty ?? false)
            ? ultimo!.trim()
            : (nome?.trim().isNotEmpty ?? false)
                ? nome!.trim()
                : 'Usuário';
      }

    } catch (e) {
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

  // Carregar as trilhas disponíveis no banco
  Future<void> _carregarTrilhas() async {
    try {
      final trilhas = await _api.listarTrilhas(); // Supondo que o método para listar trilhas exista
      setState(() {
        _trilhas = trilhas;
      });
    } catch (e) {
      print("Erro ao carregar as trilhas: $e");
    }
  }

  // Carregar a trilha selecionada de SharedPreferences
  Future<void> _carregarTrilhaSelecionada() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _trilhaSelecionada = prefs.getString('trilha_selecionada');
    });
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
                          'Preparado para conhecer as',
                          style: TextStyle(
                            color: AppColors.preparedText,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Trilhas da ESALQ?',
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

                    // Balãozinho com nova frase
                    SizedBox(
                      height: 210,
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
                                'Selecione a trilha que\n'
                                'deseja percorrer!',
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

                    // Select box para escolher a trilha
                    Center(
                      child: DropdownButton<String>(
                        value: _trilhaSelecionada,
                        onChanged: (String? newValue) async {
                          setState(() {
                            _trilhaSelecionada = newValue;
                          });

                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('trilha_selecionada', newValue!); // Salva a trilha selecionada
                        },
                        hint: const Text('Selecione uma Trilha'),
                        items: _trilhas.map<DropdownMenuItem<String>>((Trilha trilha) {
                          return DropdownMenuItem<String>(
                            value: trilha.nome,
                            child: Text(trilha.nome),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}