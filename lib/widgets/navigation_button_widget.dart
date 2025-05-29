import 'package:flutter/material.dart';

class NavigationButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const NavigationButtonWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}