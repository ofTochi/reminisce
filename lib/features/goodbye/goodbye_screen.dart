import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reminisce/core/router/route_names.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/analytics_provider.dart';
import '../../../services/deletion_service.dart';
import '../../../models/cleaning_session.dart';

class GoodbyeScreen extends ConsumerWidget {
  const GoodbyeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final sessionNotifier = ref.read(sessionProvider.notifier);
    final totalSize = session.markedFiles.fold<int>(0, (sum, f) => sum + (f is File ? f.lengthSync() : 0));
    final double mbFreed = totalSize / (1024 * 1024);

    return AppBackground(
      gradientStyle: 2,
      child: PopScope(
        canPop: session.markedFiles.isEmpty,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          _showExitGuard(context);
        },
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Marked for Removal', style: TextStyle(fontFamily: 'Playfair Display')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Text(
                    '${session.markedFiles.length} files · ${mbFreed.toStringAsFixed(1)} MB will be freed',
                    style: const TextStyle(color: AppColors.darkPrimaryGold, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: session.markedFiles.length,
                itemBuilder: (context, index) {
                  final file = session.markedFiles[index];
                  return GestureDetector(
                    onTap: () => sessionNotifier.unmarkFile(file),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.darkDeleteRed, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _buildThumbnail(file),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('tap to unmark', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
            ),
            _buildActionArea(context, ref, session, mbFreed),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(FileSystemEntity file) {
    if (file.path.toLowerCase().endsWith('.jpg') || file.path.toLowerCase().endsWith('.jpeg') || file.path.toLowerCase().endsWith('.png')) {
      return Image.file(File(file.path), fit: BoxFit.cover);
    }
    return const Icon(Icons.insert_drive_file, color: AppColors.darkTextMuted, size: 20);
  }

  Widget _buildActionArea(BuildContext context, WidgetRef ref, SessionState session, double mbFreed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "This cannot be undone.",
            style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: () => _showConfirmationDialog(context, ref, session, mbFreed),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkDeleteRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Say Goodbye (${session.markedFiles.length} files)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, WidgetRef ref, SessionState session, double mbFreed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('They had a good run.', style: TextStyle(fontFamily: 'Playfair Display', color: AppColors.darkPrimaryGold)),
        content: Text('Deleting ${session.markedFiles.length} files will free ${mbFreed.toStringAsFixed(1)} MB. Once gone, gone forever.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not yet'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _executeDeletion(context, ref, session, mbFreed);
            },
            child: const Text('Free them', style: TextStyle(color: AppColors.darkDeleteRed)),
          ),
        ],
      ),
    );
  }

  void _executeDeletion(BuildContext context, WidgetRef ref, SessionState session, double mbFreed) async {
    final deletedCount = session.markedFiles.length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DeletionProgressDialog(
        files: session.markedFiles,
        onComplete: () {
          ref.read(analyticsProvider.notifier).addSession(CleaningSession(
            sourceName: session.activeSourceName ?? 'Unknown',
            date: DateTime.now(),
            filesDeleted: deletedCount,
            mbFreed: mbFreed,
          ));
          ref.read(sessionProvider.notifier).clearSession();
          Navigator.pop(context); // Pop dialog
          _showSuccessSheet(context, deletedCount, mbFreed);
        },
      ),
    );
  }

  void _showSuccessSheet(BuildContext context, int count, double mb) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: AppColors.darkPrimaryGold, size: 64),
            const SizedBox(height: 16),
            Text('You freed ${mb.toStringAsFixed(1)} MB!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('$count files deleted from your storage', style: const TextStyle(color: AppColors.darkTextMuted)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go(RouteNames.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitGuard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wait!'),
        content: const Text('You have files waiting to be freed. Delete before you go?'),
        actions: [
          TextButton(onPressed: () => context.go(RouteNames.home), child: const Text('Not yet')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Stay here')),
        ],
      ),
    );
  }
}

class _DeletionProgressDialog extends StatefulWidget {
  final List<FileSystemEntity> files;
  final VoidCallback onComplete;

  const _DeletionProgressDialog({required this.files, required this.onComplete});

  @override
  State<_DeletionProgressDialog> createState() => _DeletionProgressDialogState();
}

class _DeletionProgressDialogState extends State<_DeletionProgressDialog> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() async {
    await for (final p in DeletionService().executeDeletionStream(widget.files)) {
      if (mounted) {
        setState(() => _progress = p);
      }
    }
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Icon(Icons.delete_sweep, color: AppColors.darkDeleteRed, size: 48),
             const SizedBox(height: 16),
             const Text(
               'Deleting Files...',
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 24),
             LinearProgressIndicator(
               value: _progress,
               backgroundColor: Colors.white.withOpacity(0.1),
               color: AppColors.darkDeleteRed,
               minHeight: 8,
               borderRadius: BorderRadius.circular(4),
             ),
             const SizedBox(height: 12),
             Text(
               '${(_progress * 100).toInt()}% complete',
               style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
             ),
          ],
        ),
      ),
    );
  }
}
