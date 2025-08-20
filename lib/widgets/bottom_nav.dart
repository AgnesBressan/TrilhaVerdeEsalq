import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BottomTab { home, mapa, pontuacao, perfil }

class BottomNav extends StatelessWidget {
  final BottomTab current;
  const BottomNav({super.key, required this.current});

  void _go(BuildContext context, BottomTab t) {
    if (t == current) return;
    switch (t) {
      case BottomTab.home:
        Navigator.pushReplacementNamed(context, '/principal');
        break;
      case BottomTab.mapa:
        Navigator.pushReplacementNamed(context, '/mapa');
        break;
      case BottomTab.pontuacao:
        Navigator.pushReplacementNamed(context, '/pontuacao');
        break;
      case BottomTab.perfil:
        Navigator.pushReplacementNamed(context, '/perfil');
        break;
    }
  }

  Widget _item(BuildContext c, IconData icon, BottomTab t) {
    final selected = current == t;
    final iconWidget = Icon(icon, size: 24, color: AppColors.navIcon);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _go(c, t),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: selected
              ? Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.navActive,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: iconWidget),
                )
              : iconWidget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // nada de SafeArea(bottom:true) aqui — fica colado no rodapé
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.panelBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, Icons.home_rounded, BottomTab.home),
          _item(context, Icons.map_rounded, BottomTab.mapa),
          _item(context, Icons.emoji_events_rounded, BottomTab.pontuacao),
          _item(context, Icons.person_rounded, BottomTab.perfil),
        ],
      ),
    );
  }
}
