import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/modern_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/session_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  PermissionStatus _storageStatus = PermissionStatus.denied;
  PermissionStatus _contactsStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final storage = await Permission.storage.status;
    final contacts = await Permission.contacts.status;
    if (mounted) {
      setState(() {
        _storageStatus = storage;
        _contactsStatus = contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;
    final Color textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color textMuted = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
    const Color deleteRed = AppColors.darkDeleteRed;

    return AppBackground(
      gradientStyle: 2,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            floating: true,
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. APPEARANCE
                const M3SectionHeader(
                  overline: 'Theme & Style',
                  title: 'Appearance',
                ),
                const SizedBox(height: 10),
                ModernCard(
                  padding: const EdgeInsets.all(16.0),
                  borderRadius: 16.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildSquircleIcon(
                            icon: Icons.palette_outlined,
                            color: primaryColor,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Theme Mode',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose how Reminisce looks on your device',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Custom Segmented Pill Tab Bar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildThemeSegment(
                              label: 'Light',
                              icon: Icons.wb_sunny_rounded,
                              mode: ThemeMode.light,
                              current: themeMode,
                              primaryColor: primaryColor,
                              isDark: isDark,
                              onTap: () => ref
                                  .read(themeModeNotifierProvider.notifier)
                                  .setThemeMode(ThemeMode.light),
                            ),
                            _buildThemeSegment(
                              label: 'Dark',
                              icon: Icons.nightlight_round,
                              mode: ThemeMode.dark,
                              current: themeMode,
                              primaryColor: primaryColor,
                              isDark: isDark,
                              onTap: () => ref
                                  .read(themeModeNotifierProvider.notifier)
                                  .setThemeMode(ThemeMode.dark),
                            ),
                            _buildThemeSegment(
                              label: 'System',
                              icon: Icons.brightness_auto_rounded,
                              mode: ThemeMode.system,
                              current: themeMode,
                              primaryColor: primaryColor,
                              isDark: isDark,
                              onTap: () => ref
                                  .read(themeModeNotifierProvider.notifier)
                                  .setThemeMode(ThemeMode.system),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.05, end: 0, duration: 350.ms),

                const SizedBox(height: 24),

                // 2. CLEANING ENGINE
                const M3SectionHeader(
                  overline: 'Engine Rules',
                  title: 'Cleaning Workflow',
                ),
                const SizedBox(height: 10),
                ModernCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 16.0,
                  child: Column(
                    children: [
                      // Deletion Limit Slider Card
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildSquircleIcon(
                                  icon: Icons.tune_rounded,
                                  color: primaryColor,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Deletion Limit',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Maximum files reviewed per session',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(
                                        alpha: isDark ? 0.18 : 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: primaryColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '${settings.deletionLimit} files',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: primaryColor,
                                inactiveTrackColor: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.black.withValues(alpha: 0.1),
                                thumbColor: primaryColor,
                                overlayColor: primaryColor.withValues(alpha: 0.15),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: settings.deletionLimit.toDouble(),
                                min: 10,
                                max: 200,
                                divisions: 19,
                                onChanged: (val) =>
                                    settingsNotifier.setDeletionLimit(val.toInt()),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('10 files',
                                    style: TextStyle(
                                        fontSize: 11, color: textMuted)),
                                Text('200 files',
                                    style: TextStyle(
                                        fontSize: 11, color: textMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _buildDivider(isDark),

                      // Auto-play Videos
                      _buildToggleRow(
                        icon: Icons.play_circle_outline_rounded,
                        title: 'Auto-play Videos',
                        subtitle: 'Automatically preview videos during swipe',
                        value: settings.get(AppStrings.settings.autoPlayVideos, defaultValue: true),
                        onChanged: (val) =>
                            settingsNotifier.toggle(AppStrings.settings.autoPlayVideos, val),
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),

                      _buildDivider(isDark),

                      // Show File Sizes
                      _buildToggleRow(
                        icon: Icons.data_usage_rounded,
                        title: 'Show File Sizes',
                        subtitle: 'Display exact byte size badges on media cards',
                        value: settings.get(AppStrings.settings.showFileSizes, defaultValue: true),
                        onChanged: (val) =>
                            settingsNotifier.toggle(AppStrings.settings.showFileSizes, val),
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),

                      _buildDivider(isDark),

                      // Fit Content
                      _buildToggleRow(
                        icon: Icons.crop_free_rounded,
                        title: 'Fit Images to Card',
                        subtitle: 'Show complete uncropped images in viewer',
                        value: settings.get(AppStrings.settings.fitContent, defaultValue: false),
                        onChanged: (val) =>
                            settingsNotifier.toggle(AppStrings.settings.fitContent, val),
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),

                      _buildDivider(isDark),

                      // Haptic Feedback
                      _buildToggleRow(
                        icon: Icons.vibration_rounded,
                        title: 'Haptic Feedback',
                        subtitle: 'Tactile vibrations when swiping or acting',
                        value: settings.get(AppStrings.settings.hapticFeedback, defaultValue: true),
                        onChanged: (val) =>
                            settingsNotifier.toggle(AppStrings.settings.hapticFeedback, val),
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),

                      _buildDivider(isDark),

                      // Confirm Deletions
                      _buildToggleRow(
                        icon: Icons.security_rounded,
                        title: 'Deletion Safeguard',
                        subtitle: 'Show confirmation dialog before purging files',
                        value: settings.get(AppStrings.settings.confirmDeletions, defaultValue: true),
                        onChanged: (val) =>
                            settingsNotifier.toggle(AppStrings.settings.confirmDeletions, val),
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 80.ms, duration: 350.ms)
                    .slideY(begin: 0.05, end: 0, duration: 350.ms),

                const SizedBox(height: 24),

                // 3. NOTIFICATIONS
                const M3SectionHeader(
                  overline: 'Reminders & Alerts',
                  title: 'Notifications',
                ),
                const SizedBox(height: 10),
                ModernCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 16.0,
                  child: Column(
                    children: [
                      _buildToggleRow(
                        icon: Icons.calendar_month_outlined,
                        title: 'Weekly Storage Digest',
                        subtitle: 'Weekly summary of storage freed and clutter',
                        value: settings.get(AppStrings.settings.notifWeeklyDigest, defaultValue: true),
                        onChanged: (val) =>
                            settingsNotifier.toggle(AppStrings.settings.notifWeeklyDigest, val),
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildToggleRow(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Group Chat Nudges',
                        subtitle: 'Smart alerts when chats grow excessively large',
                        value: settings.get(AppStrings.settings.notifGroupNudge, defaultValue: true),
                        onChanged: (val) =>
                            settingsNotifier.toggle(AppStrings.settings.notifGroupNudge, val),
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildToggleRow(
                        icon: Icons.task_alt_rounded,
                        title: 'Post-Clean Celebration',
                        subtitle: 'Notification celebrating completed sweeps',
                        value: settings.get(AppStrings.settings.notifPostClean, defaultValue: true),
                        onChanged: (val) =>
                            settingsNotifier.toggle(AppStrings.settings.notifPostClean, val),
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 140.ms, duration: 350.ms)
                    .slideY(begin: 0.05, end: 0, duration: 350.ms),

                const SizedBox(height: 24),

                // 4. PERMISSIONS
                const M3SectionHeader(
                  overline: 'Device Access',
                  title: 'Permissions',
                ),
                const SizedBox(height: 10),
                ModernCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 16.0,
                  child: Column(
                    children: [
                      _buildPermissionItem(
                        icon: Icons.folder_shared_outlined,
                        title: 'Storage Access',
                        subtitle: 'Required to scan directories and remove files',
                        status: _storageStatus,
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildPermissionItem(
                        icon: Icons.contacts_outlined,
                        title: 'Contacts Access',
                        subtitle: 'Associates WhatsApp media folders with names',
                        status: _contactsStatus,
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 350.ms)
                    .slideY(begin: 0.05, end: 0, duration: 350.ms),

                const SizedBox(height: 24),

                // 5. DANGER ZONE
                M3SectionHeader(
                  overline: 'Data Management',
                  title: 'Danger Zone',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: deleteRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'CAUTION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: deleteRed,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ModernCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 16.0,
                  borderColor: deleteRed.withValues(alpha: isDark ? 0.35 : 0.25),
                  hasGlow: true,
                  glowColor: deleteRed,
                  child: Column(
                    children: [
                      _buildDangerActionRow(
                        icon: Icons.delete_sweep_rounded,
                        title: 'Empty Deletion Queue',
                        subtitle: 'Clear all marked items from current session',
                        onTap: () => _showConfirmationModal(
                          context,
                          title: 'Clear Deletion Queue?',
                          message:
                              'This will unmark all files currently scheduled for removal in this session.',
                          confirmText: 'Empty Queue',
                          confirmColor: deleteRed,
                          onConfirm: () {
                            ref.read(sessionProvider.notifier).clearSession();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Deletion queue cleared'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        deleteRed: deleteRed,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildDangerActionRow(
                        icon: Icons.history_toggle_off_rounded,
                        title: 'Clear Analytics Data',
                        subtitle: 'Reset storage statistics, graphs, and streaks',
                        onTap: () => _showConfirmationModal(
                          context,
                          title: 'Clear Analytics Data?',
                          message:
                              'This will reset your recorded cleanup history and streak count back to zero.',
                          confirmText: 'Reset Data',
                          confirmColor: deleteRed,
                          onConfirm: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Analytics history reset'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        deleteRed: deleteRed,
                        textMuted: textMuted,
                        isDark: isDark,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 240.ms, duration: 350.ms)
                    .slideY(begin: 0.05, end: 0, duration: 350.ms),

                const SizedBox(height: 36),

                // App Branding & Version Footer
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(
                              alpha: isDark ? 0.12 : 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/reminisce_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reminisce',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Version 1.0.0 (Build 1)',
                        style: TextStyle(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 110), // Padding for bottom nav bar
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSegment({
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode current,
    required Color primaryColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = current == mode;
    return Expanded(
      child: BouncingPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? primaryColor : primaryColor)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDark ? AppColors.darkScaffoldBg : Colors.white)
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.darkScaffoldBg : Colors.white)
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color primaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildSquircleIcon(icon: icon, color: primaryColor, isDark: isDark),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: primaryColor.withValues(alpha: 0.5),
            activeThumbColor: primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required PermissionStatus status,
    required Color primaryColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    final isGranted = status.isGranted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _buildSquircleIcon(
            icon: icon,
            color: isGranted ? const Color(0xFF4CAF50) : primaryColor,
            isDark: isDark,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isGranted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: Color(0xFF4CAF50),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Granted',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            )
          else
            BouncingPressable(
              onTap: () => openAppSettings(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'Grant Access',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDangerActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color deleteRed,
    required Color textMuted,
    required bool isDark,
  }) {
    return BouncingPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            _buildSquircleIcon(icon: icon, color: deleteRed, isDark: isDark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: deleteRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: deleteRed.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquircleIcon({
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 64,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06),
    );
  }

  void _showConfirmationModal(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
