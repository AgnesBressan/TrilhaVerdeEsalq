import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pergunta.dart';
import '../services/api_cliente.dart';
import 'tela_errou.dart'; 
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';

class TelaQuiz extends StatefulWidget {
  const TelaQuiz({super.key});

  @override
  State<TelaQuiz> createState() => _TelaQuizState();
}

class _TelaQuizState extends State<TelaQuiz> {
  final _api = ApiClient();
  bool _gotArgs = false;

  // [ALTERADO] Agora a tela lida com apenas uma pergunta, recebida como argumento.
  Pergunta? _pergunta; 
  String? _opcaoSelecionadaKey; 
  bool _isSubmitting = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gotArgs) return;
    _gotArgs = true;

    // [ALTERADO] Recebe o objeto 'Pergunta' completo, enviado pela TelaDicas.
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    setState(() {
      _pergunta = args['pergunta'] as Pergunta?;
    });
  }
  
  // Lógica principal ao confirmar uma resposta
  Future<void> _onConfirmarResposta() async {
    if (_opcaoSelecionadaKey == null || _isSubmitting || _pergunta == null) return;

    setState(() => _isSubmitting = true);

    final acertou = _opcaoSelecionadaKey == _pergunta!.respostaCorreta;

    try {
      if (acertou) {
        final prefs = await SharedPreferences.getInstance();
        final nickname = prefs.getString('ultimo_usuario');
        if (nickname != null) {
          // Salva o troféu usando os dados da pergunta recebida
          await _api.salvarTrofeu(nickname, _pergunta!.trilhaNome, _pergunta!.arvoreCodigo);
        }
        
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/acertou');
      } else {
        if (!mounted) return;
        // Navega para a tela de erro, passando a URL da dica em áudio
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaErrou(audioDicaUrl: _pergunta!.audioDicaUrl),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao processar resposta: $e')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  // Constrói a lista de widgets de opção a partir da pergunta
  List<Widget> _buildOptions(Pergunta p) {
    final options = <_OpcaoData>[];
    // Adiciona apenas as opções que não são nulas
    if (p.itemA != null && p.itemA!.isNotEmpty) options.add(_OpcaoData('A', p.itemA!));
    if (p.itemB != null && p.itemB!.isNotEmpty) options.add(_OpcaoData('B', p.itemB!));
    if (p.itemC != null && p.itemC!.isNotEmpty) options.add(_OpcaoData('C', p.itemC!));
    if (p.itemD != null && p.itemD!.isNotEmpty) options.add(_OpcaoData('D', p.itemD!));
    if (p.itemE != null && p.itemE!.isNotEmpty) options.add(_OpcaoData('E', p.itemE!));

    return options.map((op) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: _OpcaoTile(
          titulo: op.titulo,
          isSelected: _opcaoSelecionadaKey == op.key,
          onTap: () {
            setState(() {
              _opcaoSelecionadaKey = op.key;
            });
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // [SIMPLIFICADO] A tela agora só precisa verificar se recebeu a pergunta.
    if (_pergunta == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: Text('Erro: Nenhuma pergunta foi recebida.'))
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ... (seu layout de nuvens pode continuar aqui)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5DAC3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _pergunta!.enunciado ?? 'Carregando...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Color(0xFF827B6D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ..._buildOptions(_pergunta!), // Constrói as opções dinamicamente
                    const SizedBox(height: 20),
                    AppButton(
                      label: _isSubmitting ? 'VERIFICANDO...' : 'CONFIRMAR',
                      onPressed: _opcaoSelecionadaKey == null ? null : _onConfirmarResposta,
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

// Classe auxiliar para os dados da opção
class _OpcaoData {
  final String key;
  final String titulo;
  const _OpcaoData(this.key, this.titulo);
}

// Widget da opção
class _OpcaoTile extends StatelessWidget {
  final String titulo;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _OpcaoTile({
    required this.titulo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.play : const Color(0xFF8B5E3C);
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            borderRadius: BorderRadius.circular(18),
            border: isSelected ? Border.all(color: color, width: 2.5) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}