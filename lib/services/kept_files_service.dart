import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persists:
///  - "kept" file names per folder (Hive box 'kept_files')
///  - cleaned-folder records per folder (Hive box 'cleaned_folders')
///
/// Keys are md5(folderPath) to stay short and stable even if mount point
/// changes.  Values store file *names* only (not full paths) for the same
/// reason.
class KeptFilesService {
  static const _keptBox = 'kept_files';
  static const _cleanedBox = 'cleaned_folders';

  // ── Hive initialisation ────────────────────────────────────────────────────

  /// Call once from main.dart after Hive.initFlutter().
  static Future<void> init() async {
    await Hive.openBox<List>(_keptBox);
    await Hive.openBox<Map>(_cleanedBox);
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  static Box<List> get _kept => Hive.box<List>(_keptBox);
  static Box<Map> get _cleaned => Hive.box<Map>(_cleanedBox);

  static String _key(String folderPath) =>
      md5.convert(utf8.encode(folderPath)).toString();

  // ── Kept-file API ──────────────────────────────────────────────────────────

  /// Returns the subset of [files] whose names have NOT yet been seen
  /// (i.e. kept) for this folder.  If [showAll] is true the original list
  /// is returned unchanged.
  static List<T> filter<T extends FileSystemEntityLike>(
    String folderPath,
    List<T> files, {
    bool showAll = false,
  }) {
    if (showAll) return files;
    final key = _key(folderPath);
    final raw = _kept.get(key);
    if (raw == null || raw.isEmpty) return files;
    final seen = Set<String>.from(raw.cast<String>());
    return files
        .where((f) => !seen.contains(f.keptFileName))
        .toList();
  }

  /// Persists [fileNames] as "kept" for [folderPath].
  /// Merges with any previously stored names (idempotent).
  static Future<void> markKept(
      String folderPath, Iterable<String> fileNames) async {
    final key = _key(folderPath);
    final existing = Set<String>.from(
        (_kept.get(key) ?? []).cast<String>());
    existing.addAll(fileNames);
    await _kept.put(key, existing.toList());
  }

  /// Clears all kept-file records for [folderPath].
  /// Used when "Show everything" is chosen in settings.
  static Future<void> clearKept(String folderPath) async {
    await _kept.delete(_key(folderPath));
  }

  // ── Cleaned-folder API ─────────────────────────────────────────────────────

  /// Marks [folderPath] as cleaned with [fileCountAfterCleaning].
  /// Should be called AFTER deletion has fully completed.
  static Future<void> markFolderCleaned(
      String folderPath, int fileCountAfterCleaning) async {
    final key = _key(folderPath);
    await _cleaned.put(key, {
      'path': folderPath,
      'count': fileCountAfterCleaning,
      'cleanedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Returns true when:
  ///  - A clean record exists for [folderPath], AND
  ///  - [currentFileCount] is not greater than the count at clean time
  ///    (no new files have been added).
  /// If new files are detected, it automatically removes the stale record
  /// so the folder reappears.
  static bool isCleanedAndUnchanged(
      String folderPath, int currentFileCount) {
    final key = _key(folderPath);
    final record = _cleaned.get(key);
    if (record == null) return false;
    final countAtClean = (record['count'] as int?) ?? 0;
    if (currentFileCount > countAtClean) {
      // New files arrived after cleaning — auto-remove stale record.
      _cleaned.delete(key);
      return false;
    }
    return true;
  }

  /// Removes the cleaned record for [folderPath].
  static Future<void> clearCleaned(String folderPath) async {
    await _cleaned.delete(_key(folderPath));
  }

  /// Returns paths of all currently-cleaned folders (for debugging / debug UI).
  static List<String> cleanedFolderPaths() {
    return _cleaned.values
        .map((m) => (m['path'] as String?) ?? '')
        .where((p) => p.isNotEmpty)
        .toList();
  }
}

// ── Thin interface so filter() stays generic ───────────────────────────────

/// Anything that can be filtered by kept-file name.
abstract class FileSystemEntityLike {
  /// The file name used as the deduplication key.
  String get keptFileName;
}

/// Dart's [File] adapter so [File] works with [KeptFilesService.filter].
class KeptFile implements FileSystemEntityLike {
  final String path;
  const KeptFile(this.path);

  @override
  String get keptFileName {
    final parts = path.split('/');
    return parts.last;
  }
}
