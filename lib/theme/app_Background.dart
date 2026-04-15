import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: isDark
            ? AppTheme.darkGradient
            : AppTheme.lightGradient,
      ),
      child: child,
    );
  }
}