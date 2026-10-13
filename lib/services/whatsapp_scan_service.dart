import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path/path.dart' as p;
import '../models/whatsapp_contact.dart';
import '../models/whatsapp_category.dart';
import '../models/whatsapp_media_file.dart';

class WhatsAppScanService {
  static const List<String> _possiblePaths = [
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media',
    '/storage/emulated/0/WhatsApp/Media',
    '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media',
    '/storage/emulated/0/WhatsApp Business/Media',
    '/sdcard/Android/media/com.whatsapp/WhatsApp/Media',
    '/sdcard/WhatsApp/Media',
  ];

  // ── System / meta files to skip ─────────────────────────────────────────────
  static const Set<String> _skipFileNames = {'.nomedia', '.thumbnail', '.tmp'};

  /// Returns true if a file should be excluded from scan results.
  static bool _isSystemFile(String path) {
    final name = p.basename(path);
    if (name.startsWith('.')) return true;
    return _skipFileNames.contains(name.toLowerCase());
  }

  /// Resolves the [WhatsAppCategory] for a file given its containing [folderName]
  /// and falling back to file extension matching.
  static WhatsAppCategory? _resolveCategory(String folderName, String ext, String filePath) {
    final fl = folderName.toLowerCase();
    final fp = filePath.toLowerCase();

    // Sent subfolders → always SentMedia
    if (fp.contains('/sent/') || fp.contains('\\sent\\')) {
      return WhatsAppCategory.sentMedia;
    }

    for (final cat in WhatsAppCategory.values) {
      if (cat == WhatsAppCategory.sentMedia) continue; // handled above
      for (final kw in cat.directoryKeywords) {
        if (fl.contains(kw)) return cat;
      }
    }
    // Extension fallback
    for (final cat in WhatsAppCategory.values) {
      if (cat == WhatsAppCategory.sentMedia) continue;
      if (cat.extensions.contains(ext)) return cat;
    }
    return null;
  }

  /// Scans all WhatsApp media paths and returns files grouped by [WhatsAppCategory],
  /// sorted by size descending within each category.
  Future<Map<WhatsAppCategory, List<WhatsAppMediaFile>>> scanByCategory() async {
    final Map<WhatsAppCategory, List<WhatsAppMediaFile>> result = {
      for (final cat in WhatsAppCategory.values) cat: [],
    };
    final Set<String> processedPaths = {};

    try {
      for (final basePath in _possiblePaths) {
        final directory = Directory(basePath);
        if (!await directory.exists()) continue;

        try {
          final typeFolders = await directory.list().toList();
          for (final typeFolder in typeFolders) {
            if (typeFolder is! Directory) continue;
            final folderName = p.basename(typeFolder.path);

            try {
              final entities = await typeFolder.list(recursive: true).toList();
              for (final entity in entities) {
                if (entity is! File) continue;
                if (!processedPaths.add(entity.path)) continue;
                if (_isSystemFile(entity.path)) continue;

                final ext = p.extension(entity.path).toLowerCase();
                final cat = _resolveCategory(folderName, ext, entity.path);
                if (cat == null) continue;

                try {
                  result[cat]!.add(WhatsAppMediaFile.fromFile(entity, cat));
                } catch (_) {
                  // skip unreadable files
                }
              }
            } catch (e) {
              debugPrint('Error scanning subfolder ${typeFolder.path}: $e');
            }
          }
        } catch (e) {
          debugPrint('Error listing WhatsApp folder $basePath: $e');
        }
      }
    } catch (e) {
      debugPrint('General WhatsApp scan error: $e');
    }

    // Sort by size descending within each category
    for (final list in result.values) {
      list.sort((a, b) => b.sizeInBytes.compareTo(a.sizeInBytes));
    }

    return result;
  }

