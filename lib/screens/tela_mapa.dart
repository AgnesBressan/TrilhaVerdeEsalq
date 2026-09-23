import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ponto_interesse.dart';
import '../models/trofeu.dart';
import '../services/api_cliente.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';

const _geoapifyKey = 'b2a17618df4d494b941226565ac390bc';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _api = ApiClient();
  final _mapController = MapController();

  String? _trilhaNome;
  String? _nickname;

  // Pontos de interesse (árvores e prédios históricos) com coordenadas,
  // ordenados por posição relativa dentro da trilha.
  List<PontoInteresse> _pontos = [];
  // codigo -> posição relativa (1, 2, 3...)
  Map<int, int> _posicaoRelativa = {};
  Set<int> _codigosVisitados = {};

  bool _loading = true;
  bool _forcarMapa = false;
  String? _erro;
  PontoInteresse? _pontoInfo;

  static const _centroEsalq = LatLng(-22.7114, -47.6306);

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    final trilha = prefs.getString('trilha_selecionada');
    final nickname = prefs.getString('ultimo_usuario');

    if (trilha == null || trilha.isEmpty) {
      setState(() {
        _erro =
            'Nenhuma trilha selecionada.\nVolte à tela principal e escolha uma trilha.';
        _loading = false;
      });
      return;
    }

    setState(() {
      _trilhaNome = trilha;
      _nickname = nickname;
    });

    await _carregarDados(trilha, nickname);
  }

  Future<void> _carregarDados(String trilha, String? nickname) async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final resultados = await Future.wait([
        _api.listarPontosInteresse(trilha: trilha, ativas: true),
        if (nickname != null && nickname.isNotEmpty)
          _api.listarTrofeus(nickname)
        else
          Future.value(<Trofeu>[]),
      ]);

      final todosPontos = resultados[0] as List<PontoInteresse>;
      final trofeus = resultados[1] as List<Trofeu>;

      // Só os que têm coordenadas fazem parte da trilha jogável,
      // ordenados pelo campo ordem
      final comCoordenadas = todosPontos
          .where((p) => p.temCoordenadas)
          .toList()
        ..sort((a, b) => a.ordem.compareTo(b.ordem));

      // Monta posição relativa: codigo -> 1, 2, 3...
      final posicao = <int, int>{};
      for (int i = 0; i < comCoordenadas.length; i++) {
        posicao[comCoordenadas[i].codigo] = i + 1;
      }

      // Um troféu pertence à trilha se o ponto que ele referencia está
      // na lista de pontos da trilha (a tabela trofeu não guarda
      // trilha_nome — um ponto pode pertencer a mais de uma trilha).
      final codigosDaTrilha = comCoordenadas.map((p) => p.codigo).toSet();
      final visitados = trofeus
          .where((t) => codigosDaTrilha.contains(t.pontoInteresseCodigo))
          .map((t) => t.pontoInteresseCodigo)
          .toSet();

      setState(() {
        _pontos = comCoordenadas;
        _posicaoRelativa = posicao;
        _codigosVisitados = visitados;
        _loading = false;
      });

      // Centraliza no próximo ponto a ser lido
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        final proximo = _proximoALer();
        if (proximo != null) {
          _mapController.move(
            LatLng(proximo.latitude!, proximo.longitude!),
            18.0,
          );
        } else if (comCoordenadas.isNotEmpty) {
          _mapController.move(_calcularCentro(comCoordenadas), 17.5);
        }
      }
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar dados:\n$e';
        _loading = false;
      });
    }
  }

  LatLng _calcularCentro(List<PontoInteresse> pontos) {
    final lat = pontos.map((p) => p.latitude!).reduce((a, b) => a + b) /
        pontos.length;
    final lng = pontos.map((p) => p.longitude!).reduce((a, b) => a + b) /
        pontos.length;
    return LatLng(lat, lng);
  }

  bool _foiVisitado(PontoInteresse p) => _codigosVisitados.contains(p.codigo);

  int _posicao(PontoInteresse p) => _posicaoRelativa[p.codigo] ?? p.ordem;

  // Retorna o próximo ponto a ser lido (menor posição não visitada)
  PontoInteresse? _proximoALer() {
    final naoVisitados = _pontos
        .where((p) => !_foiVisitado(p))
        .toList();
    if (naoVisitados.isEmpty) return null;
    naoVisitados.sort((a, b) => _posicao(a).compareTo(_posicao(b)));
    return naoVisitados.first;
  }

  // Verifica se esse ponto é o próximo a ser lido
  bool _isProximo(PontoInteresse p) {
    final proximo = _proximoALer();
    return proximo?.codigo == p.codigo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNav(current: BottomTab.mapa),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                      ? _buildErro()
                      : _pontos.isEmpty && !_forcarMapa
                          ? _buildSemCoordenadas()
                          : _buildMapa(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final visitados = _codigosVisitados.length;
    final total = _pontos.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mapa da Trilha',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.principal_title,
                  ),
                ),
                const SizedBox(height: 4),
                if (_trilhaNome != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.speechBg32,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.route,
                            size: 14, color: AppColors.loginBg),
                        const SizedBox(width: 5),
                        Text(
                          _trilhaNome!,
                          style: const TextStyle(
                            color: AppColors.loginBg,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (total > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.speechBg32,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$visitados / $total',
                style: const TextStyle(
                  color: AppColors.loginBg,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemCoordenadas() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off,
                size: 72, color: Colors.orange.shade300),
            const SizedBox(height: 20),
            Text(
              'Pontos sem localização',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Os pontos de interesse da trilha "$_trilhaNome" ainda não possuem coordenadas geográficas cadastradas.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              'Entre em contato com o administrador para cadastrar as localizações.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.speechBg32,
                foregroundColor: AppColors.loginBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              onPressed: () => setState(() => _forcarMapa = true),
              icon: const Icon(Icons.map),
              label: const Text('Ver mapa mesmo assim'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapa() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _pontos.isNotEmpty
                ? _calcularCentro(_pontos)
                : _centroEsalq,
            initialZoom: 17.0,
            maxZoom: 20.0,
            minZoom: 13.0,
            onTap: (_, __) => setState(() => _pontoInfo = null),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$_geoapifyKey',
              userAgentPackageName: 'com.trilhaverde.app',
              maxZoom: 20,
              fallbackUrl:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: _pontos.map((ponto) {
                final proximo = _isProximo(ponto);
                final visitado = _foiVisitado(ponto);
                return Marker(
                  point: LatLng(ponto.latitude!, ponto.longitude!),
                  width: proximo ? 64 : 56,
                  height: proximo ? 76 : 68,
                  child: GestureDetector(
                    onTap: () => setState(() => _pontoInfo = ponto),
                    child: _PontoMarker(
                      posicao: _posicao(ponto),
                      tipo: ponto.tipo,
                      visitado: visitado,
                      proximo: proximo,
                      selected: _pontoInfo?.codigo == ponto.codigo,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Card do ponto selecionado
        if (_pontoInfo != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildCardPonto(_pontoInfo!),
          ),

        // Botão recentrar no próximo
        Positioned(
          top: 12,
          right: 12,
          child: FloatingActionButton.small(
            heroTag: 'recentrar',
            backgroundColor: Colors.white,
            elevation: 4,
            onPressed: () {
              final proximo = _proximoALer();
              if (proximo != null) {
                _mapController.move(
                  LatLng(proximo.latitude!, proximo.longitude!),
                  18.0,
                );
              } else if (_pontos.isNotEmpty) {
                _mapController.move(_calcularCentro(_pontos), 17.5);
              }
            },
            child: const Icon(Icons.my_location,
                color: Colors.green, size: 20),
          ),
        ),

        Positioned(
          top: 12,
          left: 12,
          child: _buildLegenda(),
        ),
      ],
    );
  }

  Widget _buildLegenda() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendaItem(
              color: const Color(0xFF2E7D32), label: 'Visitado'),
          const SizedBox(height: 4),
          _legendaItem(
              color: Colors.orange.shade600, label: 'Próximo'),
          const SizedBox(height: 4),
          _legendaItem(
              color: Colors.grey.shade400, label: 'Bloqueado'),
        ],
      ),
    );
  }

  Widget _legendaItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildCardPonto(PontoInteresse ponto) {
    final visitado = _foiVisitado(ponto);
    final proximo = _isProximo(ponto);
    final pos = _posicao(ponto);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PontoIcone(
                  posicao: pos,
                  tipo: ponto.tipo,
                  visitado: visitado,
                  proximo: proximo,
                  size: 64,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _badge(
                            '#$pos',
                            AppColors.speechBg32.withOpacity(0.35),
                            AppColors.principal_title,
                          ),
                          const SizedBox(width: 6),
                          _badge(
                            visitado
                                ? '✓ Visitado'
                                : proximo
                                    ? '📍 Próximo'
                                    : '🔒 Bloqueado',
                            visitado
                                ? Colors.green.shade100
                                : proximo
                                    ? Colors.orange.shade100
                                    : Colors.grey.shade200,
                            visitado
                                ? Colors.green.shade800
                                : proximo
                                    ? Colors.orange.shade800
                                    : Colors.grey.shade600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ponto.nome,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      if (ponto.especie != null &&
                          ponto.especie!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            ponto.especie!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _pontoInfo = null),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.close,
                        size: 20, color: Colors.black38),
                  ),
                ),
              ],
            ),

            // ── Botão Ler QR Code no estilo do login ──
            if (proximo) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.loginBg,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    setState(() => _pontoInfo = null);
                    Navigator.pushNamed(
                      context,
                      '/qrcode',
                      arguments: {
                        'trilha': _trilhaNome,
                        'arvoreCodigo': ponto.codigo,
                        'titulo': ponto.nome,
                        'qrcodeUrl': ponto.qrcodeUrl,
                      },
                    ).then((_) {
                      if (mounted && _trilhaNome != null) {
                        _carregarDados(_trilhaNome!, _nickname);
                      }
                    });
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text(
                    'LER QR CODE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],

            // ── Mensagem bloqueada ──
            if (!visitado && !proximo) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    'Leia os pontos anteriores primeiro',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ── Marcador no mapa ────────────────────────────────────────────
class _PontoMarker extends StatelessWidget {
  final int posicao;
  final String tipo;
  final bool visitado;
  final bool proximo;
  final bool selected;

  const _PontoMarker({
    required this.posicao,
    required this.tipo,
    required this.visitado,
    required this.proximo,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final size = proximo ? 52.0 : selected ? 48.0 : 40.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Anel pulsante ao redor do próximo ponto
        if (proximo)
          Container(
            width: size + 12,
            height: size + 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.shade400.withOpacity(0.5),
                width: 4,
              ),
            ),
            child: Center(
              child: _PontoIcone(
                posicao: posicao,
                tipo: tipo,
                visitado: visitado,
                proximo: proximo,
                size: size,
                selected: selected,
              ),
            ),
          )
        else
          _PontoIcone(
            posicao: posicao,
            tipo: tipo,
            visitado: visitado,
            proximo: proximo,
            size: size,
            selected: selected,
          ),
        CustomPaint(
          size: const Size(10, 7),
          painter: _PinTailPainter(
            color: visitado
                ? const Color(0xFF2E7D32)
                : proximo
                    ? Colors.orange.shade600
                    : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

// ── Ícone vetorial ──────────────────────────────────────────────
class _PontoIcone extends StatelessWidget {
  final int posicao;
  final String tipo;
  final bool visitado;
  final bool proximo;
  final double size;
  final bool selected;

  const _PontoIcone({
    required this.posicao,
    required this.tipo,
    required this.visitado,
    required this.proximo,
    required this.size,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = visitado
        ? const Color(0xFF2E7D32)
        : proximo
            ? Colors.orange.shade600
            : Colors.grey.shade400;

    final borderColor = selected
        ? Colors.white
        : visitado
            ? const Color(0xFF1B5E20)
            : proximo
                ? Colors.orange.shade800
                : Colors.grey.shade600;

    final iconeTipo =
        tipo == 'predio_historico' ? Icons.account_balance : Icons.park;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
            color: borderColor, width: selected ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            iconeTipo,
            color: Colors.white
                .withOpacity(visitado || proximo ? 1.0 : 0.7),
            size: size * 0.52,
          ),
          Positioned(
            bottom: size * 0.06,
            right: size * 0.06,
            child: Container(
              width: size * 0.36,
              height: size * 0.36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$posicao',
                  style: TextStyle(
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.w800,
                    color: visitado
                        ? const Color(0xFF2E7D32)
                        : proximo
                            ? Colors.orange.shade800
                            : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pontinha do pin ─────────────────────────────────────────────
class _PinTailPainter extends CustomPainter {
  final Color color;
  const _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    final path = ui.Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter old) =>
      old.color != color;
}
