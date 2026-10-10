import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/cleaning_session.dart';

part 'analytics_provider.g.dart';

class AnalyticsState {
  final List<CleaningSession> sessions;
  final int streakDays;

  AnalyticsState({this.sessions = const [], this.streakDays = 0});
}

@riverpod
class Analytics extends _$Analytics {
  @override
  AnalyticsState build() => AnalyticsState();

  void addSession(CleaningSession session) {
    final newList = List<CleaningSession>.from(state.sessions)..add(session);
    state = AnalyticsState(sessions: newList, streakDays: _calculateStreak(newList));
  }

  int _calculateStreak(List<CleaningSession> sessions) {
    // Simplified streak calculation logic
    if (sessions.isEmpty) return 0;
    return 1; // Placeholder
  }
}
