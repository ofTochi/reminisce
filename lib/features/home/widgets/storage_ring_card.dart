import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modern_card.dart';

class StorageRingCard extends StatelessWidget {
  const StorageRingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;
    final Color textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color textMuted = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;

    // Palette for storage categories maintaining existing theme harmonies
    final Color photosColor = primaryColor;
    const Color videosColor = Color(0xFFC0622F);
    final Color docsColor = isDark ? const Color(0xFF5B8FB9) : const Color(0xFF4A7C9D);
    final Color audioColor = isDark ? const Color(0xFF48CAE4) : const Color(0xFF0096C7);
    final Color otherColor = isDark ? const Color(0xFF3E5062) : const Color(0xFFB0B7C3);

    return ModernCard(
      padding: const EdgeInsets.all(20.0),
      hasGlow: true,
      glowColor: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STORAGE OVERVIEW',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      color: primaryColor.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Internal Memory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '72% Full',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Donut Ring + Legend Row
          Row(
            children: [
              // Glowing Donut Ring
              SizedBox(
                height: 128,
                width: 128,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 46,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: photosColor,
                            value: 40,
                            radius: 14,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: videosColor,
                            value: 20,
                            radius: 14,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: docsColor,
                            value: 15,
                            radius: 14,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: audioColor,
                            value: 10,
                            radius: 14,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: otherColor,
                            value: 15,
                            radius: 14,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '72%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                height: 1.1,
                              ),
                        ),
                        Text(
                          'used',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Category Legend Items
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StorageLegendRow(
                      color: photosColor,
                      label: 'Photos',
                      size: '24.5 GB',
                      percentage: '40%',
                      textColor: textPrimary,
                      mutedColor: textMuted,
                    ),
                    const SizedBox(height: 6),
                    _StorageLegendRow(
                      color: videosColor,
                      label: 'Videos',
                      size: '12.2 GB',
                      percentage: '20%',
                      textColor: textPrimary,
                      mutedColor: textMuted,
                    ),
                    const SizedBox(height: 6),
                    _StorageLegendRow(
                      color: docsColor,
                      label: 'Docs',
                      size: '4.1 GB',
                      percentage: '15%',
                      textColor: textPrimary,
                      mutedColor: textMuted,
                    ),
                    const SizedBox(height: 6),
                    _StorageLegendRow(
                      color: audioColor,
                      label: 'Audio',
                      size: '2.8 GB',
                      percentage: '10%',
                      textColor: textPrimary,
                      mutedColor: textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Segmented Progress Bar (iOS Storage Style)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  Expanded(flex: 40, child: Container(color: photosColor)),
                  const SizedBox(width: 2),
                  Expanded(flex: 20, child: Container(color: videosColor)),
                  const SizedBox(width: 2),
                  Expanded(flex: 15, child: Container(color: docsColor)),
                  const SizedBox(width: 2),
                  Expanded(flex: 10, child: Container(color: audioColor)),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 15,
                    child: Container(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Metric Footnote
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '92.4 GB used',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                '35.6 GB free of 128 GB',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StorageLegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String size;
  final String percentage;
  final Color textColor;
  final Color mutedColor;

  const _StorageLegendRow({
    required this.color,
    required this.label,
    required this.size,
    required this.percentage,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
        Text(
          size,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 32,
          child: Text(
            percentage,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: mutedColor,
            ),
          ),
        ),
      ],
    );
  }
}
