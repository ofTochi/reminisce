import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';

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
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            sourceName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.darkPrimaryGold),
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
              onTap: () {
                ref.read(sessionProvider.notifier).startSession(
                  sourceName,
                  sourcePath,
                  filesByType['Photos']!,
                  ContentType.photo,
                );
                context.pop();
                context.push('/clean/photo');
              },
            ),
          if (filesByType['Documents']?.isNotEmpty ?? false)
            _TypeRow(
              icon: Icons.article,
              title: 'Documents',
              count: filesByType['Documents']!.length,
              bytes: _calculateSize(filesByType['Documents']!),
              onTap: () {
                ref.read(sessionProvider.notifier).startSession(
                  sourceName,
                  sourcePath,
                  filesByType['Documents']!,
                  ContentType.document,
                );
                context.pop();
                context.push('/clean/document');
              },
            ),
          if (filesByType['Audio']?.isNotEmpty ?? false)
            _TypeRow(
              icon: Icons.audiotrack,
              title: 'Audio & Voice Notes',
              count: filesByType['Audio']!.length,
              bytes: _calculateSize(filesByType['Audio']!),
              onTap: () {
                ref.read(sessionProvider.notifier).startSession(
                  sourceName,
                  sourcePath,
                  filesByType['Audio']!,
                  ContentType.audio,
                );
                context.pop();
                context.push('/clean/audio');
              },
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Logic to start cleaning all types iteratively
                if (filesByType['Photos']?.isNotEmpty ?? false) {
                  ref.read(sessionProvider.notifier).startSession(
                    sourceName,
                    sourcePath,
                    filesByType['Photos']!,
                    ContentType.photo,
                  );
                  context.pop();
                  context.push('/clean/photo');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimaryGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Cleaning All', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  int _calculateSize(List<File> files) {
    return files.fold<int>(0, (sum, f) => sum + f.lengthSync());
  }
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
        side: BorderSide(color: AppColors.darkPrimaryGold.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.darkPrimaryGold.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.darkPrimaryGold),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text('$count files · ${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB', style: const TextStyle(fontSize: 13, color: AppColors.darkTextMuted)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.darkPrimaryGold),
      ),
    );
  }
}
