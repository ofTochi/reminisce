import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/whatsapp_contact.dart';

class ContactListTile extends StatelessWidget {
  final WhatsAppContact contact;
  final VoidCallback onTap;

  const ContactListTile({super.key, required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isLarge = contact.totalBytes > 100 * 1024 * 1024; // > 100MB

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.darkPrimaryGold,
          backgroundImage: contact.deviceContact?.photo != null
              ? MemoryImage(contact.deviceContact!.photo!)
              : null,
          child: contact.deviceContact?.photo == null
              ? Text(
                  contact.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${contact.totalFiles} files · ${(contact.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
          style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isLarge)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.darkDeleteRed, shape: BoxShape.circle),
              ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: AppColors.darkPrimaryGold),
          ],
        ),
      ),
    );
  }
}
