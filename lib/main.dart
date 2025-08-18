import 'package:flutter/material.dart';
import 'package:trilha_verde_esalq/screens/tela_mapa.dart';
import 'screens/tela_principal.dart';
import 'screens/tela_inicio.dart';
import 'screens/tela_login.dart';
import 'screens/tela_menu.dart';
import 'screens/tela_perfil.dart';
import 'screens/tela_qrcode.dart';
import 'screens/tela_pontuacao.dart';

void main() {
  runApp(const TrilhaVerdeApp());
}

class TrilhaVerdeApp extends StatelessWidget {
  const TrilhaVerdeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trilha Verde',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaInicial(),
        '/login': (context) => TelaLogin(),
        '/principal': (context) => const TelaPrincipal(),
        '/menu': (context) => const TelaMenu(),
        '/perfil': (context) => const TelaPerfil(),
        '/qrcode': (context) => const TelaQRCode(),
        '/pontuacao': (context) => const TelaPontuacao(),
        '/mapa': (context) => const TelaMapa(),
      },

    );
  }
}

