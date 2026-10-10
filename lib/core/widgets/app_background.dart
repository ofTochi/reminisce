import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'glow_circle.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final int gradientStyle;

  const AppBackground({
    super.key,
    required this.child,
    required this.gradientStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;
    final Color bgColor = isDark
        ? AppColors.darkScaffoldBg
        : AppColors.lightScaffoldBg;
    final Size screen = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (gradientStyle == 1) ...[
            // "Lamp" — large glow top-left, smaller glow bottom-right
            Positioned(
              left: -100,
              top: -100,
              child: GlowCircle(size: 400, color: primaryColor),
            ),
            Positioned(
              right: -50,
              bottom: -50,
              child: GlowCircle(size: 250, color: primaryColor),
            ),
          ] else if (gradientStyle == 2) ...[
            // "Crown" — beacon centered at top, deep haze at bottom
            Positioned(
              top: -150,
              left: screen.width / 2 - 175,
              child: GlowCircle(size: 350, color: primaryColor, opacity: 0.2),
            ),
            Positioned(
              bottom: -100,
              left: 0,
              right: 0,
              child: GlowCircle(
                size: 400,
                color: const Color(0xFF001F3F),
                opacity: 0.3,
              ),
            ),
          ] else if (gradientStyle == 3) ...[
            // "Horizon" — glow left edge, deep navy right edge
            Positioned(
              left: -150,
              top: screen.height / 2 - 150,
              child: GlowCircle(size: 300, color: primaryColor),
            ),
            Positioned(
              right: -150,
              top: screen.height / 2 - 150,
              child: GlowCircle(size: 300, color: const Color(0xFF0D1B2A)),
            ),
          ],
          SafeArea(child: child),
        ],
      ),
    );
  }
}
