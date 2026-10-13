import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../models/whatsapp_category.dart';
import '../../../models/whatsapp_media_file.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category Card — dashboard grid tile
// ─────────────────────────────────────────────────────────────────────────────

class WhatsAppCategoryCard extends StatelessWidget {
  final WhatsAppCategory category;
  final List<WhatsAppMediaFile> files;
  final int totalBytesAll;
  final VoidCallback onTap;

  const WhatsAppCategoryCard({
    super.key,
    required this.category,
    required this.files,
    required this.totalBytesAll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = category.accentColor;
    final int totalBytes =
        files.fold(0, (acc, f) => acc + f.sizeInBytes);
    final double fraction =
        totalBytesAll > 0 ? totalBytes / totalBytesAll : 0.0;
    final String sizeLabel = _formatBytes(totalBytes);

    return BouncingPressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    accent.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.06),
                  ]
                : [
                    accent.withValues(alpha: 0.12),
                    accent.withValues(alpha: 0.04),
                  ],
          ),
          border: Border.all(
            color: accent.withValues(alpha: isDark ? 0.28 : 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.14 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.22 : 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon, color: accent, size: 20),
            ),
            const Spacer(),
            // Label
            Text(
              category.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${files.length} files · $sizeLabel',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 8),
            // Proportion bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 4,
                backgroundColor: accent.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// File Item — used in the category detail list & grid
// ─────────────────────────────────────────────────────────────────────────────

class WhatsAppFileItem extends StatelessWidget {
  final WhatsAppMediaFile mediaFile;
  final bool isSelected;
  final bool isGrid;
  final VoidCallback onTap;

  const WhatsAppFileItem({
    super.key,
    required this.mediaFile,
    required this.isSelected,
    required this.isGrid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) return _GridItem(mediaFile: mediaFile, isSelected: isSelected, onTap: onTap);
    return _ListItem(mediaFile: mediaFile, isSelected: isSelected, onTap: onTap);
  }

  static String formatBytes(int bytes) => _formatBytes(bytes);
}

class _GridItem extends StatelessWidget {
  final WhatsAppMediaFile mediaFile;
  final bool isSelected;
  final VoidCallback onTap;

  const _GridItem({
    required this.mediaFile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.darkDeleteRed
                  : Colors.transparent,
              width: 2.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Thumbnail(mediaFile: mediaFile),
              // Dark overlay on selection
              AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              // Empty circle (unselected state)
              if (!isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7), width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final WhatsAppMediaFile mediaFile;
  final bool isSelected;
  final VoidCallback onTap;

  const _ListItem({
    required this.mediaFile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
        ),
        clipBehavior: Clip.antiAlias,
        child: _Thumbnail(mediaFile: mediaFile),
      ),
      title: Text(
        mediaFile.fileName,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        '${_formatBytes(mediaFile.sizeInBytes)} · ${_formatDate(mediaFile.lastModified)}',
        style: TextStyle(color: textMuted, fontSize: 11),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (_) {
          HapticFeedback.selectionClick();
          onTap();
        },
        activeColor: AppColors.darkDeleteRed,
        side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final WhatsAppMediaFile mediaFile;
  const _Thumbnail({required this.mediaFile});

  @override
  Widget build(BuildContext context) {
    if (mediaFile.isImage) {
      return Image.file(
        File(mediaFile.filePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _iconFallback(context),
        cacheWidth: 256,
      );
    }
    if (mediaFile.isVideo) {
      return _iconFallback(context, icon: Icons.play_circle_outline_rounded, color: const Color(0xFFE91E63));
    }
    return _iconFallback(context);
  }

  Widget _iconFallback(BuildContext context,
      {IconData icon = Icons.insert_drive_file_rounded, Color? color}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: color ??
            mediaFile.category.accentColor.withValues(alpha: 0.7),
        size: 26,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer placeholders
// ─────────────────────────────────────────────────────────────────────────────

class WhatsAppCleanerShimmer extends StatelessWidget {
  const WhatsAppCleanerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final highlight = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.5)
        : Colors.grey.shade200;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card shimmer
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Grid shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: List.generate(
                6,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category detail shimmer rows
// ─────────────────────────────────────────────────────────────────────────────

class WhatsAppCategoryShimmer extends StatelessWidget {
  final bool isGrid;
  const WhatsAppCategoryShimmer({super.key, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final highlight = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.5)
        : Colors.grey.shade200;

    if (isGrid) {
      return Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: GridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          children: List.generate(
            12,
            (_) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────────────────────────

class WhatsAppEmptyState extends StatelessWidget {
  final String message;
  const WhatsAppEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cleaning_services_rounded,
              size: 64,
              color: textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: textMuted, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
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

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).round()}mo ago';
  return '${(diff.inDays / 365).round()}y ago';
}

// Re-export route navigation helper used in screens
void navigateToCategory(BuildContext context, WhatsAppCategory cat) {
  context.push(RouteNames.whatsappCategory, extra: cat);
}
