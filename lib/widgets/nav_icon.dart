import 'package:flutter/material.dart';

class NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const NavIcon({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: selected ? Colors.brown[200] : const Color(0xFFF8F5E3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.brown[200]!, width: 2),
        ),
        child: Icon(icon, color: Colors.brown[700], size: 32),
      ),
    );
  }
}
