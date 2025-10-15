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
      final parts = qrCodeData.split(';');
      final trilhaLida = parts[0];
      final codigoLido = int.parse(parts[1]);

      if (trilhaLida == _trilhaEsperada && codigoLido == _arvoreCodigoEsperado) {
        Navigator.pushReplacementNamed(
          context,
          '/dicas',
          arguments: {
            'trilha': _trilhaEsperada,
            'arvoreCodigo': _arvoreCodigoEsperado,
          },
        );
      } else {
        _mostrarErroEVoltar('Você escaneou o QR Code da árvore errada!');
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

  @override
  Widget build(BuildContext context) {
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
                          'Lendo QR de ${_tituloArvore ?? "..."}',
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