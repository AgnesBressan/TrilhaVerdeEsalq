import 'dart:io';
import 'dart:typed_data'; // Importe para usar Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- NOSSAS IMPORTAÇÕES ---
import '../models/usuario.dart';
import '../services/api_cliente.dart';
// ----------------------------

import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/bottom_nav.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // Cliente da API
  final _api = ApiClient();

  // Estado da tela
  bool _isLoading = true;
  Usuario? _usuario;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Pega o nickname do usuário logado
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('ultimo_usuario');

      if (nickname == null) {
        // Se não houver usuário logado, volta para o login
        _sair();
        return;
      }

      // 2. Busca os dados do usuário e o avatar da API em paralelo
      final resultados = await Future.wait([
        _api.obterUsuario(nickname),
        _api.fetchAvatarUsuario(nickname),
      ]);

      if (!mounted) return;
      setState(() {
        _usuario = resultados[0] as Usuario?;
        _avatarBytes = resultados[1] as Uint8List?;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perfil: $e')),
      );
      // Opcional: Tratar erro, talvez voltando para a tela de login
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarImagem() async {
    if (_usuario == null) return;

    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (imagem == null) return;

    final file = File(imagem.path);
    
    try {
      // Faz o upload da nova imagem para o backend
      final sucesso = await _api.uploadAvatarUsuario(_usuario!.nickname, file);

      if (sucesso) {
        // Se o upload funcionou, recarrega os dados para mostrar a nova foto
        await _carregarDados();
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto de perfil atualizada!')),
          );
        }
      } else {
        throw Exception('O servidor recusou o upload.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao trocar foto: $e')),
      );
    }
  }

  Future<void> _sair() async {
    await _api.sair(); // Limpa os dados locais
    if (!mounted) return;
    // Navega para a tela de login e remove todas as telas anteriores da pilha
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNav(current: BottomTab.perfil),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: const BoxDecoration(
                              color: AppColors.panelBg,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: ClipOval(
                              child: SizedBox(
                                width: 150,
                                height: 150,
                                child: _avatarBytes == null
                                    ? const Icon(Icons.person, size: 80, color: Colors.black26)
                                    // Usa Image.memory para exibir bytes da rede
                                    : Image.memory(_avatarBytes!, fit: BoxFit.cover),
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

                    // Exibe os dados do objeto _usuario
                    _Info(label: 'Nome', value: _usuario?.nome ?? 'Não informado'),
                    const SizedBox(height: 16),
                    _Info(label: 'Nickname', value: _usuario?.nickname ?? '-'),
                    const SizedBox(height: 16),
                    _Info(label: 'Idade', value: '${_usuario?.idade ?? '-'} anos'),
                    const SizedBox(height: 16),
                    _Info(label: 'Ano escolar', value: _usuario?.anoEscolar ?? '-'),
                    const SizedBox(height: 30),

                    // Botão SAIR
                    Center(
                      child: SizedBox(
                        child: AppButton(
                          label: 'SAIR',
                          onPressed: _sair, // Chama a função de logout
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
            color: AppColors.explorer,
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