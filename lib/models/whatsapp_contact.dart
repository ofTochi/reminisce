import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class WhatsAppContact {
  final String name;
  final int totalFiles;
  final int totalBytes;
  final Map<String, List<File>> filesByType;
  final Contact? deviceContact;
  final IconData? icon;
  final Color? accentColor;

  WhatsAppContact({
    required this.name,
    required this.totalFiles,
    required this.totalBytes,
    required this.filesByType,
    this.deviceContact,
    this.icon,
    this.accentColor,
  });

  /// Safe initial letter for avatar display
  String get initial {
    if (name.trim().isEmpty) return '?';
    return name.trim().substring(0, 1).toUpperCase();
  }
}
