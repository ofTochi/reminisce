import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/widgets/app_background.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/analytics_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return AppBackground(
      gradientStyle: 3,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontFamily: 'Playfair Display'),
          ),
          const SizedBox(height: 32),
          _buildHeader('APPEARANCE'),
          ListTile(
            title: const Text('Theme Mode'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.wb_sunny_outlined)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.nightlight_outlined)),
                ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
              ],
              selected: {themeMode},
              onSelectionChanged: (newSelection) {
                ref.read(themeModeNotifierProvider.notifier).setThemeMode(newSelection.first);
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildHeader('CLEANING'),
          ListTile(
            title: const Text('Deletion Limit'),
            subtitle: Text('${settings.deletionLimit} files max per session'),
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: settings.deletionLimit.toDouble(),
                min: 10,
                max: 200,
                divisions: 19,
                onChanged: (val) => settingsNotifier.setDeletionLimit(val.toInt()),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Auto-play Videos'),
            value: settings.autoPlayVideos,
            onChanged: (val) => settingsNotifier.updateSettings(settings.copyWith(autoPlayVideos: val)),
          ),
          SwitchListTile(
            title: const Text('Show file sizes'),
            value: settings.showFileSizes,
            onChanged: (val) => settingsNotifier.updateSettings(settings.copyWith(showFileSizes: val)),
          ),
          SwitchListTile(
            title: const Text('Fit images into card'),
            subtitle: const Text('Show the whole image instead of cropping'),
            value: settings.fitContent,
            onChanged: (val) => settingsNotifier.toggleFitContent(val),
          ),
          const SizedBox(height: 24),
          _buildHeader('PERMISSIONS'),
          _buildPermissionRow('Storage', Permission.storage),
          _buildPermissionRow('Contacts', Permission.contacts),
          const SizedBox(height: 24),
          _buildHeader('DANGER ZONE', color: AppColors.darkDeleteRed),
          ListTile(
            title: const Text('Empty deletion queue', style: TextStyle(color: AppColors.darkDeleteRed)),
            onTap: () => _confirmAction(context, 'Clear Deletion Queue', () {
              ref.read(sessionProvider.notifier).clearSession();
            }),
          ),
          ListTile(
            title: const Text('Clear all analytics data', style: TextStyle(color: AppColors.darkDeleteRed)),
            onTap: () => _confirmAction(context, 'Clear Analytics', () {
              // Reset analytics provider state
            }),
          ),
          const SizedBox(height: 48),
          const Center(
            child: Text(
              'Reminisce v1.0.0',
              style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color ?? AppColors.darkPrimaryGold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String title, Permission permission) {
    return FutureBuilder<PermissionStatus>(
      future: permission.status,
      builder: (context, snapshot) {
        final isGranted = snapshot.data?.isGranted ?? false;
        return ListTile(
          title: Text(title),
          trailing: isGranted
              ? const Icon(Icons.check_circle, color: AppColors.darkKeepGreen)
              : TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Re-grant'),
                ),
        );
      },
    );
  }

  void _confirmAction(BuildContext context, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: const Text('Confirm', style: TextStyle(color: AppColors.darkDeleteRed)),
          ),
        ],
      ),
    );
  }
}
