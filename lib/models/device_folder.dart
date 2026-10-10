import 'dart:io';
import '../providers/session_provider.dart';

class DeviceFolder {
  final String path;
  final String name;
  final int fileCount;
  final int totalBytes;
  final Map<ContentType, List<File>> filesByType;

  DeviceFolder({
    required this.path,
    required this.name,
    required this.fileCount,
    required this.totalBytes,
    required this.filesByType,
  });
}
