import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/modern_card.dart';
import '../../models/whatsapp_category.dart';
import '../../models/whatsapp_media_file.dart';
import '../../providers/whatsapp_cleaner_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/device_capability_provider.dart';
import '../../core/constants/app_strings.dart';
import 'widgets/whatsapp_cleaner_widgets.dart';

class WhatsAppCategoryScreen extends ConsumerStatefulWidget {
  final WhatsAppCategory category;
  const WhatsAppCategoryScreen({super.key, required this.category});

  @override
  ConsumerState<WhatsAppCategoryScreen> createState() =>
      _WhatsAppCategoryScreenState();
}

class _WhatsAppCategoryScreenState
    extends ConsumerState<WhatsAppCategoryScreen> {
  bool _isGrid = true;
  bool _showDeletedBanner = false;
  int _lastDeletedBytes = 0;

  @override
  Widget build(BuildContext context) {
    final cleanerState = ref.watch(whatsAppCleanerProvider);
    final notifier = ref.read(whatsAppCleanerProvider.notifier);
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

    // ── Sync selection limit from device capability + settings override ───
    final capAsync = ref.watch(deviceCapabilityProvider);
    final settings = ref.read(settingsProvider);
    final override = settings.maxSelectionOverride;
    final deviceLimit = capAsync.whenOrNull(data: (c) => c.softSelectionLimit) ?? 30;
    notifier.selectionLimit = override ?? deviceLimit;

    final files = cleanerState.filesForCategory(widget.category);
    final selectedInCat = files
        .where((f) => cleanerState.isSelected(f.filePath))
        .toList();
    final selectedBytes = selectedInCat.fold(
      0,
      (acc, f) => acc + f.sizeInBytes,
    );

    return AppBackground(
      gradientStyle: 2,
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          _buildHeader(
            context,
            files.length,
            primaryColor,
            textPrimary,
            textMuted,
            isDark,
            notifier,
            cleanerState,
          ),

          // ── Selection toolbar ────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            height: selectedInCat.isNotEmpty ? 44 : 0,
            child: selectedInCat.isNotEmpty
                ? _SelectionToolbar(
                    selectedCount: selectedInCat.length,
                    totalCount: files.length,
                    onSelectAll: () => notifier.selectAll(widget.category),
                    onDeselectAll: () => notifier.deselectAll(widget.category),
                    primaryColor: primaryColor,
                    textMuted: textMuted,
                    isDark: isDark,
                  )
                : const SizedBox.shrink(),
          ),

          // ── Deleted banner ──────────────────────────────────────────────
          if (_showDeletedBanner)
            _DeletedInlineBanner(
                  bytes: _lastDeletedBytes,
                  isDark: isDark,
                  onDismiss: () => setState(() => _showDeletedBanner = false),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.1, end: 0, duration: 300.ms),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: files.isEmpty
                ? WhatsAppEmptyState(
                    message: 'No ${widget.category.label} files found.',
                  )
                : _isGrid
                ? _buildGrid(files, cleanerState)
                : _buildList(files, cleanerState, isDark),
          ),

          // ── Bottom action bar ────────────────────────────────────────────
          if (selectedInCat.isNotEmpty)
            _BottomDeleteBar(
                  selectedCount: selectedInCat.length,
                  selectedBytes: selectedBytes,
                  onDelete: () =>
                      _performDeletion(context, cleanerState, notifier, isDark),
                  isDark: isDark,
                )
                .animate()
                .fadeIn(duration: 250.ms)
                .slideY(begin: 0.3, end: 0, duration: 300.ms),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    int fileCount,
    Color primaryColor,
    Color textPrimary,
    Color textMuted,
    bool isDark,
    WhatsAppCleanerNotifier notifier,
    WhatsAppCleanerState cleanerState,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '$fileCount files · ${cleanerState.sortByDate ? "newest first" : "largest first"}',
                  style: TextStyle(color: textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          // Sort toggle
          BouncingPressable(
            onTap: () => notifier.toggleSort(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                cleanerState.sortByDate
                    ? Icons.schedule_rounded
                    : Icons.storage_rounded,
                size: 18,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Grid/List toggle
          BouncingPressable(
            onTap: () => setState(() => _isGrid = !_isGrid),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                size: 18,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Select All / Deselect All
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: primaryColor),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            onSelected: (val) {
              if (val == 'selectAll') {
                ref
                    .read(whatsAppCleanerProvider.notifier)
                    .selectAll(widget.category);
              } else {
                ref
                    .read(whatsAppCleanerProvider.notifier)
                    .deselectAll(widget.category);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'selectAll',
                child: Text('Select All'),
              ),
              const PopupMenuItem(
                value: 'deselectAll',
                child: Text('Deselect All'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Grid view ─────────────────────────────────────────────────────────────
  Widget _buildGrid(
    List<WhatsAppMediaFile> files,
    WhatsAppCleanerState cleanerState,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final f = files[index];
        return WhatsAppFileItem(
              mediaFile: f,
              isSelected: cleanerState.isSelected(f.filePath),
              isGrid: true,
              onTap: () => _handleToggleSelection(context, f.filePath),
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: (index.clamp(0, 20) * 20)),
              duration: 250.ms,
            )
            .slideY(begin: 0.06, end: 0, duration: 250.ms);
      },
    );
  }

  // ── List view ─────────────────────────────────────────────────────────────
  Widget _buildList(
    List<WhatsAppMediaFile> files,
    WhatsAppCleanerState cleanerState,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final f = files[index];
        return WhatsAppFileItem(
              mediaFile: f,
              isSelected: cleanerState.isSelected(f.filePath),
              isGrid: false,
              onTap: () => _handleToggleSelection(context, f.filePath),
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: (index.clamp(0, 20) * 20)),
              duration: 250.ms,
            )
            .slideY(begin: 0.05, end: 0, duration: 250.ms);
      },
    );
  }

  // ── Selection with limit gate ─────────────────────────────────────────────
  void _handleToggleSelection(BuildContext context, String filePath) {
    HapticFeedback.selectionClick();
    final notifier = ref.read(whatsAppCleanerProvider.notifier);
    final result = notifier.toggleSelection(filePath);
    if (result == SelectionResult.limitReached) {
      final cap = ref.read(deviceCapabilityProvider).whenOrNull(
            data: (c) => c,
          );
      AppDialog.show(
        context,
        title: 'Performance limit reached',
        description:
            'Your device has ${cap?.ramLabel ?? 'limited'} RAM. '
            'Selecting more than ${notifier.selectionLimit} files at once '
            'may cause the app to freeze or become unresponsive.\n\n'
            'Select anyway?',
        yesLabel: 'Select anyway',
        noLabel: 'Stop here',
        onYes: () => notifier.forceSelect(filePath),
      );
    }
  }

  // ── Deletion ──────────────────────────────────────────────────────────────
  Future<void> _performDeletion(
    BuildContext context,
    WhatsAppCleanerState cleanerState,
    WhatsAppCleanerNotifier notifier,
    bool isDark,
  ) async {
    final settings = ref.read(settingsProvider);
    final needsConfirm = settings.get(
      AppStrings.settings.confirmDeletions,
      defaultValue: true,
    );

    if (needsConfirm) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => _DeleteConfirmDialog(
          count: cleanerState.selectedPaths.length,
          bytes: cleanerState.selectedBytes,
          isDark: isDark,
        ),
      );
      if (confirm != true) return;
    }

    final bytesBeforeDelete = cleanerState.selectedBytes;
    await notifier.deleteSelected();

    if (mounted) {
      HapticFeedback.mediumImpact();
      setState(() {
        _showDeletedBanner = true;
        _lastDeletedBytes = bytesBeforeDelete;
      });
      // Auto-dismiss after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showDeletedBanner = false);
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selection Toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _SelectionToolbar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final Color primaryColor;
  final Color textMuted;
  final bool isDark;

  const _SelectionToolbar({
    required this.selectedCount,
    required this.totalCount,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.primaryColor,
    required this.textMuted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: primaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppColors.darkDeleteRed,
          ),
          const SizedBox(width: 6),
          Text(
            '$selectedCount of $totalCount selected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onSelectAll,
            child: Text(
              'All',
              style: TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: onDeselectAll,
            child: Text(
              'None',
              style: TextStyle(
                fontSize: 12,
                color: textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Delete Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomDeleteBar extends StatelessWidget {
  final int selectedCount;
  final int selectedBytes;
  final VoidCallback onDelete;
  final bool isDark;

  const _BottomDeleteBar({
    required this.selectedCount,
    required this.selectedBytes,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sizeLabel = selectedBytes >= 1024 * 1024
        ? '${(selectedBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(selectedBytes / 1024).toStringAsFixed(0)} KB';

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$selectedCount files selected',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Free $sizeLabel',
                  style: const TextStyle(
                    color: AppColors.darkKeepGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          BouncingPressable(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkDeleteRed,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkDeleteRed.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.delete_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Deleted Inline Banner
// ─────────────────────────────────────────────────────────────────────────────

class _DeletedInlineBanner extends StatelessWidget {
  final int bytes;
  final bool isDark;
  final VoidCallback onDismiss;

  const _DeletedInlineBanner({
    required this.bytes,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final label = bytes >= 1024 * 1024
        ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(bytes / 1024).toStringAsFixed(0)} KB';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkKeepGreen.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkKeepGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.darkKeepGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label freed successfully!',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkKeepGreen,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delete Confirmation Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  final int count;
  final int bytes;
  final bool isDark;

  const _DeleteConfirmDialog({
    required this.count,
    required this.bytes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final sizeLabel = bytes >= 1024 * 1024
        ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(bytes / 1024).toStringAsFixed(0)} KB';

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete $count files?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
      content: Text(
        'This will permanently remove $count files ($sizeLabel) from your device. This action cannot be undone.',
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          fontSize: 13,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkDeleteRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
