import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int notificationCount;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    this.notificationCount = 0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: const Text(
        '',
        style: TextStyle(

        ),
      ),
      centerTitle: false,
      backgroundColor: backgroundColor ?? theme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      actions: [

      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
