import 'package:flutter/material.dart';
import '../services/api_cliente.dart'; // [NOVO] Importe o ApiClient

class TelaMenu extends StatefulWidget { // [ALTERADO] Para StatefulWidget
  const TelaMenu({super.key});

  @override
  State<TelaMenu> createState() => _TelaMenuState();
}

class _TelaMenuState extends State<TelaMenu> { // [NOVO] Classe de estado
  final _api = ApiClient(); // Instancia o cliente da API

  // [NOVO] Função de logout que chama a API e depois navega
  Future<void> _onSair() async {
    await _api.sair(); // Limpa os dados da sessão (SharedPreferences)
    if (mounted) {
      // Navega para o login e remove todas as telas anteriores
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF90E0D4),
      appBar: AppBar(
        // ... seu AppBar continua igual
        backgroundColor: const Color(0xFF90E0D4),
        elevation: 0,
        automaticallyImplyLeading: true,
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/principal');
          },
          child: Image.asset('lib/assets/img/logo.png', height: 40),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'MENU',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // [ALTERADO] Os MenuItems agora usam 'onPressed' para mais flexibilidade
              MenuItem(
                icon: Icons.emoji_events,
                label: 'Pontuação',
                onPressed: () => Navigator.pushReplacementNamed(context, '/pontuacao'),
              ),
              MenuItem(
                icon: Icons.person,
                label: 'Perfil',
                onPressed: () => Navigator.pushReplacementNamed(context, '/perfil'),
              ),
              MenuItem(
                icon: Icons.map,
                label: 'Mapa',
                onPressed: () => Navigator.pushReplacementNamed(context, '/mapa'),
              ),
              MenuItem(
                icon: Icons.logout,
                label: 'Sair',
                onPressed: _onSair, // Chama nossa nova função de logout
              ),
              MenuItem(
                icon: Icons.phone,
                label: 'Contato',
                onPressed: () => Navigator.pushReplacementNamed(context, '/contato'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed; // [ALTERADO] De 'String rota' para 'VoidCallback'

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed, // [ALTERADO]
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onPressed, // [ALTERADO] Simplesmente chama a função passada
        child: Row(
          children: [
            // ... o resto do seu MenuItem continua igual e está perfeito
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE5E5E5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}