import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  File? _imagemPerfil;
  String _nomeUsuario = 'Usuário';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome_usuario') ?? 'Usuário';
    final chaveImagem = 'imagem_perfil_$nome';

    File? foto;
    final imagemPath = prefs.getString(chaveImagem);
    if (imagemPath != null && File(imagemPath).existsSync()) {
      foto = File(imagemPath);
    }

    if (!mounted) return;
    setState(() {
      _nomeUsuario = nome;
      _imagemPerfil = foto;
    });
  }

  Future<void> _selecionarImagem() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem == null) return;

    final prefs = await SharedPreferences.getInstance();
    final chaveImagem = 'imagem_perfil_$_nomeUsuario';
    await prefs.setString(chaveImagem, imagem.path);

    if (!mounted) return;
    setState(() => _imagemPerfil = File(imagem.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNav(current: BottomTab.perfil),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seu perfil',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.principal_title,
                ),
              ),
              const SizedBox(height: 30),

              // Avatar + botão
              Center(
                child: Column(
                  children: [
                    // círculo grande como no Figma
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.panelBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: SizedBox(
                          width: 210,
                          height: 210,
                          child: _imagemPerfil == null
                              ? Icon(Icons.person, size: 80, color: Colors.black26)
                              : Image.file(_imagemPerfil!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      child: AppButton(
                        label: 'TROCAR FOTO',
                        onPressed: _selecionarImagem,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Infos
              _Info(label: 'Nome', value: _nomeUsuario),
              const SizedBox(height: 16),
              _Info(label: 'Nickname', value: _nomeUsuario),
              const SizedBox(height: 16),
              const _Info(label: 'Idade', value: 'idade aqui'),
              const SizedBox(height: 16),
              const _Info(label: 'Ano escolar', value: 'ano escolar aqui'),

              const SizedBox(height: 30),

              // SAIR → volta pra Home
              Center(
                child: SizedBox(
                  child: AppButton(
                    label: 'SAIR',
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.explorer, // #4F6F52
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.explorer,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
