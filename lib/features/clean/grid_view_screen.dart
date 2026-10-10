import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';

class GridViewScreen extends ConsumerStatefulWidget {
  const GridViewScreen({super.key});

  @override
  ConsumerState<GridViewScreen> createState() => _GridViewScreenState();
}

class _GridViewScreenState extends ConsumerState<GridViewScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final sessionNotifier = ref.read(sessionProvider.notifier);

    return AppBackground(
      gradientStyle: 2,
      child: Column(
        children: [
          _buildHeader(context),
          _buildActionRow(session, sessionNotifier),
          Expanded(
            child: _isGridView 
              ? _buildGridView(session, sessionNotifier)
              : _buildListView(session, sessionNotifier),
          ),
          _buildBottomActionBar(context, session),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Selection Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            color: AppColors.darkPrimaryGold,
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Save', style: TextStyle(color: AppColors.darkPrimaryGold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(SessionState session, Session sessionNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${session.markedFiles.length} files selected',
            style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  for (final file in session.allFiles) {
                    if (!session.markedFiles.contains(file)) {
                      sessionNotifier.markFile(file);
                    }
                  }
                },
                child: const Text('Select All', style: TextStyle(color: AppColors.darkPrimaryGold, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  for (final file in session.allFiles) {
                    sessionNotifier.unmarkFile(file);
                  }
                },
                child: const Text('Deselect All', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(SessionState session, Session sessionNotifier) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: session.allFiles.length,
      itemBuilder: (context, index) {
        final file = session.allFiles[index];
        final isMarked = session.markedFiles.contains(file);
        return _MediaItem(
          file: file,
          isMarked: isMarked,
          isGrid: true,
          onTap: () {
            if (isMarked) {
              sessionNotifier.unmarkFile(file);
            } else {
              sessionNotifier.markFile(file);
            }
          },
        );
      },
    );
  }

  Widget _buildListView(SessionState session, Session sessionNotifier) {
    return ListView.builder(
      itemCount: session.allFiles.length,
      itemBuilder: (context, index) {
        final file = session.allFiles[index];
        final isMarked = session.markedFiles.contains(file);
        return _MediaItem(
          file: file,
          isMarked: isMarked,
          isGrid: false,
          onTap: () {
            if (isMarked) {
              sessionNotifier.unmarkFile(file);
            } else {
              sessionNotifier.markFile(file);
            }
          },
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context, SessionState session) {
    final totalSize = session.markedFiles.fold<int>(0, (sum, f) => sum + (f is File ? f.statSync().size : 0));
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${session.markedFiles.length} to delete',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Recover ${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB',
                style: const TextStyle(color: AppColors.darkKeepGreen, fontSize: 12),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: session.markedFiles.isNotEmpty ? () => context.push('/goodbye') : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkDeleteRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MediaItem extends StatelessWidget {
  final FileSystemEntity file;
  final bool isMarked;
  final bool isGrid;
  final VoidCallback onTap;

  const _MediaItem({
    required this.file,
    required this.isMarked,
    required this.isGrid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnail(),
            if (isMarked)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.darkDeleteRed, width: 3),
                  color: Colors.black.withOpacity(0.4),
                ),
                child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 32)),
              ),
            if (!isMarked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final stats = file.statSync();
    final name = file.path.split('/').last;
    final size = '${(stats.size / (1024 * 1024)).toStringAsFixed(1)} MB';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.darkSurface,
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildThumbnail(),
      ),
      title: Text(name, style: const TextStyle(fontSize: 14, color: Colors.white), overflow: TextOverflow.ellipsis),
      subtitle: Text(size, style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
      trailing: Checkbox(
        value: isMarked,
        onChanged: (_) => onTap(),
        activeColor: AppColors.darkDeleteRed,
        side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildThumbnail() {
    final path = file.path.toLowerCase();
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.webp')) {
      return Image.file(File(file.path), fit: BoxFit.cover);
    }
    return const Icon(Icons.insert_drive_file, color: AppColors.darkTextMuted);
  }
}
