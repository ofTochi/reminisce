import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
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

  void toggleFitContent(bool value) {
    _save(state.copyWith(fitContent: value));
  }

  void setDeletionLimit(int limit) {
    _save(state.copyWith(deletionLimit: limit));
  }
  
  void toggleAutoPlay(bool value) {
    _save(state.copyWith(autoPlayVideos: value));
  }
  
  void toggleShowSizes(bool value) {
    _save(state.copyWith(showFileSizes: value));
  }
}
