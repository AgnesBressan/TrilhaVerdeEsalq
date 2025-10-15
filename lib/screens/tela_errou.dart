import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button.dart';
import '../models/pergunta.dart'; // Importa o modelo Pergunta

class TelaErrou extends StatefulWidget {
  final Pergunta pergunta;

  const TelaErrou({super.key, required this.pergunta});

  @override
  State<TelaErrou> createState() => _TelaErrouState();
}

class _TelaErrouState extends State<TelaErrou> {
  late final AudioPlayer player;
  PlayerState? _playerState; 

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();

    player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    player.stop(); 
    player.dispose();
    super.dispose();
  }

  Future<void> _toggleAudioPlayback() async {
    final audioDicaUrl = widget.pergunta.audioDicaUrl;

    if (audioDicaUrl == null || audioDicaUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma dica em áudio disponível.')),
      );
      return;
    }

    if (_playerState == PlayerState.playing) {
      await player.pause();
    } else {
      await player.play(UrlSource(audioDicaUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dicaTexto = widget.pergunta.dica ?? 'Nenhuma dica disponível.'; // Puxa o campo 'dica'
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 200,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 96),
            ),
            Positioned(
              top: size.height * 0.30,
              left: 36,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 68),
            ),
            Positioned(
              top: size.height * 0.40,
              right: 36,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 110),
            ),
            Positioned(
              bottom: 200,
              left: 26,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 60),
            ),
            Positioned(
              bottom: 70,
              right: 30,
              child: Image.asset('lib/assets/img/pequena_nuvem.png', width: 64),
            ),
            Positioned(
              bottom: 20,
              left: 80,
              child: Image.asset('lib/assets/img/grande_nuvem.png', width: 100),
            ),
            
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'VOCÊ ERROU,\nOUÇA A DICA E\nTENTE NOVAMENTE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF8F3D3D),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Image.asset('lib/assets/img/errou.png', width: 190),
                    const SizedBox(height: 22),
                    
                    // [TEXTO DA DICA]
                    Container(
                      constraints: BoxConstraints(maxWidth: size.width * 0.85),
                      child: Text(
                        dicaTexto,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                          color: Color(0xFF4B4B4B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),


                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
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
                            Image.asset('lib/assets/img/sound.png', height: 30),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    AppButton(
                      label: 'TENTAR NOVAMENTE',
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
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