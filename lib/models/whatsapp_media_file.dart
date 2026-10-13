import 'dart:io';
import 'whatsapp_category.dart';

/// Strongly-typed model representing a single WhatsApp media file.
class WhatsAppMediaFile {
  final String filePath;
  final String fileName;
  final int sizeInBytes;
  final DateTime lastModified;
  final WhatsAppCategory category;

  const WhatsAppMediaFile({
    required this.filePath,
    required this.fileName,
    required this.sizeInBytes,
    required this.lastModified,
    required this.category,
  });

  /// Constructs from a [File] and a resolved [WhatsAppCategory].
  factory WhatsAppMediaFile.fromFile(File file, WhatsAppCategory category) {
    final stat = file.statSync();
    return WhatsAppMediaFile(
      filePath: file.path,
      fileName: file.uri.pathSegments.last,
      sizeInBytes: stat.size,
      lastModified: stat.modified,
      category: category,
    );
  }

  /// Whether this file is an image and can be shown as a thumbnail.
  bool get isImage {
    final ext = filePath.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.webp') ||
        ext.endsWith('.heic');
  }

  /// Whether this file is a video.
  bool get isVideo {
    final ext = filePath.toLowerCase();
    return ext.endsWith('.mp4') ||
        ext.endsWith('.mov') ||
        ext.endsWith('.3gp') ||
        ext.endsWith('.mkv') ||
        ext.endsWith('.avi');
  }

  File get file => File(filePath);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhatsAppMediaFile && other.filePath == filePath;

  @override
  int get hashCode => filePath.hashCode;
}
