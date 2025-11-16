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
  static const Map<String, Color> _opcaoColors = {
    'A': Color(0xFF4F6F52), // Verde Escuro
    'B': Color(0xFFA7C957), // Verde Claro
    'C': Color(0xFFEBA937), // Laranja/Amarelo
    'D': Color(0xFF8B5E3C), // Marrom Escuro
    'E': Color(0xFFA35E2D), // Marrom Claro
  };

  Color _getColorForKey(String key) {
    return _opcaoColors[key] ?? Colors.grey;
  }

  final _api = ApiClient();
  bool _gotArgs = false;

  Pergunta? _pergunta; 
  String? _opcaoSelecionadaKey; 
  bool _isSubmitting = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gotArgs) return;
    _gotArgs = true;

    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    setState(() {
      _pergunta = args['pergunta'] as Pergunta?;
    });
  }
  
  Future<void> _onConfirmarResposta() async {
    if (_opcaoSelecionadaKey == null || _isSubmitting || _pergunta == null) return;

    setState(() => _isSubmitting = true);

    final acertou = _opcaoSelecionadaKey == _pergunta!.respostaCorreta;

    try {
      if (acertou) {
        final prefs = await SharedPreferences.getInstance();
        final nickname = prefs.getString('ultimo_usuario');
        if (nickname != null) {
          // 1. Salva o troféu
          await _api.salvarTrofeu(nickname, _pergunta!.trilhaNome, _pergunta!.arvoreCodigo);
          
          // 2. Conta os troféus já coletados (para a trilha atual)
          final trofeus = await _api.listarTrofeus(nickname);
          final trofeusDaTrilha = trofeus
              .where((t) => t.trilhaNome == _pergunta!.trilhaNome)
              .map((t) => t.arvoreCodigo)
              .toSet();
          final trofeusColetados = trofeusDaTrilha.length;
          
          // 3. OBTÉM O TOTAL DE ÁRVORES ATIVAS (CORREÇÃO CRUCIAL)
          // Busca APENAS as árvores ATIVAS na trilha para o cálculo do total.
          final todasArvoresAtivas = await _api.listarArvores(
            trilha: _pergunta!.trilhaNome, 
            ativas: true,
          );
          final totalArvoresAtivas = todasArvoresAtivas.length;

          if (!mounted) return;

          // 4. VERIFICA FINALIZAÇÃO: Compara os coletados com o total de ativas
          final finalizouTrilha =
              totalArvoresAtivas > 0 && trofeusColetados >= totalArvoresAtivas;

          // 5. NAVEGAÇÃO CONDICIONAL
          final targetRoute = finalizouTrilha ? '/ganhou' : '/acertou';
          
          Navigator.pushReplacementNamed(
            context,
            targetRoute, 
            // Argumentos para /ganhou ou /acertou
            arguments: finalizouTrilha 
                      ? {'autoReset': true} 
                      : {'finalizou': false},
          );
        }
      } else {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaErrou(pergunta: _pergunta!),
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

  List<Widget> _buildOptions(Pergunta p) {
    final options = <_OpcaoData>[];
    if (p.itemA != null && p.itemA!.isNotEmpty) options.add(_OpcaoData('A', p.itemA!));
    if (p.itemB != null && p.itemB!.isNotEmpty) options.add(_OpcaoData('B', p.itemB!));
    if (p.itemC != null && p.itemC!.isNotEmpty) options.add(_OpcaoData('C', p.itemC!));
    if (p.itemD != null && p.itemD!.isNotEmpty) options.add(_OpcaoData('D', p.itemD!));
    if (p.itemE != null && p.itemE!.isNotEmpty) options.add(_OpcaoData('E', p.itemE!));

    return options.map((op) {
      final color = _getColorForKey(op.key); 
      
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
          primaryColor: color, 
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                    ..._buildOptions(_pergunta!),
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

class _OpcaoData {
  final String key;
  final String titulo;
  const _OpcaoData(this.key, this.titulo);
}

class _OpcaoTile extends StatelessWidget {
  final String titulo;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor; 
  
  const _OpcaoTile({
    required this.titulo,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor;
    
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
            color: color.withOpacity(0.37), 
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