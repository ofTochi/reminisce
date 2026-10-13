import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:workmanager/workmanager.dart';
import 'app.dart';
import 'models/cleaning_session.dart';
import 'models/saved_session_state.dart';
import 'models/app_settings.dart';
import 'services/kept_files_service.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     // Background tasks logic
//     return Future.value(true);
//   });
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CleaningSessionAdapter());
  Hive.registerAdapter(SavedSessionStateAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  await Hive.openBox<CleaningSession>('sessions');
  await Hive.openBox<SavedSessionState>('saved_sessions');
  await Hive.openBox<AppSettings>('settings');
  await KeptFilesService.init(); // opens kept_files + cleaned_folders boxes

  // Prevent runtime font fetching — avoids exceptions when device is offline.
  // Fonts bundled locally in pubspec assets will be used instead.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Workmanager().initialize(callbackDispatcher);

  runApp(const ProviderScope(child: ReminisceApp()));
}
