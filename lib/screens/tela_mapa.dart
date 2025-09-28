import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_cliente.dart';
import '../models/trofeu.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/interactive_map.dart';
import '../models/map_spot.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _api = ApiClient();
  bool isLoading = true;

  static const Size _mapSize = Size(395, 574);

  final List<MapSpot> _spots = const [
    MapSpot(id: 'arvore_4850', titulo: 'Eritrina',          pos: Offset(0.6037, 0.8075)),
    MapSpot(id: 'arvore_5433', titulo: 'Pau-Jacaré',        pos: Offset(0.5555, 0.7551)),
    MapSpot(id: 'arvore_3957', titulo: 'Cambará',           pos: Offset(0.5555, 0.6456)),
    MapSpot(id: 'arvore_4',    titulo: 'Ipê-Amarelo',       pos: Offset(0.4851, 0.4345)),
    MapSpot(id: 'arvore_3994', titulo: 'Chuva-de-Ouro',     pos: Offset(0.3761, 0.2812)),
    MapSpot(id: 'arvore_4040', titulo: 'Abricó-de-Macaco',  pos: Offset(0.5275, 0.0476)),
    MapSpot(id: 'arvore_3846', titulo: 'Ipê-Branco',        pos: Offset(0.2565, 0.1744)),
    MapSpot(id: 'arvore_1345', titulo: 'Jequitibá-Rosa',    pos: Offset(0.2440, 0.2162)),
    MapSpot(id: 'arvore_1297', titulo: 'Coração-de-Negro',  pos: Offset(0.0665, 0.2706)),
    MapSpot(id: 'arvore_1367', titulo: 'Seringueira',       pos: Offset(0.1273, 0.3038)),
    MapSpot(id: 'arvore_1362', titulo: 'Escovinha',         pos: Offset(0.3684, 0.6555)),
    MapSpot(id: 'arvore_3990', titulo: 'Flor-de-Abril',     pos: Offset(0.3173, 0.6800)),
    MapSpot(id: 'arvore_593',  titulo: 'Imbiriçu',          pos: Offset(0.3298, 0.7219)),
  ];

  final List<int> _ordemDasArvores = const [4850, 5433, 3957, 4, 3994, 4040, 3846, 1345, 1297, 1367, 1362, 3990, 593];
  
  int? _nextTreeCode;
  String? _activeId;
  String? imagePath; // <-- Alterado de volta para 'imagePath' como no seu original

  @override
  void initState() {
    super.initState();
    _loadProgressFromBackend();
  }

  // [ALTERADO] A lógica de imagem progressiva foi restaurada aqui
  Future<void> _loadProgressFromBackend() async {
    setState(() => isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final nickname = prefs.getString('ultimo_usuario');

      if (nickname == null) {
        throw Exception("Usuário não logado");
      }

      final List<Trofeu> userTrophies = await _api.listarTrofeus(nickname);
      final Set<int> conqueredTreeCodes = userTrophies.map((t) => t.arvoreCodigo).toSet();

      int? nextCode;
      for (final treeCode in _ordemDasArvores) {
        if (!conqueredTreeCodes.contains(treeCode)) {
          nextCode = treeCode;
          break;
        }
      }

      // [LÓGICA RESTAURADA] Calcula o nome da imagem com base no número de troféus
      String newImagePath;
      final int arvoresConquistadas = userTrophies.length;

      // Supondo que você tenha imagens como 'planta(1).png', 'planta(2).png', etc.
      if (arvoresConquistadas >= _spots.length) {
        // Trilha completa, talvez mostrar a planta final
        newImagePath = 'lib/assets/img/planta_completa.png'; // Exemplo
      } else {
        // O número da imagem é a quantidade de árvores lidas + 1
        final numImagem = arvoresConquistadas + 1;
        newImagePath = 'lib/assets/img/planta($numImagem).png';
      }

      setState(() {
        _nextTreeCode = nextCode;
        _activeId = _nextTreeCode != null ? 'arvore_$_nextTreeCode' : null;
        imagePath = newImagePath; // Define a imagem correta
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        _activeId = null;
        imagePath = 'lib/assets/img/planta(1).png'; // Imagem padrão em caso de erro
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar progresso: $e')),
      );
    }
  }
  
  // O resto do seu código (onSpotTap, build, etc.) continua igual ao da última versão
  
  int _getCodigoDoSpot(MapSpot s) {
    return int.tryParse(s.id.split('_').last) ?? -1;
  }

  void _onSpotTap(MapSpot s) {
    final codigoArvoreTocada = _getCodigoDoSpot(s);

    if (_nextTreeCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parabéns! Você concluiu a trilha!')),
      );
      return;
    }

    if (codigoArvoreTocada == _nextTreeCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Você selecionou ${s.titulo}! Abrindo câmera...'),
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
            'trilha': 'Árvores Úteis',
            'arvoreCodigo': codigoArvoreTocada,
            'titulo': s.titulo,
          },
        );
      });
    } else {
      final proximoSpot = _spots.firstWhere((spot) => _getCodigoDoSpot(spot) == _nextTreeCode, orElse: () => s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta é a ${s.titulo}. Sua próxima visita é na ${proximoSpot.titulo}.'),
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
                    final baseWidth = constraints.maxWidth * 0.9;
                    final baseHeight = baseWidth / (_mapSize.width / _mapSize.height);
                    return SizedBox(
                      width: baseWidth,
                      height: baseHeight,
                      child: InteractiveMap(
                        imageAsset: imagePath!,
                        imageSize: _mapSize,
                        spots: _spots,
                        onSpotTap: _onSpotTap,
                        activeId: _activeId,
                        adaptiveHit: true,
                        minHitPx: 18,
                        maxHitPx: 34,
                        hitRatio: 0.38,
                        activeRingRadiusPx: 15,
                        activeRingStroke: 2.5,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}