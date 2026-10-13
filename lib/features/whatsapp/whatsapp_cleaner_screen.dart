import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/modern_card.dart';
import '../../models/whatsapp_category.dart';
import '../../providers/whatsapp_cleaner_provider.dart';
import 'widgets/whatsapp_cleaner_widgets.dart';

class WhatsAppCleanerScreen extends ConsumerStatefulWidget {
  const WhatsAppCleanerScreen({super.key});

  @override
  ConsumerState<WhatsAppCleanerScreen> createState() =>
      _WhatsAppCleanerScreenState();
}

class _WhatsAppCleanerScreenState extends ConsumerState<WhatsAppCleanerScreen> {
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndScan();
  }

  Future<void> _checkPermissionAndScan() async {
    final manage = await Permission.manageExternalStorage.status;
    final legacy = await Permission.storage.status;
    final photos = await Permission.photos.status;

    if (!manage.isGranted && !legacy.isGranted && !photos.isGranted) {
      if (mounted) setState(() => _hasPermission = false);
      return;
    }
    if (mounted) {
      setState(() => _hasPermission = true);
      ref.read(whatsAppCleanerProvider.notifier).scan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanerState = ref.watch(whatsAppCleanerProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor =
        isDark ? AppColors.darkPrimaryGold : AppColors.lightPrimaryTerracotta;
    final Color textMuted =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return AppBackground(
      gradientStyle: 2,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            floating: true,
            title: Text(
              'WhatsApp Cleaner',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
            ),
            actions: [
              // Sort toggle
              if (cleanerState.status == CleanerStatus.loaded)
                _SortChip(
                  sortByDate: cleanerState.sortByDate,
                  onTap: () =>
                      ref.read(whatsAppCleanerProvider.notifier).toggleSort(),
                  primaryColor: primaryColor,
                  isDark: isDark,
                ),
              // Refresh
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: primaryColor),
                onPressed: () =>
                    ref.read(whatsAppCleanerProvider.notifier).refresh(),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Body content ─────────────────────────────────────────────────
          if (!_hasPermission)
            SliverFillRemaining(
              child: _PermissionDeniedState(
                onRequest: () async {
                  await Permission.manageExternalStorage.request();
                  _checkPermissionAndScan();
                },
                textMuted: textMuted,
                primaryColor: primaryColor,
                isDark: isDark,
              ),
            )
          else if (cleanerState.status == CleanerStatus.loading ||
              cleanerState.status == CleanerStatus.idle)
            const SliverFillRemaining(
              child: WhatsAppCleanerShimmer(),
            )
          else if (cleanerState.status == CleanerStatus.error)
            SliverFillRemaining(
              child: _ErrorState(
                message: cleanerState.errorMessage ?? 'Unknown error',
                onRetry: () =>
                    ref.read(whatsAppCleanerProvider.notifier).scan(),
                textMuted: textMuted,
                primaryColor: primaryColor,
              ),
            )
          else ...[
            // ── Hero Summary Card ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _HeroSummaryCard(state: cleanerState, isDark: isDark)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.06, end: 0, duration: 400.ms),
            ),

            // ── Section header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: M3SectionHeader(
                  overline: 'Media Breakdown',
                  title: cleanerState.sortByDate
                      ? 'By Recent Activity'
                      : 'By Largest Size',
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
            ),

            // ── Category grid ────────────────────────────────────────────
            if (cleanerState.totalFiles == 0)
              const SliverFillRemaining(
                child: WhatsAppEmptyState(
                  message:
                      'No WhatsApp media found on this device.\nMake sure WhatsApp is installed.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cats = WhatsAppCategory.values
                          .where((c) =>
                              (cleanerState.filesByCategory[c]?.length ?? 0) >
                              0)
                          .toList();
                      if (index >= cats.length) return null;
                      final cat = cats[index];
                      final files = cleanerState.filesByCategory[cat] ?? [];
                      return WhatsAppCategoryCard(
                        category: cat,
                        files: files,
                        totalBytesAll: cleanerState.totalBytes,
                        onTap: () => navigateToCategory(context, cat),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 120 + index * 60),
                            duration: 350.ms,
                          )
                          .slideY(begin: 0.08, end: 0, duration: 350.ms);
                    },
                    childCount: WhatsAppCategory.values
                        .where((c) =>
                            (cleanerState.filesByCategory[c]?.length ?? 0) > 0)
                        .length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                ),
              ),

            // ── Freed space banner ──────────────────────────────────────
            if (cleanerState.deletedBytes > 0)
              SliverToBoxAdapter(
                child: _FreedBanner(
                  bytes: cleanerState.deletedBytes,
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms).scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                    ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sort Chip
// ─────────────────────────────────────────────────────────────────────────────

class _SortChip extends StatelessWidget {
  final bool sortByDate;
  final VoidCallback onTap;
  final Color primaryColor;
  final bool isDark;

  const _SortChip({
    required this.sortByDate,
    required this.onTap,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: BouncingPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                sortByDate
                    ? Icons.schedule_rounded
                    : Icons.storage_rounded,
                size: 14,
                color: primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                sortByDate ? 'Date' : 'Size',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSummaryCard extends StatelessWidget {
  final WhatsAppCleanerState state;
  final bool isDark;

  const _HeroSummaryCard({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final int total = state.totalBytes;
    final String sizeText = _formatBytesLarge(total);
    final String countText = '${state.totalFiles} files across '
        '${state.filesByCategory.values.where((l) => l.isNotEmpty).length} categories';

    final Color c1 = isDark
        ? const Color(0xFF1B5E20)
        : const Color(0xFF66BB6A);
    final Color c2 = isDark
        ? const Color(0xFF004D40)
        : const Color(0xFF26A69A);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              c1.withValues(alpha: 0.45),
              c2.withValues(alpha: 0.35),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: isDark ? 0.3 : 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50)
                  .withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chat_rounded,
                    color: const Color(0xFF25D366),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Cleanable Space',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sizeText,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              countText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytesLarge(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Freed Banner (post-deletion success)
// ─────────────────────────────────────────────────────────────────────────────

class _FreedBanner extends StatelessWidget {
  final int bytes;
  final bool isDark;
  const _FreedBanner({required this.bytes, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final label = bytes >= 1024 * 1024
        ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(bytes / 1024).toStringAsFixed(0)} KB';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ModernCard(
        hasGlow: true,
        glowColor: AppColors.darkKeepGreen,
        borderColor: AppColors.darkKeepGreen.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.darkKeepGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.darkKeepGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label freed!',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkKeepGreen,
                    ),
                  ),
                  Text(
                    'Storage recovered from deleted WhatsApp files',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission Denied State
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionDeniedState extends StatelessWidget {
  final VoidCallback onRequest;
  final Color textMuted;
  final Color primaryColor;
  final bool isDark;

  const _PermissionDeniedState({
    required this.onRequest,
    required this.textMuted,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off_rounded,
                size: 56, color: textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Storage permission required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Grant access to scan and clean WhatsApp media files.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRequest,
              icon: const Icon(Icons.lock_open_rounded, size: 18),
              label: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color textMuted;
  final Color primaryColor;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.textMuted,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.darkDeleteRed.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              'Scan failed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
