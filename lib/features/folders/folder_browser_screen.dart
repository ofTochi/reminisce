import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_background.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/folders_provider.dart';
import '../content_type/content_type_sheet.dart';
import '../../providers/session_provider.dart';
import '../../models/device_folder.dart';

class FolderBrowserScreen extends ConsumerWidget {
  const FolderBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersData = ref.watch(deviceFoldersProvider);

    return AppBackground(
      gradientStyle: 2,
      child: Column(
        children: [
          _buildHeader(context),
          // _buildSuggestionsRow(context, foldersData),
          const Divider(color: Colors.white10),
          Expanded(
            child: foldersData.when(
              data: (folders) {
                if (folders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No media folders found.',
                      style: TextStyle(color: AppColors.darkTextMuted),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return _FolderTile(folder: folder);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.darkPrimaryGold,
                ),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Device Folders',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'Playfair Display',
              ),
            ),
          ),
          IconButton(
            onPressed: () {}, // Refresh?
            icon: const Icon(Icons.refresh, color: AppColors.darkPrimaryGold),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsRow(
    BuildContext context,
    AsyncValue<List<DeviceFolder>> foldersData,
  ) {
    return foldersData.when(
      data: (folders) {
        final suggestions = folders.take(6).toList(); // Top 6 by size
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Text(
                'QUICK CLEAN SUGGESTIONS',
                style: TextStyle(
                  color: AppColors.darkPrimaryGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final folder = suggestions[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        folder.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppColors.darkSurface,
                      side: BorderSide(
                        color: AppColors.darkPrimaryGold.withOpacity(0.4),
                      ),
                      onPressed: () => _openFolder(context, folder),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _openFolder(BuildContext context, DeviceFolder folder) {
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
      builder: (context) => ContentTypeSheet(
        sourceName: folder.name,
        sourcePath: folder.path,
        filesByType: filesByType,
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final DeviceFolder folder;

  const _FolderTile({required this.folder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.folder_copy_outlined,
          color: AppColors.darkPrimaryGold,
          size: 24,
        ),
      ),
      title: Text(
        folder.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        '${folder.fileCount} items · ${(folder.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
        style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.darkTextMuted,
        size: 20,
      ),
      onTap: () {
        final filesByType = {
          'Photos': List<File>.from(
            folder.filesByType[ContentType.photo] ?? [],
          ),
          'Documents': List<File>.from(
            folder.filesByType[ContentType.document] ?? [],
          ),
          'Audio': List<File>.from(folder.filesByType[ContentType.audio] ?? []),
        };

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ContentTypeSheet(
            sourceName: folder.name,
            sourcePath: folder.path,
            filesByType: filesByType,
          ),
        );
      },
    );
  }
}
