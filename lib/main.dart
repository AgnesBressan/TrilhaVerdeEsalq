import 'package:flutter/material.dart';
import 'package:trilha_verde_esalq/screens/tela_inicio.dart';
import 'screens/tela_login.dart';
import 'screens/tela_home.dart';
import 'screens/tela_principal.dart';
import 'screens/tela_menu.dart';
import 'screens/tela_perfil.dart';
import 'screens/tela_qrcode.dart';
import 'screens/tela_pontuacao.dart';
import 'screens/tela_mapa.dart';
import 'screens/tela_cadastro.dart';
import 'screens/tela_dicas.dart';
import 'screens/tela_quiz.dart';
import 'screens/tela_acertou.dart';
import 'screens/tela_errou.dart';
import 'screens/tela_tutorial.dart';

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
      theme: ThemeData(
        fontFamily: 'Poppins', // fonte global
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaInicial(),
        '/login': (context) => TelaLogin(),
        '/home': (context) => const TelaHome(),
        '/cadastro': (context) => const TelaCadastro(),
        '/principal': (context) => const TelaPrincipal(),
        '/menu': (context) => const TelaMenu(),
        '/perfil': (context) => const TelaPerfil(),
        '/qrcode': (context) => const TelaQRCode(),
        '/pontuacao': (context) => const TelaPontuacao(),
        '/mapa': (context) => const TelaMapa(),
        '/dicas':  (context) => const TelaDicas(),
        '/quiz':   (context) => const TelaQuiz(),
        '/acertou': (context) => const TelaAcertou(),
        '/errou': (context) => const TelaErrou(),
        '/tutorial': (context) => const TelaTutorial(),
      },
    );
  }
}
