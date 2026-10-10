import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color borderColor;
  final String? badge;
  final VoidCallback onTap;

  const SourceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkPrimaryGold, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimaryGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.darkTextMuted),
          ],
        ),
      ),
    );
  }
}
