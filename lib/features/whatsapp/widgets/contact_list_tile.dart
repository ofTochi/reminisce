import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../models/whatsapp_contact.dart';

class ContactListTile extends StatelessWidget {
  final WhatsAppContact contact;
  final VoidCallback onTap;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLarge = contact.totalBytes > 100 * 1024 * 1024; // > 100MB

    final Color primaryColor = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;
    final Color textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color textMuted = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
    final Color accentColor = contact.accentColor ?? primaryColor;

    final String sizeFormatted = contact.totalBytes >= 1024 * 1024 * 1024
        ? '${(contact.totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB'
        : '${(contact.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: BouncingPressable(
        onTap: onTap,
        child: ModernCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 16.0,
          child: Row(
            children: [
              // Category Icon or Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: contact.deviceContact?.photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.memory(
                          contact.deviceContact!.photo!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        contact.icon ?? Icons.folder_rounded,
                        color: accentColor,
                        size: 24,
                      ),
              ),

              const SizedBox(width: 14),

              // Title & Subtitle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '${contact.totalFiles} files · $sizeFormatted',
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                        if (isLarge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.darkDeleteRed
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'HEAVY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkDeleteRed,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Chevron action
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
