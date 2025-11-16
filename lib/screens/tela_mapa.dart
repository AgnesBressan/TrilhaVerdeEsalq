import 'package:flutter/material.dart';
import '../models/map_spot.dart';
import '../widgets/overlayed_map.dart';
import '../widgets/bottom_nav.dart'; 
import '../services/api_cliente.dart'; 
import '../models/arvore.dart'; 
import '../models/usuario.dart';
import '../models/trofeu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer'; // Importante para usar log()


class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});
  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _api = ApiClient();
  static const String _trilhaAtiva = 'Árvores Úteis';
  static const Size _mapSize = Size(395, 562); 

  bool _isLoading = true;
  List<MapSpot> _allSpots = [];
  int? _activeId;
  
  Set<int> _arvoresVisitadasCodigos = <int>{}; 
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

      final resultados = await Future.wait([
        _api.listarArvores(trilha: _trilhaAtiva, ativas: true),
        _nickname != null ? _api.listarTrofeus(_nickname!) : Future.value(<Trofeu>[]),
        _nickname != null ? _api.obterUsuario(_nickname!) : Future.value(null),
      ]);

      final List<Arvore> arvoreList = resultados[0] as List<Arvore>;
      final List<Trofeu> trofeus = resultados[1] as List<Trofeu>;

      final spots = arvoreList.map((arvore) => MapSpot.fromArvore(arvore)).toList();

      spots.sort((a, b) {
        return a.ordem.compareTo(b.ordem) != 0 
               ? a.ordem.compareTo(b.ordem)
               : a.codigo.compareTo(b.codigo);
      });

      if (!mounted) return;
      setState(() {
        _allSpots = spots; 
        
        final trofeusDaTrilha = trofeus.where((t) => t.trilhaNome == _trilhaAtiva).toList();
        final visitadasSet = trofeusDaTrilha.map((t) => t.arvoreCodigo).toSet();
        _arvoresVisitadasCodigos = visitadasSet;

        final proximaArvore = spots.firstWhereOrNull(
          (spot) => !visitadasSet.contains(spot.codigo),
        );

        _activeId = proximaArvore?.codigo;
        
        log('Mapa carregado. Total Ativas: ${spots.length}. Visitadas: ${visitadasSet.length}. Próximo Foco: ${proximaArvore?.titulo ?? "Nenhuma"}');
      });
      
    } catch (e) {
      log('ERRO no carregamento do mapa: $e');
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
    // 🔍 LOG 1: Confirma se a função foi chamada
    log('CLIQUE NO MAPA detectado. Árvore clicada: ${s.titulo} (${s.codigo}). Árvore esperada: ${_activeId}');

    // 1. Encontra a próxima árvore (foco) para dar a mensagem correta
    final proximaArvoreSpot = _allSpots.firstWhereOrNull(
      (spot) => spot.codigo == _activeId,
    );
    
    // 2. Lógica para Árvore ERRADA (não é a _activeId)
    if (s.codigo != _activeId) {
      // 🔍 LOG 2: Entrou na lógica de erro (árvore errada)
      log('FLUXO: Árvore ${s.codigo} é a errada. Exibindo SnackBar.');

      final arvoreNome = s.titulo;
      final arvoreCodigo = s.codigo;
      
      String mensagem;
      if (proximaArvoreSpot != null) {
        // Encontrou a próxima árvore para guiar o usuário
        final proximaNome = proximaArvoreSpot.titulo;
        final proximaCodigo = proximaArvoreSpot.codigo;
        mensagem = 'Você clicou na $arvoreNome ($arvoreCodigo). A próxima árvore a ser visitada é a $proximaNome ($proximaCodigo). Siga a ordem da trilha!';
      } else {
        // Todas as árvores foram lidas
        mensagem = 'Você clicou na $arvoreNome ($arvoreCodigo). Parabéns, você já visitou todas as árvores ativas da trilha!';
      }

      if (mounted) {
        // Exibe o SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mensagem, 
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return; 
    }

    // 3. Lógica para Árvore CORRETA (é a _activeId)
    // 🔍 LOG 3: Entrou na lógica de sucesso (navegação)
    log('FLUXO: Árvore ${s.codigo} é a correta. Navegando para /qrcode.');
    
    Navigator.pushNamed(
      context,
      '/qrcode',
      arguments: {
        'trilha': _trilhaAtiva,
        'arvoreCodigo': s.codigo,
        'titulo': s.titulo,
      },
    ).then((_) => _carregarDados()); 
  }

  @override
  Widget build(BuildContext context) {
    final activeSpots = _allSpots; 

    return Scaffold(
      backgroundColor: const Color(0xFF8BD600),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: OverlayedMap(
                    baseSize: _mapSize,
                    spots: activeSpots, 
                    activeId: _activeId,
                    onSpotTap: _onSpotTap,
                    visitedCodigos: _arvoresVisitadasCodigos, 
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