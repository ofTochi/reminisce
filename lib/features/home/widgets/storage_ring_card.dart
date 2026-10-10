import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class StorageRingCard extends StatelessWidget {
  const StorageRingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? AppColors.darkPrimaryGold : AppColors.lightPrimaryTerracotta;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: [
                          PieChartSectionData(color: primaryColor, value: 40, radius: 10, showTitle: false),
                          PieChartSectionData(color: const Color(0xFFC0622F), value: 20, radius: 10, showTitle: false),
                          PieChartSectionData(color: Colors.blueGrey, value: 15, radius: 10, showTitle: false),
                          PieChartSectionData(color: Colors.blueAccent, value: 10, radius: 10, showTitle: false),
                          PieChartSectionData(color: Colors.grey, value: 15, radius: 10, showTitle: false),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '72%',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
                        ),
                        const Text('used', style: TextStyle(fontSize: 10, color: AppColors.darkTextMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(color: primaryColor, label: 'Photos', size: '24.5 GB'),
                    _LegendItem(color: const Color(0xFFC0622F), label: 'Videos', size: '12.2 GB'),
                    _LegendItem(color: Colors.blueGrey, label: 'Docs', size: '4.1 GB'),
                    _LegendItem(color: Colors.blueAccent, label: 'Audio', size: '2.8 GB'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '92.4 GB used of 128 GB',
            style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String size;

  const _LegendItem({required this.color, required this.label, required this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(size, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

