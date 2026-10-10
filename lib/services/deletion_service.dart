import 'dart:io';
import 'package:flutter/foundation.dart';

class DeletionService {
  Stream<double> executeDeletionStream(List<FileSystemEntity> files) async* {
    if (files.isEmpty) {
      yield 1.0;
      return;
    }

    int deleted = 0;
    final int total = files.length;
    
    // Process in small batches for concurrency + UI responsiveness
    const int batchSize = 5;
    for (int i = 0; i < files.length; i += batchSize) {
      final end = (i + batchSize < files.length) ? i + batchSize : files.length;
      final batch = files.sublist(i, end);
      
      await Future.wait(batch.map((file) async {
        try {
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error deleting file ${file.path}: $e');
        }
      }));
      
      deleted += batch.length;
      yield deleted / total;
    }
  }

  // Legacy support
  Future<void> executeDeletion(List<FileSystemEntity> files) async {
    await executeDeletionStream(files).last;
  }
}
