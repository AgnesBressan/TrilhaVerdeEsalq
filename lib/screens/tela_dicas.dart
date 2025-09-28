// lib/screens/tela_dicas.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../services/api_cliente.dart';
import '../models/arvore.dart';
import '../models/pergunta.dart';

class TelaDicas extends StatefulWidget {
  const TelaDicas({super.key});
  @override
  State<TelaDicas> createState() => _TelaDicasState();
}

class _TelaDicasState extends State<TelaDicas> {
  final _api = ApiClient();
  late final AudioPlayer _player;

  PlayerState? _playerState;

  String? _trilha;
  int? _arvoreCodigo;
  Arvore? _arvore;
  Pergunta? _perguntaSelecionada;
  bool _loading = true;
  String? _error;
  bool _gotArgs = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gotArgs) return;
    _gotArgs = true;

    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    _trilha = args['trilha'] as String?;
    _arvoreCodigo = args['arvoreCodigo'] as int?;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_trilha == null || _arvoreCodigo == null) {
        throw Exception('Parâmetros ausentes (trilha/código).');
      }

      final resultados = await Future.wait([
        _api.listarPerguntas(trilha: _trilha!, arvoreCodigo: _arvoreCodigo!),
        _api.obterArvore(_trilha!, _arvoreCodigo!),
      ]);

      final perguntas = resultados[0] as List<Pergunta>;
      final arvore = resultados[1] as Arvore;

      Pergunta? perguntaSorteada;
      if (perguntas.isNotEmpty) {
        final random = Random();
        perguntaSorteada = perguntas[random.nextInt(perguntas.length)];
      }

      setState(() {
        _arvore = arvore;
        _perguntaSelecionada = perguntaSorteada;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Falha ao carregar dados: $e';
        _loading = false;
      });
    }
  }

  // A LÓGICA DE TOCAR/PAUSAR FOI CENTRALIZADA E CORRIGIDA AQUI
  Future<void> _toggleAudioPlayback() async {
    const baseUrl = 'http://localhost:3001'; // Para emulador Android, use 'http://10.0.2.2:3001'

    final audioPath = _perguntaSelecionada?.audioUrl;
    if (audioPath == null || audioPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum áudio disponível.')),
      );
      return;
    }

    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else {
      String finalUrl;
      // VERIFICA SE O CAMINHO JÁ É UMA URL COMPLETA
      if (audioPath.startsWith('http')) {
        finalUrl = audioPath;
      } else {
        // SE NÃO FOR, MONTA A URL COMPLETA COM O BASEURL
        finalUrl = baseUrl + audioPath;
      }
      await _player.play(UrlSource(finalUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              AppButton(label: 'Tentar novamente', onPressed: _load),
            ],
          ),
        ),
      );
    }

    final nomeArvore = _arvore?.nome ?? 'Árvore ${_arvoreCodigo ?? ''}';
    final especie = (_arvore?.especie ?? '').trim();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Parabéns, ',
                      style: TextStyle(
                        color: AppColors.explorer,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: 'você leu o QR code da seguinte árvore:',
                      style: TextStyle(
                        color: AppColors.explorer,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nome da árvore
              Text(
                nomeArvore,
                style: const TextStyle(
                  color: AppColors.preparedText,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                  height: 1.05,
                ),
              ),
              if (especie.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  especie,
                  style: const TextStyle(
                    color: Color(0xFF4B4B4B),
                    fontSize: 14.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const SizedBox(height: 50),

              // Balão + mascote
              SizedBox(
                height: 210,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 3,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: w * 0.70),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
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
                          'Vamos conhecer um pouco\nmais sobre a árvore?',
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
                        width: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Descrição vinda da pergunta
              Text(
                _perguntaSelecionada?.texto ??
                    'Nenhuma descrição disponível para esta árvore.',
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: Color(0xFF4B4B4B),
                ),
              ),

              const SizedBox(height: 30),

              // Caixa de áudio funcional
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.panelBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _toggleAudioPlayback,
                        iconSize: 30,
                        icon: Icon(
                          _playerState == PlayerState.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.play,
                        ),
                      ),
                      Image.asset('lib/assets/img/sound.png',
                          height: 30, fit: BoxFit.contain),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botão "RESPONDER A PERGUNTA"
              Center(
                child: AppButton(
                  label: _perguntaSelecionada == null
                      ? 'SEM PERGUNTAS NESTA ÁRVORE'
                      : 'RESPONDER A PERGUNTA',
                  onPressed: _perguntaSelecionada == null
                      ? null
                      : () => Navigator.pushNamed(
                            context,
                            '/quiz',
                            arguments: {
                              'pergunta': _perguntaSelecionada!,
                            },
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