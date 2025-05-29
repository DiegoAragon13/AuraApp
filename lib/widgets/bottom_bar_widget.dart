import 'package:flutter/material.dart';

class BottomBarWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1FF), // Color lavanda claro similar a la imagen
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            0,
            Icons.home,
            'Home',
            const Color(0xFF4A3B80), // Color morado para el texto e icono seleccionado
          ),
          _buildNavItem(
            context,
            1,
            Icons.favorite_outline,
            'Medicion',
            const Color(0xFF4A3B80),
          ),
          _buildNavItem(
            context,
            2,
            Icons.show_chart,
            'Análisis',
            const Color(0xFF4A3B80),
          ),
          _buildNavItem(
            context,
            3,
            Icons.menu_book_outlined,
            'Educación',
            const Color(0xFF4A3B80),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, Color activeColor) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? activeColor : Colors.grey;

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}