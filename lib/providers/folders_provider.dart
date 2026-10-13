import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../models/device_folder.dart';
import '../services/kept_files_service.dart';
import 'session_provider.dart';

part 'folders_provider.g.dart';

@riverpod
Future<List<DeviceFolder>> deviceFolders(DeviceFoldersRef ref) async {
  // Check for permissions before scanning
  final status = await Permission.manageExternalStorage.status;
  final legacyStatus = await Permission.storage.status;
  final photosStatus = await Permission.photos.status;

  if (!status.isGranted && !legacyStatus.isGranted && !photosStatus.isGranted) {
    return [];
  }

  final List<DeviceFolder> folders = [];
  
  // Base directory for Android storage
  const String rootPath = '/storage/emulated/0';
  final rootDir = Directory(rootPath);
  
  if (!await rootDir.exists()) return [];

  try {
    final List<FileSystemEntity> subDirs = await rootDir.list().where((e) => e is Directory).toList();
    
    // We also want to specifically check some deep common paths if they exist
    final List<String> deepPaths = [
      '/storage/emulated/0/DCIM/Camera',
      '/storage/emulated/0/Pictures/Screenshots',
      '/storage/emulated/0/WhatsApp/Media/WhatsApp Images',
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Images',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Telegram/Telegram Images',
    ];

    final Set<String> allPaths = subDirs.map((e) => e.path).toSet()..addAll(deepPaths);

    for (final path in allPaths) {
      if (path.split('/').last.startsWith('.')) continue; // Skip hidden
      
      final dir = Directory(path);
      if (await dir.exists()) {
        try {
          final List<FileSystemEntity> entities = await dir.list().toList();
          final List<File> files = entities.whereType<File>().toList();
          if (files.isEmpty) continue;

          int totalSize = 0;
          final Map<ContentType, List<File>> filesByType = {
            ContentType.photo: [],
            ContentType.document: [],
            ContentType.audio: [],
          };

          for (final file in files) {
            try {
              final size = await file.length();
              totalSize += size;
              
              final ext = p.extension(file.path).toLowerCase();
              if (['.jpg', '.jpeg', '.png', '.webp', '.mp4', '.mov'].contains(ext)) {
                filesByType[ContentType.photo]!.add(file);
              } else if (['.pdf', '.doc', '.docx', '.txt'].contains(ext)) {
                filesByType[ContentType.document]!.add(file);
              } else if (['.mp3', '.ogg', '.wav', '.m4a'].contains(ext)) {
                filesByType[ContentType.audio]!.add(file);
              }
            } catch (_) {}
          }

          if (filesByType.values.every((list) => list.isEmpty)) continue;

          folders.add(
            DeviceFolder(
              path: path,
              name: p.basename(path),
              fileCount: files.length,
              totalBytes: totalSize,
              filesByType: filesByType,
            ),
          );
        } catch (e) {
          debugPrint('Error scanning folder $path: $e');
        }
      }
    }
  } catch (e) {
    debugPrint('General folders scan error: $e');
  }

  // Sort by bytes descending
  folders.sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
  return folders;
}

// ── Cleaned-folder filter layer ────────────────────────────────────────────────
// This sits on top of deviceFoldersProvider without touching codegen.

/// Simple toggle: when true show all folders including cleaned ones.
final showCleanedFoldersProvider =
    StateNotifierProvider<_ShowCleanedNotifier, bool>(
  (_) => _ShowCleanedNotifier(),
);

class _ShowCleanedNotifier extends StateNotifier<bool> {
  _ShowCleanedNotifier() : super(false);
  void toggle() => state = !state;
}

/// The list that [FolderBrowserScreen] should actually consume.
/// Hides cleaned-and-unchanged folders unless [showCleanedFoldersProvider] is true.
final filteredDeviceFoldersProvider =
    FutureProvider<List<DeviceFolder>>((ref) async {
  final all = await ref.watch(deviceFoldersProvider.future);
  final showCleaned = ref.watch(showCleanedFoldersProvider);
  if (showCleaned) return all;
  return all.where((folder) {
    return !KeptFilesService.isCleanedAndUnchanged(folder.path, folder.fileCount);
  }).toList();
});
