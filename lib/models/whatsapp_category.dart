import 'package:flutter/material.dart';

/// Strongly-typed classification for all WhatsApp media categories.
enum WhatsAppCategory {
  images,
  videos,
  voiceNotes,
  audio,
  documents,
  sentMedia,
  stickers,
}

extension WhatsAppCategoryX on WhatsAppCategory {
  String get label {
    switch (this) {
      case WhatsAppCategory.images:
        return 'Images';
      case WhatsAppCategory.videos:
        return 'Videos';
      case WhatsAppCategory.voiceNotes:
        return 'Voice Notes';
      case WhatsAppCategory.audio:
        return 'Audio';
      case WhatsAppCategory.documents:
        return 'Documents';
      case WhatsAppCategory.sentMedia:
        return 'Sent Media';
      case WhatsAppCategory.stickers:
        return 'Stickers & GIFs';
    }
  }

  IconData get icon {
    switch (this) {
      case WhatsAppCategory.images:
        return Icons.photo_library_rounded;
      case WhatsAppCategory.videos:
        return Icons.play_circle_fill_rounded;
      case WhatsAppCategory.voiceNotes:
        return Icons.mic_rounded;
      case WhatsAppCategory.audio:
        return Icons.audiotrack_rounded;
      case WhatsAppCategory.documents:
        return Icons.description_rounded;
      case WhatsAppCategory.sentMedia:
        return Icons.send_rounded;
      case WhatsAppCategory.stickers:
        return Icons.emoji_emotions_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case WhatsAppCategory.images:
        return const Color(0xFF2196F3);
      case WhatsAppCategory.videos:
        return const Color(0xFFE91E63);
      case WhatsAppCategory.voiceNotes:
        return const Color(0xFF9C27B0);
      case WhatsAppCategory.audio:
        return const Color(0xFF00BCD4);
      case WhatsAppCategory.documents:
        return const Color(0xFFFF9800);
      case WhatsAppCategory.sentMedia:
        return const Color(0xFF607D8B);
      case WhatsAppCategory.stickers:
        return const Color(0xFFFFC107);
    }
  }

  /// Folder name fragments (lowercase) used to classify a subdirectory.
  List<String> get directoryKeywords {
    switch (this) {
      case WhatsAppCategory.images:
        return ['image', 'photo'];
      case WhatsAppCategory.videos:
        return ['video'];
      case WhatsAppCategory.voiceNotes:
        return ['voice', 'ptt'];
      case WhatsAppCategory.audio:
        return ['audio', 'music'];
      case WhatsAppCategory.documents:
        return ['document', 'doc'];
      case WhatsAppCategory.sentMedia:
        return ['sent'];
      case WhatsAppCategory.stickers:
        return ['sticker', 'gif', 'animated'];
    }
  }

  /// File extensions belonging to this category.
  List<String> get extensions {
    switch (this) {
      case WhatsAppCategory.images:
        return ['.jpg', '.jpeg', '.png', '.webp', '.heic'];
      case WhatsAppCategory.videos:
        return ['.mp4', '.mov', '.3gp', '.mkv', '.avi'];
      case WhatsAppCategory.voiceNotes:
        return ['.opus', '.ogg', '.m4a'];
      case WhatsAppCategory.audio:
        return ['.mp3', '.ogg', '.opus', '.wav', '.m4a', '.aac', '.flac'];
      case WhatsAppCategory.documents:
        return [
          '.pdf',
          '.doc',
          '.docx',
          '.txt',
          '.xlsx',
          '.xls',
          '.ppt',
          '.pptx',
          '.zip',
        ];
      case WhatsAppCategory.sentMedia:
        return [
          '.jpg',
          '.jpeg',
          '.png',
          '.webp',
          '.mp4',
          '.mov',
          '.3gp',
          '.opus',
        ];
      case WhatsAppCategory.stickers:
        return ['.webp', '.gif'];
    }
  }
}
