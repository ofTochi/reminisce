import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path/path.dart' as p;
import '../models/whatsapp_contact.dart';

class WhatsAppScanService {
  static const List<String> _possiblePaths = [
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media',
    '/storage/emulated/0/WhatsApp/Media',
    '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media',
  ];

  Future<List<WhatsAppContact>> scanContacts() async {
    final List<WhatsAppContact> contacts = [];
    final Map<String, List<File>> contactFilesMap = {};

    try {
      for (final basePath in _possiblePaths) {
        final directory = Directory(basePath);
        if (!await directory.exists()) continue;

        try {
          final List<FileSystemEntity> typeFolders = await directory.list().toList();
          for (final typeFolder in typeFolders) {
            if (typeFolder is! Directory) continue;

            try {
              final List<FileSystemEntity> children = await typeFolder.list().toList();
              for (final child in children) {
                if (child is Directory) {
                  final contactName = p.basename(child.path);
                  final List<File> files = (await child
                      .list(recursive: true)
                      .toList())
                      .whereType<File>()
                      .toList();
                  contactFilesMap.update(
                    contactName,
                    (value) => value..addAll(files),
                    ifAbsent: () => files,
                  );
                } else if (child is File) {
                  contactFilesMap.update(
                    'Unsorted Media',
                    (value) => value..add(child),
                    ifAbsent: () => [child],
                  );
                }
              }
            } catch (e) {
              debugPrint('Error listing contact folder: $e');
            }
          }
        } catch (e) {
          debugPrint('Error listing WhatsApp media folder: $e');
        }
      }
    } catch (e) {
      debugPrint('General WhatsApp scan error: $e');
    }

    if (contactFilesMap.isEmpty) return [];

    final deviceContacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    for (final entry in contactFilesMap.entries) {
      final name = entry.key;
      final files = entry.value;

      Contact? deviceContact;
      try {
        deviceContact = deviceContacts.firstWhere(
          (c) => c.displayName.toLowerCase() == name.toLowerCase(),
        );
      } catch (_) {
        // Not found in device contacts
      }

      int totalBytes = 0;
      final Map<String, List<File>> filesByType = {};

      for (final file in files) {
        try {
          totalBytes += await file.length();
        } catch (_) {
          // Skip if missing
          continue;
        }
        final ext = p.extension(file.path).toLowerCase();
        String type = 'Other';
        if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
          type = 'Photos';
        } else if (['.mp4', '.mov', '.avi'].contains(ext)) {
          type = 'Videos';
        } else if (['.pdf', '.doc', '.docx', '.txt'].contains(ext)) {
          type = 'Documents';
        } else if (['.mp3', '.ogg', '.wav', '.m4a'].contains(ext)) {
          type = 'Audio';
        }

        filesByType.update(
          type,
          (value) => value..add(file),
          ifAbsent: () => [file],
        );
      }

      contacts.add(
        WhatsAppContact(
          name: name,
          totalFiles: files.length,
          totalBytes: totalBytes,
          filesByType: filesByType.map((key, value) => MapEntry(key, value)),
          deviceContact: deviceContact,
        ),
      );
    }

    contacts.sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
    return contacts;
  }
}
