import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/modern_card.dart';
import '../../core/constants/app_colors.dart';
import '../../models/cleaning_session.dart';
import '../../providers/analytics_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/weekly_bar_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
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

    final double totalFreedGb = _calculateTotalFreed(analytics.sessions);
    final double bestSessionMb = _calculateBestSession(analytics.sessions);

    return AppBackground(
      gradientStyle: 3,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with iOS HIG title styling
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Your Storage Story',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero Reclaimed Space Card
                _buildHeroReclaimedCard(
                  context,
                  totalFreedGb: totalFreedGb,
                  primaryColor: primaryColor,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  isDark: isDark,
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.05, end: 0, duration: 400.ms),

                const SizedBox(height: 20),

                // 2x2 Stat Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    StatCard(
                      title: 'Freed Space',
                      value: '${totalFreedGb.toStringAsFixed(1)} GB',
                      icon: Icons.delete_sweep_rounded,
                      accentColor: primaryColor,
                      subtitle: 'Reclaimed lifetime',
                    ),
                    StatCard(
                      title: 'Sessions',
                      value: '${analytics.sessions.length}',
                      icon: Icons.auto_awesome_rounded,
                      accentColor: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2),
                      subtitle: 'Cleaning sweeps',
                    ),
                    StatCard(
                      title: 'Streak',
                      value: '${analytics.streakDays} ${analytics.streakDays == 1 ? "day" : "days"}',
                      icon: Icons.local_fire_department_rounded,
                      accentColor: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                      subtitle: 'Consecutive activity',
                    ),
                    StatCard(
                      title: 'Best Sweep',
                      value: bestSessionMb >= 1024
                          ? '${(bestSessionMb / 1024).toStringAsFixed(1)} GB'
                          : '${bestSessionMb.toStringAsFixed(0)} MB',
                      icon: Icons.bolt_rounded,
                      accentColor: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                      subtitle: 'Single sweep record',
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.05, end: 0, duration: 400.ms),

                const SizedBox(height: 20),

                // Storage Composition Donut Card
                _buildDonutCompositionCard(
                  context,
                  primaryColor: primaryColor,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  isDark: isDark,
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideY(begin: 0.05, end: 0, duration: 400.ms),

                const SizedBox(height: 20),

                // Weekly Cleaning Activity Bar Chart
                const WeeklyBarChart()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.05, end: 0, duration: 400.ms),

                const SizedBox(height: 28),

                // Section Header: Recent Sessions
                const M3SectionHeader(
                  overline: 'History',
                  title: 'Recent Sessions',
                ),

                const SizedBox(height: 12),

                // Grouped Session History Card / Empty State
                if (analytics.sessions.isEmpty)
                  _buildEmptyState(
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    isDark: isDark,
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms)
                else
                  _buildSessionHistoryGroup(
                    analytics.sessions.reversed.take(8).toList(),
                    primaryColor: primaryColor,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    isDark: isDark,
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: 110), // Padding for floating nav bar
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Hero Banner displaying total reclaimed space
  Widget _buildHeroReclaimedCard(
    BuildContext context, {
    required double totalFreedGb,
    required Color primaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    return ModernCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 16.0,
      hasGlow: true,
      glowColor: primaryColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TOTAL RECLAIMED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalFreedGb.toStringAsFixed(1)} GB',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cleaned and optimized storage',
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: isDark ? 0.25 : 0.18),
                  primaryColor.withValues(alpha: isDark ? 0.10 : 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.spa_rounded,
              color: primaryColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Donut Chart Card showing breakdown of cleanable categories
  Widget _buildDonutCompositionCard(
    BuildContext context, {
    required Color primaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    const Color videosColor = Color(0xFFC0622F);
    final Color docsColor = isDark ? const Color(0xFF5B8FB9) : const Color(0xFF4A7C9D);
    final Color audioColor = isDark ? const Color(0xFF48CAE4) : const Color(0xFF0096C7);
    final Color otherColor = isDark ? const Color(0xFF3E5062) : const Color(0xFFB0B7C3);

    return ModernCard(
      padding: const EdgeInsets.all(20.0),
      borderRadius: 16.0,
      hasGlow: true,
      glowColor: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPOSITION',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                      color: primaryColor.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Storage Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Text(
                '128 GB Total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                height: 128,
                width: 128,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 44,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: primaryColor,
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
                    Text(
                      'Files',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Category legend column
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(primaryColor, 'Photos', '40%', textPrimary, textMuted),
                    const SizedBox(height: 6),
                    _buildLegendItem(videosColor, 'Videos', '20%', textPrimary, textMuted),
                    const SizedBox(height: 6),
                    _buildLegendItem(docsColor, 'Documents', '15%', textPrimary, textMuted),
                    const SizedBox(height: 6),
                    _buildLegendItem(audioColor, 'Audio', '10%', textPrimary, textMuted),
                    const SizedBox(height: 6),
                    _buildLegendItem(otherColor, 'Other/Cache', '15%', textPrimary, textMuted),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    Color color,
    String label,
    String pct,
    Color textPrimary,
    Color textMuted,
  ) {
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
              color: textPrimary,
            ),
          ),
        ),
        Text(
          pct,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
      ],
    );
  }

  /// Empty State Card
  Widget _buildEmptyState({
    required Color primaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    return ModernCard(
      padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 24.0),
      borderRadius: 16.0,
      child: Center(
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cleaning_services_outlined,
                color: primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No cleaning history yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start a cleaning session from the Home tab to begin tracking your reclaimed space and streaks.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grouped Inset Card containing recent session history items
  Widget _buildSessionHistoryGroup(
    List<CleaningSession> sessions, {
    required Color primaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    return ModernCard(
      padding: EdgeInsets.zero,
      borderRadius: 16.0,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sessions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.8,
          indent: 64,
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        itemBuilder: (context, index) {
          final session = sessions[index];
          final isWhatsApp = session.sourceName.toLowerCase().contains('whatsapp');
          final iconData = isWhatsApp
              ? Icons.chat_bubble_outline_rounded
              : Icons.folder_open_rounded;
          final iconColor = isWhatsApp
              ? const Color(0xFF25D366)
              : primaryColor;

          final dateStr = DateFormat('MMM d · h:mm a').format(session.date);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Squircle Icon Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    size: 19,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 14),

                // Source title & details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.sourceName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateStr · ${session.filesDeleted} ${session.filesDeleted == 1 ? "file" : "files"}',
                        style: TextStyle(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Freed size pill badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '+${session.mbFreed.toStringAsFixed(1)} MB',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _calculateTotalFreed(List<CleaningSession> sessions) {
    if (sessions.isEmpty) return 0.0;
    return sessions.fold<double>(0.0, (sum, s) => sum + s.mbFreed) / 1024;
  }

  double _calculateBestSession(List<CleaningSession> sessions) {
    if (sessions.isEmpty) return 0.0;
    return sessions
        .map((s) => s.mbFreed)
        .reduce((a, b) => a > b ? a : b);
  }
}
