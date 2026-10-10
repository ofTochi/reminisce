import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart';

class WhatsAppContact {
  final String name;
  final int totalFiles;
  final int totalBytes;
  final Map<String, List<File>> filesByType;
  final Contact? deviceContact;

  WhatsAppContact({
    required this.name,
    required this.totalFiles,
    required this.totalBytes,
    required this.filesByType,
    this.deviceContact,
  });
}
