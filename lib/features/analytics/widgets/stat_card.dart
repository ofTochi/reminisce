import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_card.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? accentColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.accentColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color defaultPrimary = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;
    final Color color = accentColor ?? defaultPrimary;
    final Color textMuted = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;

    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14.0),
      borderRadius: 16.0,
      borderColor: color.withValues(alpha: isDark ? 0.22 : 0.16),
      borderWidth: 1.0,
      hasGlow: true,
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Title + Icon Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: color,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Main Metric Value
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Subtitle / Trend footnote
          Text(
            subtitle ?? 'Total recorded',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: textMuted.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
