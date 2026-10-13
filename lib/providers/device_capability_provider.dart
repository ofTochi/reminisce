import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads device total RAM from /proc/meminfo (available on all Android devices)
/// and maps it to a recommended max-selection soft limit.
///
/// Tier table:
///  < 3 GB  → 20 files
///  3–5 GB  → 35 files
///  5–8 GB  → 50 files
///  > 8 GB  → 75 files
class DeviceCapability {
  final int totalRamBytes;
  final int softSelectionLimit;

  const DeviceCapability({
    required this.totalRamBytes,
    required this.softSelectionLimit,
  });

  double get totalRamGb => totalRamBytes / (1024 * 1024 * 1024);
  String get ramLabel => '${totalRamGb.toStringAsFixed(1)} GB';

  static int _limitForRam(int bytes) {
    final gb = bytes / (1024 * 1024 * 1024);
    if (gb < 3) return 20;
    if (gb < 5) return 35;
    if (gb < 8) return 50;
    return 75;
  }

  static DeviceCapability unknown() => const DeviceCapability(
        totalRamBytes: 0,
        softSelectionLimit: 30, // conservative fallback
      );
}

/// Reads MemTotal from /proc/meminfo, which is available on all Android devices.
/// Returns [DeviceCapability.unknown] if the file can't be parsed.
final deviceCapabilityProvider = FutureProvider<DeviceCapability>((ref) async {
  try {
    final memInfoFile = File('/proc/meminfo');
    if (!await memInfoFile.exists()) return DeviceCapability.unknown();

    final content = await memInfoFile.readAsString();
    final match = RegExp(r'MemTotal:\s+(\d+)\s+kB').firstMatch(content);
    if (match == null) return DeviceCapability.unknown();

    final kbTotal = int.parse(match.group(1)!);
    final bytesTotal = kbTotal * 1024;

    return DeviceCapability(
      totalRamBytes: bytesTotal,
      softSelectionLimit: DeviceCapability._limitForRam(bytesTotal),
    );
  } catch (_) {
    return DeviceCapability.unknown();
  }
});
