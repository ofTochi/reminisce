import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_provider.g.dart';

enum SessionStatus { none, inProgress, pendingDelete }
enum ContentType { photo, document, audio }

class SessionState {
  final SessionStatus status;
  final String? activeSourceName;
  final String? activeSourcePath;
  final ContentType? activeContentType;
  final List<FileSystemEntity> allFiles;
  final int currentIndex;
  final List<FileSystemEntity> markedFiles;
  final DateTime? sessionStarted;

  SessionState({
    this.status = SessionStatus.none,
    this.activeSourceName,
    this.activeSourcePath,
    this.activeContentType,
    this.allFiles = const [],
    this.currentIndex = 0,
    this.markedFiles = const [],
    this.sessionStarted,
  });

  SessionState copyWith({
    SessionStatus? status,
    String? activeSourceName,
    String? activeSourcePath,
    ContentType? activeContentType,
    List<FileSystemEntity>? allFiles,
    int? currentIndex,
    List<FileSystemEntity>? markedFiles,
    DateTime? sessionStarted,
  }) {
    return SessionState(
      status: status ?? this.status,
      activeSourceName: activeSourceName ?? this.activeSourceName,
      activeSourcePath: activeSourcePath ?? this.activeSourcePath,
      activeContentType: activeContentType ?? this.activeContentType,
      allFiles: allFiles ?? this.allFiles,
      currentIndex: currentIndex ?? this.currentIndex,
      markedFiles: markedFiles ?? this.markedFiles,
      sessionStarted: sessionStarted ?? this.sessionStarted,
    );
  }
}

@riverpod
class Session extends _$Session {
  @override
  SessionState build() => SessionState();

  void startSession(String sourceName, String sourcePath, List<FileSystemEntity> files, ContentType type) {
    state = state.copyWith(
      status: SessionStatus.inProgress,
      activeSourceName: sourceName,
      activeSourcePath: sourcePath,
      allFiles: files,
      activeContentType: type,
      currentIndex: 0,
      markedFiles: [],
      sessionStarted: DateTime.now(),
    );
  }

  void markFile(FileSystemEntity file) {
    final newList = List<FileSystemEntity>.from(state.markedFiles)..add(file);
    state = state.copyWith(markedFiles: newList);
  }

  void unmarkFile(FileSystemEntity file) {
    final newList = List<FileSystemEntity>.from(state.markedFiles)..remove(file);
    state = state.copyWith(markedFiles: newList);
  }

  void undoLastSwipe() {
    if (state.currentIndex > 0) {
      final prevIndex = state.currentIndex - 1;
      final prevFile = state.allFiles[prevIndex];
      final newList = List<FileSystemEntity>.from(state.markedFiles)..remove(prevFile);
      state = state.copyWith(
        currentIndex: prevIndex,
        markedFiles: newList,
      );
    }
  }

  void jumpToIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void completeSession() {
    state = state.copyWith(status: SessionStatus.pendingDelete);
  }

  void clearSession() {
    state = SessionState();
  }

  void replaceSession(String sourceName, String sourcePath, List<FileSystemEntity> files, ContentType type) {
    startSession(sourceName, sourcePath, files, type);
  }
}
