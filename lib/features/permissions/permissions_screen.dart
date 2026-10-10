import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/app_background.dart';
import '../../core/constants/app_colors.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isLoading = false;
  bool _storageGranted = false;
  bool _whatsappGranted = false;
  bool _contactsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final statusStorage = await Permission.storage.status;
    final statusContacts = await Permission.contacts.status;
    final statusPhotos = await Permission.photos.status;
    final statusVideos = await Permission.videos.status;
    final statusManage = await Permission.manageExternalStorage.status;

    final bool storageOk = statusStorage.isGranted || statusManage.isGranted || 
                         (statusPhotos.isGranted && statusVideos.isGranted);
    final bool contactsOk = statusContacts.isGranted;

    if (mounted) {
      setState(() {
        _storageGranted = storageOk;
        _whatsappGranted = storageOk;
        _contactsGranted = contactsOk;
      });

      // Auto navigate if all mandatory permissions are granted
      if (storageOk && contactsOk) {
        _finalizeOnboarding();
      }
    }
  }

  Future<void> _finalizeOnboarding() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    // Add a small artificial delay to ensure users see the transition/loading
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) context.go('/home');
  }

  Future<void> _requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
      Permission.notification,
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();

    await Permission.storage.request();

    final bool allMediaGranted = statuses[Permission.photos]!.isGranted &&
                                statuses[Permission.videos]!.isGranted &&
                                statuses[Permission.audio]!.isGranted;

    if (allMediaGranted && statuses[Permission.contacts]!.isGranted) {
      _finalizeOnboarding();
    } else {
      if (mounted) {
        _showManageStorageDialog();
      }
    }
  }

  void _showManageStorageDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isLoading,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('All Access Required', style: TextStyle(color: AppColors.darkPrimaryGold, fontFamily: 'Playfair Display')),
        content: const Text(
          'To scan and clean all your folders effectively, Reminisce works best with "All Files Access".\n\nPlease enable it in the next screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (await Permission.manageExternalStorage.request().isGranted) {
                _finalizeOnboarding();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimaryGold),
            child: const Text('Grant All Access', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      gradientStyle: 1,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before we begin',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    color: AppColors.darkPrimaryGold,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reminisce needs these permissions to work its magic.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkTextMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),
                _PermissionCard(
                  onTap: _checkPermissions,
                  icon: Icons.folder,
                  title: "Storage Access",
                  description: "To scan and clean your device files and folders",
                  isGranted: _storageGranted,
                ),
                const SizedBox(height: 16),
                _PermissionCard(
                  onTap: _checkPermissions,
                  icon: Icons.message,
                  title: "WhatsApp Media",
                  description: "To read and group your WhatsApp media by contact",
                  isGranted: _whatsappGranted,
                ),
                const SizedBox(height: 16),
                _PermissionCard(
                  onTap: _checkPermissions,
                  icon: Icons.person,
                  title: "Contacts",
                  description: "To show profile pictures for your chats",
                  isGranted: _contactsGranted,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPrimaryGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text(
                        'Grant Permissions & Continue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => context.go('/home'),
                    child: Text(
                      "I'll do this later",
                      style: TextStyle(color: AppColors.darkTextMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.darkPrimaryGold),
                    SizedBox(height: 24),
                    Text(
                      'Initializing your session...',
                      style: TextStyle(color: AppColors.darkPrimaryGold, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.darkPrimaryGold.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkPrimaryGold, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.darkTextMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isGranted
                    ? AppColors.darkKeepGreen.withOpacity(0.2)
                    : Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isGranted ? 'Granted' : 'Required',
                style: TextStyle(
                  color: isGranted ? AppColors.darkKeepGreen : Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
