import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_colors.dart';

class TelaQRCode extends StatefulWidget {
  const TelaQRCode({super.key});

  @override
  State<TelaQRCode> createState() => _TelaQRCodeState();
}

class _TelaQRCodeState extends State<TelaQRCode> {
  final _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  static const List<String> _codigoKeys = [
    'codigo',
    'cod',
    'arvore',
    'arvorecodigo',
    'narvore',
    'id',
    'tree',
    'numero',
    'num',
    'numeroarvore',
  ];
  static const List<String> _trilhaKeys = [
    'trilha',
    'trail',
    'rota',
    'route',
    'trilha_nome',
    'trilhanome',
  ];
  static const Map<String, String> _accentMap = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'å': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };

  String? _trilhaEsperada;
  int? _arvoreCodigoEsperado;
  String? _tituloArvore;
  bool _handledScan = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?);
    if (args != null) {
      _trilhaEsperada = args['trilha'] as String?;
      _arvoreCodigoEsperado = args['arvoreCodigo'] as int?; 
      _tituloArvore = args['titulo'] as String?; 
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDebugTap() {
    if (_trilhaEsperada != null && _arvoreCodigoEsperado != null) {
      Navigator.pushReplacementNamed(
        context,
        '/dicas',
        arguments: {
          'trilha': _trilhaEsperada,
          'arvoreCodigo': _arvoreCodigoEsperado,
        },
      );
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handledScan) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final qrCodeData = barcode?.rawValue ?? '';
    if (qrCodeData.isEmpty) return;
    
    _handledScan = true;
    _controller.stop();

    try {
      final payload = _parseQrPayload(qrCodeData);
      if (payload == null) {
        _mostrarErroEVoltar('Este QR Code não parece ser válido.');
        return;
      }

      final codigoOk = _arvoreCodigoEsperado == null || payload.codigo == _arvoreCodigoEsperado;
      final trilhaOk = _matchesTrilha(payload.trilha);

      if (codigoOk && trilhaOk) {
        Navigator.pushReplacementNamed(
          context,
          '/dicas',
          arguments: {
            'trilha': _trilhaEsperada,
            'arvoreCodigo': _arvoreCodigoEsperado,
          },
        );
      } else {
        final codigoMsg = payload.codigo.toString();
        _mostrarErroEVoltar('Você escaneou o QR Code da árvore errada! (lido $codigoMsg)');
      }
    } catch (e) {
      _mostrarErroEVoltar('Este QR Code não parece ser válido.');
    }
  }

  void _mostrarErroEVoltar(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  _QrPayload? _parseQrPayload(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return null;

    int? codigo;
    String? trilha;

    int? tryParseInt(String? value) {
      if (value == null) return null;
      final parsed = int.tryParse(value.trim());
      return parsed;
    }

    void tryFromTokens(Iterable<String> tokens) {
      for (final token in tokens) {
        final current = token.trim();
        if (current.isEmpty) continue;

        final eqIndex = current.indexOf('=');
        final colonIndex = current.indexOf(':');
        String? key;
        String? value;

        if (eqIndex > 0) {
          key = current.substring(0, eqIndex).trim().toLowerCase();
          value = current.substring(eqIndex + 1).trim();
        } else if (colonIndex > 0) {
          key = current.substring(0, colonIndex).trim().toLowerCase();
          value = current.substring(colonIndex + 1).trim();
        }

        if (key != null && value != null) {
          if (_codigoKeys.contains(key) && codigo == null) {
            codigo = tryParseInt(value);
          }
          if (_trilhaKeys.contains(key) && (trilha == null || trilha!.isEmpty)) {
            trilha = value;
          }
        }
      }
    }

    codigo = tryParseInt(cleaned);
    if (codigo != null) {
      return _QrPayload(codigo: codigo!, trilha: trilha);
    }

    final uri = Uri.tryParse(cleaned);
    if (uri != null && (uri.hasScheme || cleaned.startsWith('http') || cleaned.startsWith('www.'))) {
      for (final key in _codigoKeys) {
        if (codigo != null) break;
        codigo = tryParseInt(uri.queryParameters[key]);
      }
      for (final key in _trilhaKeys) {
        if (trilha != null && trilha!.isNotEmpty) break;
        final value = uri.queryParameters[key];
        if (value != null && value.trim().isNotEmpty) {
          trilha = value;
        }
      }
      if (codigo == null) {
        for (final segment in uri.pathSegments.reversed) {
          final parsed = tryParseInt(segment);
          if (parsed != null) {
            codigo = parsed;
            break;
          }
        }
      }

      if (codigo != null) {
        trilha = trilha?.replaceAll('+', ' ').trim();
        return _QrPayload(codigo: codigo!, trilha: trilha);
      }
    }

    final normalizedTokens = cleaned
        .replaceAll(RegExp(r'[\r\n]+'), ';')
        .split(RegExp(r'[;,|]'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (normalizedTokens.isNotEmpty) {
      tryFromTokens(normalizedTokens);

      if (codigo == null) {
        final possibleCode = tryParseInt(normalizedTokens.last);
        if (possibleCode != null) {
          codigo = possibleCode;
          if (normalizedTokens.length > 1) {
            trilha ??= normalizedTokens.sublist(0, normalizedTokens.length - 1).join(' ');
          }
        }
      }
    }

    if (codigo == null) {
      final matches = RegExp(r'(\d{2,})').allMatches(cleaned).toList();
      if (matches.isNotEmpty) {
        matches.sort((a, b) => a.group(0)!.length.compareTo(b.group(0)!.length));
        final candidate = matches.last.group(0);
        codigo = tryParseInt(candidate);
      }
    }

    if (codigo == null) return null;
    return _QrPayload(codigo: codigo!, trilha: trilha);
  }

  bool _matchesTrilha(String? trilhaLida) {
    if (_trilhaEsperada == null || _trilhaEsperada!.trim().isEmpty) return true;
    if (trilhaLida == null || trilhaLida.trim().isEmpty) return true;

    final esperado = _normalizeText(_trilhaEsperada!);
    final lido = _normalizeText(trilhaLida);

    return esperado == lido || esperado.contains(lido) || lido.contains(esperado);
  }

  String _normalizeText(String value) {
    final lower = value.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accentMap[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    // Constrói a string do código da árvore (ex: "(123)" ou "")
    final codigoStr = _arvoreCodigoEsperado != null ? ' ($_arvoreCodigoEsperado)' : '';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.panelBg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.principal_title),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // ALTERAÇÃO AQUI: Adiciona o código da árvore
                          'Lendo QR de ${_tituloArvore ?? "..."}$codigoStr', 
                          style: const TextStyle(
                            color: AppColors.principal_title,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (kDebugMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: _onDebugTap,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27C46B),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Debug', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                  LayoutBuilder(
                    builder: (context, c) {
                      final side = (c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight) * 0.70;
                      return Center(
                        child: Container(
                          width: side,
                          height: side,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.9),
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RoundIcon(
                          icon: Icons.flash_on_rounded,
                          onTap: () => _controller.toggleTorch(),
                        ),
                        _RoundIcon(
                          icon: Icons.cameraswitch_rounded,
                          onTap: () => _controller.switchCamera(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrPayload {
  final int codigo;
  final String? trilha;

  const _QrPayload({required this.codigo, this.trilha});
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}