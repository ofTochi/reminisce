import 'package:hive/hive.dart';

part 'saved_session_state.g.dart';

@HiveType(typeId: 1)
class SavedSessionState {
  @HiveField(0)
  final String sourceType; // 'folder' or 'whatsapp'
  @HiveField(1)
  final String sourceName;
  @HiveField(2)
  final String sourcePath;
  @HiveField(3)
  final int contentType; // 0=photo, 1=doc, 2=audio
  @HiveField(4)
  final int currentIndex;
  @HiveField(5)
  final List<String> markedFilePaths;

  SavedSessionState({
    required this.sourceType,
    required this.sourceName,
    required this.sourcePath,
    required this.contentType,
    required this.currentIndex,
    required this.markedFilePaths,
  });
}
