/// Centralized application string constants.
class AppStrings {
  AppStrings._();

  /// Setting keys for dynamic Map<String, bool> settings storage.
  static const settings = _SettingsKeys();

  /// WhatsApp cleaner preference keys.
  static const whatsapp = _WhatsAppCleanerKeys();
}

class _SettingsKeys {
  const _SettingsKeys();

  // Cleaning engine keys
  final String autoPlayVideos = 'auto_play_videos';
  final String showFileSizes = 'show_file_sizes';
  final String fitContent = 'fit_content';
  final String hapticFeedback = 'haptic_feedback';
  final String confirmDeletions = 'confirm_deletions';
  final String defaultSwipeIsDelete = 'default_swipe_is_delete';

  // Notification keys
  final String notifWeeklyDigest = 'notif_weekly_digest';
  final String notifGroupNudge = 'notif_group_nudge';
  final String notifPostClean = 'notif_post_clean';

  // Kept-file & selection limit keys
  final String showKeptFiles = 'show_kept_files';
  final String maxSelectionOverride = 'max_selection_override'; // stored as int in AppSettings
}

class _WhatsAppCleanerKeys {
  const _WhatsAppCleanerKeys();

  /// Whether the cleaner sorts by date (true) or by size (false).
  final String sortByDate = 'wa_cleaner_sort_by_date';
}