  /// Scans for all WhatsApp media and groups it into logical, actionable categories.
  Future<List<WhatsAppContact>> scanContacts() async {
    final Map<String, List<File>> categoryFilesMap = {
      'WhatsApp Images': [],
      'WhatsApp Videos': [],
      'WhatsApp Voice Notes': [],
      'WhatsApp Documents': [],
      'WhatsApp Audio': [],
      'WhatsApp Sent Media': [],
      'WhatsApp Stickers & GIFs': [],
    };

    final Set<String> processedFilePaths = {};

    try {
      for (final basePath in _possiblePaths) {
        final directory = Directory(basePath);
        if (!await directory.exists()) continue;

        try {
          final List<FileSystemEntity> typeFolders =
              await directory.list().toList();

          for (final typeFolder in typeFolders) {
            if (typeFolder is! Directory) continue;
            final folderName = p.basename(typeFolder.path).toLowerCase();

            try {
              // Recursively scan all files in this media subfolder
              final List<FileSystemEntity> entities =
                  await typeFolder.list(recursive: true).toList();

              for (final entity in entities) {
                if (entity is! File) continue;
                if (!processedFilePaths.add(entity.path)) continue; // Prevent duplicates

                final filePathLower = entity.path.toLowerCase();
                final ext = p.extension(entity.path).toLowerCase();

                // 1. Sent duplicate media (Sent folders)
                if (filePathLower.contains('/sent/') ||
                    filePathLower.contains('\\sent\\')) {
                  categoryFilesMap['WhatsApp Sent Media']!.add(entity);
                }
                // 2. Images
                else if (folderName.contains('image')) {
                  if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
                    categoryFilesMap['WhatsApp Images']!.add(entity);
                  }
                }
                // 3. Videos & Video Notes
                else if (folderName.contains('video')) {
                  if (['.mp4', '.mov', '.3gp', '.mkv', '.avi'].contains(ext)) {
                    categoryFilesMap['WhatsApp Videos']!.add(entity);
                  }
                }
                // 4. Voice Notes (PTT recordings in subfolders)
                else if (folderName.contains('voice') ||
                    folderName.contains('ptt') ||
                    ext == '.opus') {
                  categoryFilesMap['WhatsApp Voice Notes']!.add(entity);
                }
                // 5. Documents
                else if (folderName.contains('doc')) {
                  categoryFilesMap['WhatsApp Documents']!.add(entity);
                }
                // 6. Audio
                else if (folderName.contains('audio')) {
                  categoryFilesMap['WhatsApp Audio']!.add(entity);
                }
                // 7. Stickers and Animated GIFs
                else if (folderName.contains('sticker') ||
                    folderName.contains('gif')) {
                  categoryFilesMap['WhatsApp Stickers & GIFs']!.add(entity);
                }
                // Fallback by extension
                else {
                  if (['.jpg', '.jpeg', '.png'].contains(ext)) {
                    categoryFilesMap['WhatsApp Images']!.add(entity);
                  } else if (['.mp4', '.mov', '.3gp'].contains(ext)) {
                    categoryFilesMap['WhatsApp Videos']!.add(entity);
                  } else if (['.pdf', '.doc', '.docx', '.txt'].contains(ext)) {
                    categoryFilesMap['WhatsApp Documents']!.add(entity);
                  } else if (['.mp3', '.ogg', '.m4a', '.wav'].contains(ext)) {
                    categoryFilesMap['WhatsApp Audio']!.add(entity);
                  }
                }
              }
            } catch (e) {
              debugPrint('Error scanning subfolder ${typeFolder.path}: $e');
            }
          }
        } catch (e) {
          debugPrint('Error listing WhatsApp folder $basePath: $e');
        }
      }
    } catch (e) {
      debugPrint('General WhatsApp scan error: $e');
    }

    // Safely attempt device contacts retrieval without throwing
    List<Contact> deviceContacts = [];
    try {
      final hasContactPermission =
          await FlutterContacts.requestPermission(readonly: true);
      if (hasContactPermission) {
        deviceContacts = await FlutterContacts.getContacts(
          withProperties: false,
          withPhoto: true,
        );
      }
    } catch (e) {
      debugPrint('Safely handled contact retrieval: $e');
    }

    final List<WhatsAppContact> result = [];

    // Helper map of visual metadata per category
    final Map<String, (IconData, Color)> categoryMeta = {
      'WhatsApp Images': (Icons.photo_library_rounded, const Color(0xFF2196F3)),
      'WhatsApp Videos': (Icons.play_circle_fill_rounded, const Color(0xFFE91E63)),
      'WhatsApp Voice Notes': (Icons.mic_rounded, const Color(0xFF9C27B0)),
      'WhatsApp Documents': (Icons.description_rounded, const Color(0xFFFF9800)),
      'WhatsApp Audio': (Icons.audiotrack_rounded, const Color(0xFF00BCD4)),
      'WhatsApp Sent Media': (Icons.send_rounded, const Color(0xFF607D8B)),
      'WhatsApp Stickers & GIFs': (Icons.emoji_emotions_rounded, const Color(0xFFFFC107)),
    };

    for (final entry in categoryFilesMap.entries) {
      final title = entry.key;
      final files = entry.value;
      if (files.isEmpty) continue;

      int totalBytes = 0;
      final Map<String, List<File>> filesByType = {
        'Photos': [],
        'Videos': [],
        'Documents': [],
        'Audio': [],
        'Other': [],
      };

      for (final file in files) {
        try {
          totalBytes += file.lengthSync();
        } catch (_) {
          continue;
        }

        final ext = p.extension(file.path).toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
          filesByType['Photos']!.add(file);
        } else if (['.mp4', '.mov', '.3gp', '.mkv', '.avi'].contains(ext)) {
          filesByType['Photos']!.add(file); // Photos tab handles photo and video swipes
          filesByType['Videos']!.add(file);
        } else if (['.pdf', '.doc', '.docx', '.txt', '.xlsx', '.xls', '.ppt', '.pptx'].contains(ext)) {
          filesByType['Documents']!.add(file);
        } else if (['.mp3', '.ogg', '.opus', '.wav', '.m4a', '.aac'].contains(ext)) {
          filesByType['Audio']!.add(file);
        } else {
          filesByType['Other']!.add(file);
        }
      }

      final meta = categoryMeta[title] ??
          (Icons.folder_special_rounded, const Color(0xFF25D366));

      Contact? matchedContact;
      try {
        if (deviceContacts.isNotEmpty) {
          matchedContact = deviceContacts.firstWhere(
            (c) => c.displayName.toLowerCase().contains(title.toLowerCase()),
          );
        }
      } catch (_) {}

      result.add(
        WhatsAppContact(
          name: title,
          totalFiles: files.length,
          totalBytes: totalBytes,
          filesByType: filesByType,
          deviceContact: matchedContact,
          icon: meta.$1,
          accentColor: meta.$2,
        ),
      );
    }

    // Sort by largest byte size first
    result.sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
    return result;
  }
}
