import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  AppSettings build() {
    final box = Hive.box<AppSettings>('settings');
    return box.get('current') ?? AppSettings();
  }

  void _save(AppSettings newSettings) {
    state = newSettings;
    Hive.box<AppSettings>('settings').put('current', newSettings);
  }

  void updateSettings(AppSettings newSettings) {
    _save(newSettings);
  }

  void setDeletionLimit(int limit) {
    _save(state.copyWith(deletionLimit: limit));
  }

  /// Toggles any boolean setting dynamically by [key].
  /// Completely agnostic to which keys exist.
  void toggle(String key, [bool? value]) {
    final current = state.get(key);
    final next = value ?? !current;
    final updated = Map<String, bool>.from(state.booleanSettings);
    updated[key] = next;
    _save(state.copyWith(booleanSettings: updated));
  }

  /// Reads any boolean setting dynamically by [key].
  bool readSetting(String key, {bool defaultValue = false}) {
    return state.get(key, defaultValue: defaultValue);
  }
}

/// Dynamic provider exposing the raw Map<String, bool> of all toggleable settings
final booleanSettingsProvider = Provider<Map<String, bool>>((ref) {
  return ref.watch(settingsProvider).booleanSettings;
});
