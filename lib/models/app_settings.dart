import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_strings.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings {
  @HiveField(0)
  final int deletionLimit;

  @HiveField(1)
  final Map<String, bool> booleanSettings;

  @HiveField(2)
  final int? maxSelectionOverride;

  AppSettings({
    this.deletionLimit = 50,
    Map<String, bool>? booleanSettings,
    this.maxSelectionOverride,
  }) : booleanSettings = booleanSettings ?? const {};

  /// Read any boolean setting by arbitrary string key with a fallback
  bool get(String key, {bool defaultValue = false}) {
    return booleanSettings[key] ?? defaultValue;
  }

  /// Convenience check whether any setting key is enabled
  bool isEnabled(String key, {bool defaultValue = false}) =>
      get(key, defaultValue: defaultValue);

  // Dynamic convenience accessor for existing swipe card check
  bool get fitContent => get(AppStrings.settings.fitContent, defaultValue: false);

  AppSettings copyWith({
    int? deletionLimit,
    Map<String, bool>? booleanSettings,
    Object? maxSelectionOverride = _sentinel,
  }) {
    return AppSettings(
      deletionLimit: deletionLimit ?? this.deletionLimit,
      booleanSettings: booleanSettings ?? this.booleanSettings,
      maxSelectionOverride: maxSelectionOverride == _sentinel
          ? this.maxSelectionOverride
          : maxSelectionOverride as int?,
    );
  }
}

const Object _sentinel = Object();
