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

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToDicas({
    required String arvoreId,
    required String titulo,
    required int? numero,
    required String qr,
  }) async {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/dicas',
      arguments: {
        'arvoreId': arvoreId,
        'titulo': titulo,
        'numero': numero,
        'qr': qr,
      },
    );
  }

  void _onDetect(
    BarcodeCapture capture,
    String arvoreId,
    String titulo,
    int? numero,
  ) async {
    if (_handled) return;
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final value = barcode?.rawValue ?? '';
    if (value.isEmpty) return;

    _handled = true;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR lido de $titulo: $value'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 200));
    _goToDicas(arvoreId: arvoreId, titulo: titulo, numero: numero, qr: value);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
            {};
    final arvoreId = args['arvoreId'] as String? ?? 'desconhecida';
    final titulo   = args['titulo'] as String? ?? 'Árvore';
    final numero   = args['numero'] as int?;
    final titleText = numero != null ? 'Árvore $numero' : titulo;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER (igual ao painel) + seta voltar
            Container(
              width: double.infinity,
              color: AppColors.panelBg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.principal_title),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lendo QR de $titleText',
                          style: const TextStyle(
                            color: AppColors.principal_title,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Atalho de debug: simula leitura e vai para /dicas
                  if (kDebugMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => _goToDicas(
                          arvoreId: arvoreId,
                          titulo: titulo,
                          numero: numero,
                          qr: 'DEBUG-${DateTime.now().millisecondsSinceEpoch}',
                        ),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
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

            // SCANNER
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: (c) => _onDetect(c, arvoreId, titulo, numero),
                  ),
                  // Moldura/mira
                  LayoutBuilder(
                    builder: (context, c) {
                      final side = (c.maxWidth < c.maxHeight
                              ? c.maxWidth
                              : c.maxHeight) *
                          0.70;
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
                  // botões
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
