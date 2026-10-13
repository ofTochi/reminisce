import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../providers/folders_provider.dart';
import '../content_type/content_type_sheet.dart';
import '../../providers/session_provider.dart';
import '../../models/device_folder.dart';

class FolderBrowserScreen extends ConsumerStatefulWidget {
  const FolderBrowserScreen({super.key});

  @override
  ConsumerState<FolderBrowserScreen> createState() =>
      _FolderBrowserScreenState();
}

class _FolderBrowserScreenState extends ConsumerState<FolderBrowserScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foldersData = ref.watch(filteredDeviceFoldersProvider);
    final showingCleaned = ref.watch(showCleanedFoldersProvider);
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
    final Color surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return AppBackground(
      gradientStyle: 2,
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          _Header(
            primaryColor: primaryColor,
            textPrimary: textPrimary,
            isDark: isDark,
            showingCleaned: showingCleaned,
            onRefresh: () {
              ref.invalidate(filteredDeviceFoldersProvider);
              ref.invalidate(deviceFoldersProvider);
            },
            onToggleCleaned: () =>
                ref.read(showCleanedFoldersProvider.notifier).toggle(),
          ),

          // ── Search bar ──────────────────────────────────────────────────
          _SearchBar(
            controller: _searchController,
            isDark: isDark,
            primaryColor: primaryColor,
            textMuted: textMuted,
            surfaceColor: surfaceColor,
            onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: foldersData.when(
              loading: () => _FolderShimmer(isDark: isDark),
              error: (err, _) => _ErrorState(
                message: err.toString(),
                textMuted: textMuted,
                primaryColor: primaryColor,
                onRetry: () {
                  ref.invalidate(filteredDeviceFoldersProvider);
                  ref.invalidate(deviceFoldersProvider);
                },
              ),
              data: (folders) {
                final filtered = _searchQuery.isEmpty
                    ? folders
                    : folders
                          .where(
                            (f) => f.name.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return _EmptyState(
                    isSearch: _searchQuery.isNotEmpty,
                    textMuted: textMuted,
                    primaryColor: primaryColor,
                  );
                }

                return _FolderList(
                  folders: filtered,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  surfaceColor: surfaceColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Color primaryColor;
  final Color textPrimary;
  final bool isDark;
  final bool showingCleaned;
  final VoidCallback onRefresh;
  final VoidCallback onToggleCleaned;

  const _Header({
    required this.primaryColor,
    required this.textPrimary,
    required this.isDark,
    required this.showingCleaned,
    required this.onRefresh,
    required this.onToggleCleaned,
  });

  @override
  Widget build(BuildContext context) {
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
                  'Device Folders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  showingCleaned ? 'Showing all folders' : 'Browse and clean your media',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Show/hide cleaned folders toggle
          Tooltip(
            message: showingCleaned ? 'Hide cleaned folders' : 'Show cleaned folders',
            child: IconButton(
              onPressed: onToggleCleaned,
              icon: Icon(
                showingCleaned
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: showingCleaned
                    ? primaryColor
                    : primaryColor.withValues(alpha: 0.45),
                size: 22,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh_rounded, color: primaryColor, size: 22),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color primaryColor;
  final Color textMuted;
  final Color surfaceColor;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.primaryColor,
    required this.textMuted,
    required this.surfaceColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search folders...',
          hintStyle: TextStyle(color: textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: textMuted, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(Icons.close_rounded, color: textMuted, size: 18),
                )
              : null,
          filled: true,
          fillColor: surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.14),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.14),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Folder list
// ─────────────────────────────────────────────────────────────────────────────

class _FolderList extends StatelessWidget {
  final List<DeviceFolder> folders;
  final bool isDark;
  final Color primaryColor;
  final Color textPrimary;
  final Color textMuted;
  final Color surfaceColor;

  const _FolderList({
    required this.folders,
    required this.isDark,
    required this.primaryColor,
    required this.textPrimary,
    required this.textMuted,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        return _FolderTile(
              folder: folders[index],
              isDark: isDark,
              primaryColor: primaryColor,
              textPrimary: textPrimary,
              textMuted: textMuted,
              surfaceColor: surfaceColor,
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: (index.clamp(0, 15) * 40)),
              duration: 300.ms,
            )
            .slideY(begin: 0.05, end: 0, duration: 300.ms);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Folder tile
// ─────────────────────────────────────────────────────────────────────────────

class _FolderTile extends StatelessWidget {
  final DeviceFolder folder;
  final bool isDark;
  final Color primaryColor;
  final Color textPrimary;
  final Color textMuted;
  final Color surfaceColor;

  const _FolderTile({
    required this.folder,
    required this.isDark,
    required this.primaryColor,
    required this.textPrimary,
    required this.textMuted,
    required this.surfaceColor,
  });

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '$bytes B';
  }

  Color _sizeColor(int bytes) {
    if (bytes >= 500 * 1024 * 1024) return const Color(0xFFE53935);
    if (bytes >= 100 * 1024 * 1024) return const Color(0xFFFF9800);
    return AppColors.darkKeepGreen;
  }

  @override
  Widget build(BuildContext context) {
    final sizeLabel = _formatBytes(folder.totalBytes);
    final sizeColor = _sizeColor(folder.totalBytes);

    return GestureDetector(
      onTap: () => _openFolder(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Folder icon badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.folder_rounded, color: primaryColor, size: 26),
            ),
            const SizedBox(width: 14),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      fontSize: 14,
                      letterSpacing: -0.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${folder.fileCount} items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Size badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: sizeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sizeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: sizeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openFolder(BuildContext context) {
    final filesByType = {
      'Photos': List<File>.from(folder.filesByType[ContentType.photo] ?? []),
      'Documents': List<File>.from(
        folder.filesByType[ContentType.document] ?? [],
      ),
      'Audio': List<File>.from(folder.filesByType[ContentType.audio] ?? []),
    };
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContentTypeSheet(
        sourceName: folder.name,
        sourcePath: folder.path,
        filesByType: filesByType,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer loading list
// ─────────────────────────────────────────────────────────────────────────────

class _FolderShimmer extends StatelessWidget {
  final bool isDark;
  const _FolderShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final highlight = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.5)
        : Colors.grey.shade200;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 60),
        itemCount: 10,
        itemBuilder: (_, index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
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
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isSearch;
  final Color textMuted;
  final Color primaryColor;

  const _EmptyState({
    required this.isSearch,
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
            Icon(
              isSearch ? Icons.search_off_rounded : Icons.folder_off_rounded,
              size: 56,
              color: textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
            Text(
              isSearch
                  ? 'No folders match your search'
                  : 'No media folders found on this device',
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final Color textMuted;
  final Color primaryColor;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.textMuted,
    required this.primaryColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.darkDeleteRed.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 13),
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
