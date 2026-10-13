import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/kept_files_service.dart';

class ContentTypeSheet extends ConsumerWidget {
  final String sourceName;
  final String sourcePath;
  final Map<String, List<File>> filesByType;

  const ContentTypeSheet({
    super.key,
    required this.sourceName,
    required this.sourcePath,
    required this.filesByType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            sourceName,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.darkPrimaryGold),
          ),
          const Text(
            'What would you like to clean?',
            style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          if (filesByType['Photos']?.isNotEmpty ?? false)
            _TypeRow(
              icon: Icons.photo_library,
              title: 'Photos & Videos',
              count: filesByType['Photos']!.length,
              bytes: _calculateSize(filesByType['Photos']!),
              onTap: () => _startSession(
                context,
                ref,
                filesByType['Photos']!,
                ContentType.photo,
                RouteNames.cleanPhoto,
              ),
            ),
          if (filesByType['Documents']?.isNotEmpty ?? false)
            _TypeRow(
              icon: Icons.article,
              title: 'Documents',
              count: filesByType['Documents']!.length,
              bytes: _calculateSize(filesByType['Documents']!),
              onTap: () => _startSession(
                context,
                ref,
                filesByType['Documents']!,
                ContentType.document,
                RouteNames.cleanDocument,
              ),
            ),
          if (filesByType['Audio']?.isNotEmpty ?? false)
            _TypeRow(
              icon: Icons.audiotrack,
              title: 'Audio & Voice Notes',
              count: filesByType['Audio']!.length,
              bytes: _calculateSize(filesByType['Audio']!),
              onTap: () => _startSession(
                context,
                ref,
                filesByType['Audio']!,
                ContentType.audio,
                RouteNames.cleanAudio,
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (filesByType['Photos']?.isNotEmpty ?? false) {
                  _startSession(
                    context,
                    ref,
                    filesByType['Photos']!,
                    ContentType.photo,
                    RouteNames.cleanPhoto,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimaryGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Cleaning All',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Session gate ────────────────────────────────────────────────────────────
  Future<void> _startSession(
    BuildContext context,
    WidgetRef ref,
    List<File> rawFiles,
    ContentType type,
    String route,
  ) async {
    final session = ref.read(sessionProvider);
    final settings = ref.read(settingsProvider);
    final showAll = settings.get(AppStrings.settings.showKeptFiles);

    // ── Gate: active session already exists ──────────────────────────────────
    if (session.status != SessionStatus.none) {
      await AppDialog.show(
        context,
        title: 'Active Session',
        description:
            'You have a "${session.activeSourceName ?? 'folder'}" session in progress.\n'
            'What would you like to do?',
        actions: [
          AppDialogAction(
            label: 'Continue old session',
            onTap: () {
              Navigator.of(context).pop(); // close sheet
              final route = _routeForType(session.activeContentType);
              if (route != null) context.push(route);
            },
          ),
          AppDialogAction(
            label: 'Start fresh (discard old)',
            onTap: () => _doStartSession(context, ref, rawFiles, type, route, showAll),
            isPrimary: true,
          ),
          AppDialogAction(
            label: 'Go to goodbye (finish old first)',
            onTap: () {
              Navigator.of(context).pop();
              context.push(RouteNames.goodbye);
            },
            isDestructive: true,
          ),
        ],
      );
      return;
    }

    _doStartSession(context, ref, rawFiles, type, route, showAll);
  }

  void _doStartSession(
    BuildContext context,
    WidgetRef ref,
    List<File> rawFiles,
    ContentType type,
    String route,
    bool showAll,
  ) {
    // ── Apply kept-file filter ───────────────────────────────────────────────
    final filtered = KeptFilesService.filter<_FileWrapper>(
      sourcePath,
      rawFiles.map((f) => _FileWrapper(f)).toList(),
      showAll: showAll,
    ).map((w) => w.file).toList();

    final filesToUse = filtered.isEmpty ? rawFiles : filtered;

    ref.read(sessionProvider.notifier).clearSession();
    ref.read(sessionProvider.notifier).startSession(
          sourceName,
          sourcePath,
          filesToUse,
          type,
        );
    Navigator.of(context).pop(); // close sheet
    context.push(route);
  }

  String? _routeForType(ContentType? type) {
    switch (type) {
      case ContentType.photo:
        return RouteNames.cleanPhoto;
      case ContentType.document:
        return RouteNames.cleanDocument;
      case ContentType.audio:
        return RouteNames.cleanAudio;
      default:
        return null;
    }
  }

  int _calculateSize(List<File> files) {
    return files.fold<int>(0, (sum, f) {
      try {
        return sum + f.lengthSync();
      } catch (_) {
        return sum;
      }
    });
  }
}

/// Thin wrapper so [KeptFilesService.filter] can work with [File] objects.
class _FileWrapper implements FileSystemEntityLike {
  final File file;
  const _FileWrapper(this.file);

  @override
  String get keptFileName => file.path.split('/').last;
}

class _TypeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final int bytes;
  final VoidCallback onTap;

  const _TypeRow({
    required this.icon,
    required this.title,
    required this.count,
    required this.bytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.darkPrimaryGold.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.darkPrimaryGold.withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.darkPrimaryGold),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(
            '$count files · ${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB',
            style:
                const TextStyle(fontSize: 13, color: AppColors.darkTextMuted)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.darkPrimaryGold),
      ),
    );
  }
}
