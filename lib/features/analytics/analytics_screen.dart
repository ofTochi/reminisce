import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/app_background.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/analytics_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/weekly_bar_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    return AppBackground(
      gradientStyle: 3,
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating:
                true, // Optional: Makes it reappear immediately when scrolling up
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Your Storage Story',
              style: TextStyle(fontFamily: 'Playfair Display'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDonutChart(context),
                const SizedBox(height: 32),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Freed',
                      value:
                          '${_calculateTotalFreed(analytics.sessions).toStringAsFixed(1)} GB',
                    ),
                    StatCard(
                      title: 'Sessions',
                      value: '${analytics.sessions.length}',
                    ),
                    StatCard(
                      title: 'Streak',
                      value: '${analytics.streakDays} days',
                    ),
                    StatCard(
                      title: 'Best Session',
                      value:
                          '${_calculateBestSession(analytics.sessions).toStringAsFixed(1)} MB',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const WeeklyBarChart(),
                const SizedBox(height: 32),
                Text(
                  'Recent Sessions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (analytics.sessions.isEmpty)
                  const Center(
                    child: Text(
                      'No cleaning history yet.',
                      style: TextStyle(color: AppColors.darkTextMuted),
                    ),
                  )
                else
                  ...analytics.sessions.reversed
                      .take(10)
                      .map((s) => _buildSessionTile(s)),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              color: AppColors.darkPrimaryGold,
              value: 40,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              color: const Color(0xFFC0622F),
              value: 20,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              color: Colors.blueGrey,
              value: 15,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              color: Colors.blueAccent,
              value: 10,
              radius: 20,
              showTitle: false,
            ),
            PieChartSectionData(
              color: Colors.grey,
              value: 15,
              radius: 20,
              showTitle: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(dynamic session) {
    return Card(
      color: AppColors.darkSurface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          session.sourceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${session.filesDeleted} files deleted'),
        trailing: Text(
          '${session.mbFreed.toStringAsFixed(1)} MB',
          style: const TextStyle(
            color: AppColors.darkPrimaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  double _calculateTotalFreed(List<dynamic> sessions) {
    return sessions.fold<double>(0.0, (sum, s) => sum + s.mbFreed) / 1024;
  }

  double _calculateBestSession(List<dynamic> sessions) {
    if (sessions.isEmpty) return 0.0;
    return sessions
        .map((s) => s.mbFreed as double)
        .reduce((a, b) => a > b ? a : b);
  }
}
