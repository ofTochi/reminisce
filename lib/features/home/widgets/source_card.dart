import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_card.dart';

class SourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color borderColor;
  final String? badge;
  final VoidCallback onTap;

  const SourceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color textMuted = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;

    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      borderRadius: 16.0,
      borderColor: borderColor.withValues(alpha: isDark ? 0.35 : 0.28),
      borderWidth: 1.2,
      hasGlow: true,
      glowColor: borderColor,
      child: Row(
        children: [
          // Squircle Icon Container with soft gradient & glow
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  borderColor.withValues(alpha: isDark ? 0.22 : 0.16),
                  borderColor.withValues(alpha: isDark ? 0.08 : 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor.withValues(alpha: isDark ? 0.45 : 0.30),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: borderColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Title & Subtitle with refined typography hierarchy
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Optional Modern Pill Badge
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    borderColor.withValues(alpha: isDark ? 0.25 : 0.18),
                    borderColor.withValues(alpha: isDark ? 0.15 : 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: borderColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],

          const SizedBox(width: 10),

          // Chevron Indicator in subtle circular container
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: textMuted.withValues(alpha: 0.8),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
