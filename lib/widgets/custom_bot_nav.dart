import 'package:byteback2/widgets/nav_icon.dart';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F5E3),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NavIcon(
            icon: Icons.home,
            selected: currentIndex == 0,
            onTap: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
          NavIcon(
            icon: Icons.search,
            selected: currentIndex == 1,
            onTap: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
          NavIcon(
            icon: Icons.menu,
            selected: currentIndex == 2,
            onTap: () => Navigator.pushReplacementNamed(context, '/main'),
          ),
        ],
      ),
    );
  }
}
