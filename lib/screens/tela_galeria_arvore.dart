import 'package:flutter/material.dart';
import '../models/imagem.dart';

class TelaGaleriaArvore extends StatefulWidget {
  const TelaGaleriaArvore({super.key});

  @override
  State<TelaGaleriaArvore> createState() => _TelaGaleriaArvoreState();
}

class _TelaGaleriaArvoreState extends State<TelaGaleriaArvore> {
  final _pageController = PageController();
  int _paginaAtual = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatarLinkImagem(String url) {
    final texto = url.trim();

    if (texto.contains('drive.google.com')) {
      final uri = Uri.tryParse(texto);

      if (uri != null) {
        final segments = uri.pathSegments;

        final dIndex = segments.indexOf('d');
        if (dIndex != -1 && dIndex + 1 < segments.length) {
          final fileId = segments[dIndex + 1];
          return 'https://drive.google.com/uc?export=view&id=$fileId';
        }

        final id = uri.queryParameters['id'];
        if (id != null && id.isNotEmpty) {
          return 'https://drive.google.com/uc?export=view&id=$id';
        }
      }
    }

    return texto;
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final List<Imagem> imagens =
        (args['imagens'] as List?)?.cast<Imagem>() ?? const [];
    final String nomePonto =
        (args['nomePonto'] ?? 'Ponto de Interesse').toString();

    return Scaffold(
      backgroundColor: const Color(0xFF8BD600),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      nomePonto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (imagens.isEmpty)
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nenhuma imagem disponível.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else ...[
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: imagens.length,
                  onPageChanged: (i) => setState(() => _paginaAtual = i),
                  itemBuilder: (context, index) {
                    final imageUrl = _formatarLinkImagem(imagens[index].url);
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 5.0,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'Erro ao carregar a imagem.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildLegenda(imagens[_paginaAtual]),
              if (imagens.length > 1) _buildIndicadores(imagens.length),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegenda(Imagem imagem) {
    final legenda = imagem.legenda?.trim();
    final fonte = imagem.fonte?.trim();
    if ((legenda == null || legenda.isEmpty) && (fonte == null || fonte.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (legenda != null && legenda.isNotEmpty)
            Text(
              legenda,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (fonte != null && fonte.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Fonte: $fonte',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicadores(int total) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final ativo = i == _paginaAtual;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: ativo ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(ativo ? 1.0 : 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
