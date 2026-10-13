import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/whatsapp_category.dart';
import '../models/whatsapp_media_file.dart';
import '../services/whatsapp_scan_service.dart';
import '../services/deletion_service.dart';

// ── Status ─────────────────────────────────────────────────────────────────────
enum CleanerStatus { idle, loading, loaded, error }

// ── State ──────────────────────────────────────────────────────────────────────
class WhatsAppCleanerState {
  final CleanerStatus status;
  final Map<WhatsAppCategory, List<WhatsAppMediaFile>> filesByCategory;
  final Set<String> selectedPaths;
  final bool sortByDate;
  final String? errorMessage;
  final int deletedBytes;

  const WhatsAppCleanerState({
    this.status = CleanerStatus.idle,
    this.filesByCategory = const {},
    this.selectedPaths = const {},
    this.sortByDate = false,
    this.errorMessage,
    this.deletedBytes = 0,
  });

  WhatsAppCleanerState copyWith({
    CleanerStatus? status,
    Map<WhatsAppCategory, List<WhatsAppMediaFile>>? filesByCategory,
    Set<String>? selectedPaths,
    bool? sortByDate,
    Object? errorMessage = _sentinel,
    int? deletedBytes,
  }) {
    return WhatsAppCleanerState(
      status: status ?? this.status,
      filesByCategory: filesByCategory ?? this.filesByCategory,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      sortByDate: sortByDate ?? this.sortByDate,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      deletedBytes: deletedBytes ?? this.deletedBytes,
    );
  }

  // ── Computed helpers ──────────────────────────────────────────────────────────
  int get totalFiles =>
      filesByCategory.values.fold(0, (acc, l) => acc + l.length);

  int get totalBytes => filesByCategory.values
      .fold(0, (acc, l) => acc + l.fold(0, (s, f) => s + f.sizeInBytes));

  int get selectedBytes {
    int total = 0;
    for (final list in filesByCategory.values) {
      for (final f in list) {
        if (selectedPaths.contains(f.filePath)) total += f.sizeInBytes;
      }
    }
    return total;
  }

  int totalFilesForCategory(WhatsAppCategory cat) =>
      filesByCategory[cat]?.length ?? 0;

  int totalBytesForCategory(WhatsAppCategory cat) =>
      (filesByCategory[cat] ?? []).fold(0, (s, f) => s + f.sizeInBytes);

  List<WhatsAppMediaFile> filesForCategory(WhatsAppCategory cat) {
    final list = List<WhatsAppMediaFile>.from(filesByCategory[cat] ?? []);
    if (sortByDate) {
      list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    } else {
      list.sort((a, b) => b.sizeInBytes.compareTo(a.sizeInBytes));
    }
    return list;
  }

  bool isSelected(String filePath) => selectedPaths.contains(filePath);
}

// Sentinel to distinguish null from "not provided" in copyWith.
const Object _sentinel = Object();

// ── Notifier ───────────────────────────────────────────────────────────────────
class WhatsAppCleanerNotifier extends StateNotifier<WhatsAppCleanerState> {
  WhatsAppCleanerNotifier() : super(const WhatsAppCleanerState());

  final _scanService = WhatsAppScanService();
  final _deletionService = DeletionService();

  /// The effective selection limit — set by the caller after reading
  /// [deviceCapabilityProvider] and/or the user's settings override.
  int selectionLimit = 30;

  Future<void> scan() async {
    state = state.copyWith(status: CleanerStatus.loading, errorMessage: null);
    try {
      final files = await _scanService.scanByCategory();
      state = state.copyWith(
        status: CleanerStatus.loaded,
        filesByCategory: files,
        selectedPaths: {},
        deletedBytes: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: CleanerStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void refresh() {
    state = const WhatsAppCleanerState();
    scan();
  }

  void toggleSort() => state = state.copyWith(sortByDate: !state.sortByDate);

  /// Attempts to toggle selection. Returns [SelectionResult.limitReached] if
  /// adding would exceed [selectionLimit], so the UI can show a warning dialog.
  SelectionResult toggleSelection(String filePath) {
    final next = Set<String>.from(state.selectedPaths);
    if (next.contains(filePath)) {
      next.remove(filePath);
      state = state.copyWith(selectedPaths: next);
      return SelectionResult.ok;
    }
    if (next.length >= selectionLimit) {
      return SelectionResult.limitReached;
    }
    next.add(filePath);
    state = state.copyWith(selectedPaths: next);
    return SelectionResult.ok;
  }

  /// Force-selects [filePath] even if the limit is reached (user confirmed).
  void forceSelect(String filePath) {
    final next = Set<String>.from(state.selectedPaths)..add(filePath);
    state = state.copyWith(selectedPaths: next);
  }

  void selectAll(WhatsAppCategory cat) {
    final all = state.filesByCategory[cat] ?? [];
    final next = Set<String>.from(state.selectedPaths)
      ..addAll(all.map((f) => f.filePath));
    state = state.copyWith(selectedPaths: next);
  }

  void deselectAll([WhatsAppCategory? cat]) {
    if (cat == null) {
      state = state.copyWith(selectedPaths: {});
    } else {
      final removing =
          (state.filesByCategory[cat] ?? []).map((f) => f.filePath).toSet();
      final next = Set<String>.from(state.selectedPaths)
        ..removeAll(removing);
      state = state.copyWith(selectedPaths: next);
    }
  }

  Future<void> deleteSelected() async {
    if (state.selectedPaths.isEmpty) return;

    final toDelete = <File>[];
    final deletedPaths = Set<String>.from(state.selectedPaths);

    for (final list in state.filesByCategory.values) {
      for (final f in list) {
        if (deletedPaths.contains(f.filePath)) {
          toDelete.add(File(f.filePath));
        }
      }
    }

    final bytesFreed = state.selectedBytes;
    await _deletionService.executeDeletion(toDelete);

    final updated = <WhatsAppCategory, List<WhatsAppMediaFile>>{};
    for (final entry in state.filesByCategory.entries) {
      updated[entry.key] = entry.value
          .where((f) => !deletedPaths.contains(f.filePath))
          .toList();
    }

    state = state.copyWith(
      filesByCategory: updated,
      selectedPaths: {},
      deletedBytes: state.deletedBytes + bytesFreed,
    );
  }
}

/// Return value from [WhatsAppCleanerNotifier.toggleSelection].
enum SelectionResult { ok, limitReached }

// ── Provider ───────────────────────────────────────────────────────────────────
final whatsAppCleanerProvider =
    StateNotifierProvider<WhatsAppCleanerNotifier, WhatsAppCleanerState>(
  (ref) => WhatsAppCleanerNotifier(),
);
