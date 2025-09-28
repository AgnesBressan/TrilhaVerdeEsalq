import 'package:flutter/material.dart';

class QRCodeWeb extends StatelessWidget {
  const QRCodeWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF90E0D4),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('lib/assets/img/logo.png', height: 40),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(context, '/menu');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ElevatedButton(
          // [ALTERADO] A navegação agora envia os argumentos necessários
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/quiz',
              arguments: {
                'trilha': 'Árvores Úteis', // Simula a trilha
                'arvoreCodigo': 4850,      // Simula a 1ª árvore (Eritrina)
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[300],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('Simular leitura do QR Code'),
        ),
      ),
    );
  }
}

// 🔧 Stub da classe mobile (apenas para evitar erro de compilação na web)
class QRCodeMobile extends StatelessWidget {
  const QRCodeMobile({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // nunca será exibido
  }
}