import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/whatsapp_provider.dart';
import '../../../providers/theme_provider.dart';
import 'widgets/storage_ring_card.dart';
import 'widgets/source_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final whatsappData = ref.watch(whatsappContactsProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;

    return AppBackground(
      gradientStyle: 1,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header with Brand & Theme Toggle
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            floating: true,
            leadingWidth: 54,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Image.asset(
                'assets/images/reminisce_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            titleSpacing: 12,
            title: Text(
              'Reminisce',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: BouncingPressable(
                  onTap: () {
                    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
                    ref
                        .read(themeModeNotifierProvider.notifier)
                        .setThemeMode(nextMode);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: isDark ? 0.14 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Main Scrollable Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Storage Overview Hero Card
                const StorageRingCard()
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.05,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 24),

                // Active Session Banner if in progress
                if (session.status != SessionStatus.none) ...[
                  _ResumeSessionBanner(session: session)
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.08, end: 0, duration: 350.ms),
                  const SizedBox(height: 24),
                ],

                // Section Header
                const M3SectionHeader(
                  // overline: 'Quick Clean',
                  title: 'Start Cleaning',
                ),

                const SizedBox(height: 12),

                // Source Card 1: Device Folders
                SourceCard(
                      icon: Icons.folder_open_rounded,
                      title: 'Device Folders',
                      subtitle: 'Browse and clean specific directories',
                      borderColor: primaryColor,
                      badge: 'Files',
                      onTap: () => context.push(RouteNames.folders),
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.06, end: 0, duration: 400.ms),

                const SizedBox(height: 12),

                // Source Card 2: WhatsApp Media
                SourceCard(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'WhatsApp Media',
                      subtitle: 'Clean by contact chats or groups',
                      borderColor: const Color(0xFF25D366),
                      badge: whatsappData.when(
                        data: (list) {
                          final totalBytes = list.fold<int>(
                            0,
                            (sum, item) => sum + item.totalBytes,
                          );
                          if (totalBytes == 0) return '0 MB';
                          if (totalBytes > 1024 * 1024 * 1024) {
                            return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
                          }
                          return '${(totalBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
                        },
                        loading: () => 'Scanning...',
                        error: (_, __) => null,
                      ),
                      onTap: () => context.push(RouteNames.whatsapp),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.06, end: 0, duration: 400.ms),

                const SizedBox(height: 110), // Padding for floating bottom nav
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeSessionBanner extends StatelessWidget {
  final SessionState session;

  const _ResumeSessionBanner({required this.session});

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

    final int totalFiles = session.allFiles.length;
    final int currentIndex = session.currentIndex;
    final double progress = totalFiles > 0
        ? (currentIndex / totalFiles).clamp(0.0, 1.0)
        : 0.0;

    void resumeSession() {
      if (session.status == SessionStatus.pendingDelete) {
        context.push(RouteNames.goodbye);
        return;
      }
      if (session.activeContentType == ContentType.photo) {
        context.push(RouteNames.cleanPhoto);
      } else if (session.activeContentType == ContentType.document) {
        context.push(RouteNames.cleanDocument);
      } else if (session.activeContentType == ContentType.audio) {
        context.push(RouteNames.cleanAudio);
      }
    }

    return ModernCard(
      onTap: resumeSession,
      padding: const EdgeInsets.all(16.0),
      borderRadius: 16.0,
      borderColor: primaryColor.withValues(alpha: isDark ? 0.45 : 0.35),
      borderWidth: 1.2,
      hasGlow: true,
      glowColor: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Pulsing Play/Resume Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Resume Session',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${session.activeSourceName ?? "Clean"} · $currentIndex / $totalFiles items reviewed',
                      style: TextStyle(fontSize: 12, color: textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      isDark ? AppColors.darkPrimaryBright : primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkScaffoldBg : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: isDark ? AppColors.darkScaffoldBg : Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Track
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
