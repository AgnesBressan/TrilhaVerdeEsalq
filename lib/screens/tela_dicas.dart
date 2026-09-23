import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../services/api_cliente.dart';
import '../models/ponto_interesse.dart';
import '../models/pergunta.dart';
import '../models/imagem.dart';

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
  int? _pontoCodigo;
  PontoInteresse? _ponto;
  List<Imagem> _imagens = [];
  Pergunta? _perguntaSelecionada;
  bool _loading = true;
  String? _error;
  bool _gotArgs = false;
  bool _marcandoLida = false;
  bool _finalizouTrilha = false;

  bool get _ehPredio => _ponto?.tipo == 'predio_historico';
  String get _rotulo => _ehPredio ? 'prédio' : 'árvore';
  String get _artigo => _ehPredio ? 'o' : 'a';
  String get _demonstrativo => _ehPredio ? 'este' : 'esta';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
  }

  @override
  void dispose() {
    _stopAudio();
    _player.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _stopAudio();
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_gotArgs) return;
    _gotArgs = true;

    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    _trilha = args['trilha'] as String?;
    _pontoCodigo = args['arvoreCodigo'] as int?;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_pontoCodigo == null) {
        throw Exception('Parâmetros ausentes (código do ponto).');
      }

      final resultados = await Future.wait([
        _api.listarPerguntas(pontoInteresseCodigo: _pontoCodigo!),
        _api.obterPontoInteresse(_pontoCodigo!),
        _api.listarImagens(_pontoCodigo!),
      ]);

      final perguntas = resultados[0] as List<Pergunta>;
      final ponto = resultados[1] as PontoInteresse;
      final imagens = resultados[2] as List<Imagem>;

      Pergunta? perguntaSorteada;
      if (perguntas.isNotEmpty) {
        final random = Random();
        perguntaSorteada = perguntas[random.nextInt(perguntas.length)];
      }

      setState(() {
        _ponto = ponto;
        _imagens = imagens;
        _perguntaSelecionada = perguntaSorteada;
        _loading = false;
      });

      // Se não tem perguntas, marca como lido automaticamente
      if (perguntaSorteada == null) {
        await _marcarComoLida();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Falha ao carregar dados: $e';
        _loading = false;
      });
    }
  }

  Future<void> _marcarComoLida() async {
    if (_marcandoLida) return;
    setState(() => _marcandoLida = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('ultimo_usuario');

      if (nickname != null && _trilha != null && _pontoCodigo != null) {
        // Salva o troféu
        await _api.salvarTrofeu(nickname, _pontoCodigo!);

        // Verifica se finalizou a trilha comparando com o total de
        // pontos ativos dela (a tabela trofeu não guarda trilha_nome —
        // um ponto pode pertencer a mais de uma trilha).
        final todosPontos =
            await _api.listarPontosInteresse(trilha: _trilha!, ativas: true);
        final trofeus = await _api.listarTrofeus(nickname);

        final codigosDaTrilha = todosPontos.map((p) => p.codigo).toSet();
        final totalAtivos = todosPontos.length;
        final totalLidos = trofeus
            .where((t) => codigosDaTrilha.contains(t.pontoInteresseCodigo))
            .length;

        if (mounted) {
          setState(() {
            _finalizouTrilha = totalLidos >= totalAtivos;
            _marcandoLida = false;
          });
        }
      }
    } catch (_) {
      // ignora erro silenciosamente — pode já ter sido salvo antes
      if (mounted) setState(() => _marcandoLida = false);
    }
  }

  Future<void> _toggleAudioPlayback() async {
    const baseUrl = 'http://200.144.255.186:3001';

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
      final finalUrl =
          audioPath.startsWith('http') ? audioPath : baseUrl + audioPath;
      await _player.play(UrlSource(finalUrl));
    }
  }

  void _stopAudio() {
    _player.stop();
  }

  void _abrirGaleria() {
    if (_imagens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Nenhuma foto disponível para $_demonstrativo $_rotulo.')),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/galeria_arvore',
      arguments: {
        'imagens': _imagens,
        'nomePonto': _ponto?.nome ?? 'Ponto de interesse',
      },
    );
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

    final nomePonto = _ponto?.nome ?? 'Ponto ${_pontoCodigo ?? ''}';
    final especie = (_ponto?.especie ?? '').trim();
    final temPerguntas = _perguntaSelecionada != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabeçalho ──────────────────────────────────
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Parabéns, ',
                      style: TextStyle(
                        color: AppColors.explorer,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: 'você leu o QR code d$_artigo seguinte $_rotulo:',
                      style: const TextStyle(
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

              Text(
                nomePonto,
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

              // ── Balão mascote + galeria (sempre igual) ──────
              SizedBox(
                height: 230,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 3,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: w * 0.70),
                        padding:
                            const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── texto do balão sempre igual ──
                            Text(
                              'Vamos conhecer um pouco\nmais sobre $_artigo $_rotulo?',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.loginBg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                onPressed: _abrirGaleria,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFA7C957),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Galeria',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppColors.buttonText,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
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

              // ── Corpo condicional ───────────────────────────
              if (temPerguntas) ...[
                // Texto da dica
                Text(
                  _perguntaSelecionada?.texto ?? '',
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.45,
                    color: Color(0xFF4B4B4B),
                  ),
                ),

                const SizedBox(height: 30),

                // Player de áudio
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 3),
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
                        Image.asset(
                          'lib/assets/img/sound.png',
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: AppButton(
                    label: 'RESPONDER A PERGUNTA',
                    onPressed: () {
                      _stopAudio();
                      Navigator.pushNamed(
                        context,
                        '/quiz',
                        arguments: {
                          'pergunta': _perguntaSelecionada!,
                          'trilha': _trilha,
                        },
                      );
                    },
                  ),
                ),

              ] else ...[
                                // ── Sem perguntas: mensagem + botões ───────────
                const SizedBox(height: 8),

                // Mensagem no lugar da descrição
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.green.shade600, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_rotulo[0].toUpperCase()}${_rotulo.substring(1)} registrad${_ehPredio ? 'o' : 'a'} com sucesso!\nContinue explorando a trilha.',
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: Color(0xFF4B4B4B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Botões — se finalizou trilha vai para /ganhou,
                // caso contrário mostra mapa e pontuação
                if (_marcandoLida)
                  const Center(child: CircularProgressIndicator())
                else if (_finalizouTrilha)
                  Center(
                    child: AppButton(
                      label: 'SEGUIR',
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        '/ganhou',
                      ),
                    ),
                  )
                else
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        AppButton(
                          label: 'IR AO MAPA',
                          onPressed: () =>
                              Navigator.pushReplacementNamed(
                                  context, '/mapa'),
                        ),
                        AppButton(
                          label: 'PONTUAÇÃO',
                          onPressed: () =>
                              Navigator.pushReplacementNamed(
                                  context, '/pontuacao'),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
