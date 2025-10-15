// lib/telas/tela_mapa.dart
import 'package:flutter/material.dart';
import '../models/map_spot.dart';
import '../widgets/overlayed_map.dart';
import '../widgets/bottom_nav.dart'; 
import '../services/api_cliente.dart'; 
import '../models/arvore.dart'; 
import '../models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});
  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _api = ApiClient();
  static const String _trilhaAtiva = 'Árvores Úteis';
  static const Size _mapSize = Size(650, 923);

  bool _isLoading = true;
  List<MapSpot> _allSpots = [];
  int? _activeId;
  
  int _arvoresVisitadas = 0; 
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _nickname = prefs.getString('ultimo_usuario');

      final List<Arvore> arvoreList = await _api.listarArvores(
        trilha: _trilhaAtiva,
        ativas: true,
      );
      
      Usuario? usuario = _nickname != null ? await _api.obterUsuario(_nickname!) : null;

      final spots = arvoreList.map((arvore) => MapSpot.fromArvore(arvore)).toList();

      spots.sort((a, b) {
        final ordemA = a.ordem;
        final ordemB = b.ordem;
        if (ordemA == ordemB) {
            return a.codigo.compareTo(b.codigo); 
        }
        return ordemA.compareTo(ordemB); 
      });

      if (!mounted) return;
      setState(() {
        _allSpots = spots;
        _arvoresVisitadas = usuario?.numArvoresVisitadas ?? 0;
        
        
        final proximaArvore = spots.firstWhereOrNull((spot) => spot.ordem > _arvoresVisitadas); 

        if (proximaArvore != null) {
            _activeId = proximaArvore.codigo;
        } else {
            // Se trilha completa ou falha na ordem, foca na última visitada (para visualização)
            final ultimaVisitada = spots.firstWhereOrNull((s) => s.ordem == _arvoresVisitadas);
            _activeId = ultimaVisitada?.codigo;
        }
      });
      
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar mapa: $e')),
         );
      }
      _allSpots = [];
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSpotTap(MapSpot s) {
    setState(() => _activeId = s.codigo);

    final proximaArvore = _allSpots.firstWhereOrNull((spot) => spot.ordem > _arvoresVisitadas); 
    
    final proximaOrdemEsperada = proximaArvore?.ordem;
    final isNext = s.ordem == proximaOrdemEsperada;
    
    final proximaArvoreTitulo = proximaArvore?.titulo ?? 'Trilha completa.'; 

    final isTrilhaRealmenteCompleta = proximaArvore == null; 

    if (isNext) {
        Navigator.pushNamed(
            context, 
            '/qrcode', 
            arguments: {
                'trilha': _trilhaAtiva,      
                'arvoreCodigo': s.codigo,    
                'titulo': s.titulo,          
            }
        ).then((_) => _carregarDados());
            
    } else if (isTrilhaRealmenteCompleta) {
        final msg = 'Parabéns, você completou a trilha! Você clicou em ${s.titulo} novamente.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    } else if (s.ordem <= _arvoresVisitadas) {
        final msg = 'Você já visitou a ${s.titulo}. Sua próxima parada é a ${proximaArvoreTitulo}.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    } else {
        final msg = 'Você clicou em ${s.titulo}. Sua próxima parada é a ${proximaArvoreTitulo}.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeSpots = _allSpots.where((s) => s.enabled).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF8BD600),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: OverlayedMap(
                    baseSize: _mapSize,
                    spots: activeSpots,
                    activeId: _activeId,
                    onSpotTap: _onSpotTap,
                    arvoresVisitadas: _arvoresVisitadas, 
                  ),
                ),
              ),
      ),
      bottomNavigationBar: const BottomNav(current: BottomTab.mapa),
    );
  }
}
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}