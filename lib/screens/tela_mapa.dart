import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/interactive_map.dart';
import '../models/map_spot.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  String? imagePath;
  bool isLoading = true;

  // Tamanho nativo do PNG do mapa (ajuste se usar outro asset)
  static const Size _mapSize = Size(395, 574);

  // Hotspots já com as coordenadas normalizadas que você levantou
  final List<MapSpot> _spots = const [
    MapSpot(id: 'arvore_1',  titulo: 'Árvore 1',  pos: Offset(0.6037, 0.8075)),
    MapSpot(id: 'arvore_2',  titulo: 'Árvore 2',  pos: Offset(0.5555, 0.7551)),
    MapSpot(id: 'arvore_3',  titulo: 'Árvore 3',  pos: Offset(0.5555, 0.6456)),
    MapSpot(id: 'arvore_4',  titulo: 'Árvore 4',  pos: Offset(0.4851, 0.4345)),
    MapSpot(id: 'arvore_5',  titulo: 'Árvore 5',  pos: Offset(0.3761, 0.2812)),
    MapSpot(id: 'arvore_6',  titulo: 'Árvore 6',  pos: Offset(0.5275, 0.0476)),
    MapSpot(id: 'arvore_7',  titulo: 'Árvore 7',  pos: Offset(0.2565, 0.1744)),
    MapSpot(id: 'arvore_8',  titulo: 'Árvore 8',  pos: Offset(0.2440, 0.2162)),
    MapSpot(id: 'arvore_9',  titulo: 'Árvore 9',  pos: Offset(0.0665, 0.2706)),
    MapSpot(id: 'arvore_10', titulo: 'Árvore 10', pos: Offset(0.1273, 0.3038)),
    MapSpot(id: 'arvore_11', titulo: 'Árvore 11', pos: Offset(0.3684, 0.6555)),
    MapSpot(id: 'arvore_12', titulo: 'Árvore 12', pos: Offset(0.3173, 0.6800)),
    MapSpot(id: 'arvore_13', titulo: 'Árvore 13', pos: Offset(0.3298, 0.7219)),
  ];

  int _nextNumber = 1;   // próxima árvore que o usuário deve visitar
  String? _activeId;     // id da próxima (ex.: "arvore_3")

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome_usuario') ?? 'usuário';
    final key = 'arvores_lidas_$nome';
    final lidas = prefs.getStringList(key) ?? [];

    // próxima = (quantas lidas) + 1, limitado ao total
    _nextNumber = (lidas.length + 1).clamp(1, _spots.length);
    _activeId = 'arvore_$_nextNumber';

    // imagem de progresso (sua lógica antiga, mantida)
    final qtdArvoresLidas = lidas.length + 1;
    setState(() {
      if (qtdArvoresLidas <= 0) {
        imagePath = 'lib/assets/img/planta(1).png';
      } else if (qtdArvoresLidas < 28) {
        final numImagem = qtdArvoresLidas + 1;
        imagePath = 'lib/assets/img/planta($numImagem).png';
      } else {
        imagePath = 'lib/assets/img/planta(1).png';
      }
      isLoading = false;
    });
  }

  int _numeroDaArvore(MapSpot s) {
    final m = RegExp(r'(\d+)$').firstMatch(s.id);
    return m == null ? -1 : int.parse(m.group(1)!);
  }

  void _onSpotTap(MapSpot s) {
    final n = _numeroDaArvore(s);
    final msgSel = 'Selecionou ${s.titulo} (#$n)';
    debugPrint('🗺️ $msgSel'); // console

    if (n == _nextNumber) {
      // feedback curto antes de abrir a câmera
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$msgSel — abrindo câmera...'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ),
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/qrcode',
          arguments: {
            'arvoreId': s.id,
            'titulo': s.titulo,
            'numero': n,
          },
        );
      });
    } else if (n > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Esta é ${s.titulo}. Sua próxima visita é para a Árvore $_nextNumber.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BD600),
      bottomNavigationBar: const BottomNav(current: BottomTab.mapa),
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // centraliza com largura ~90% da tela
                    final baseWidth = constraints.maxWidth * 0.9;
                    final baseHeight =
                        baseWidth / (_mapSize.width / _mapSize.height);
                    return SizedBox(
                      width: baseWidth,
                      height: baseHeight,
                      child: InteractiveMap(
                        imageAsset: imagePath!,
                        imageSize: _mapSize,
                        spots: _spots,
                        onSpotTap: _onSpotTap,
                        activeId: _activeId,
                        adaptiveHit: true,   // hitbox continua adaptativa para facilitar o clique
                        minHitPx: 18,
                        maxHitPx: 34,
                        hitRatio: 0.38,
                        activeRingRadiusPx: 15,         // <- anel SEMPRE do mesmo tamanho (menor)
                        activeRingStroke: 2.5,          // opcional
                        // activeRingColor: Colors.white.withOpacity(0.9), // opcional
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
