import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onViewMarked;
  final int markedCount;
  final bool canUndo;

  const ActionButtons({
    super.key,
    required this.onUndo,
    required this.onViewMarked,
    required this.markedCount,
    required this.canUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.undo,
              label: 'Undo Last',
              onTap: canUndo ? onUndo : null,
              isEnabled: canUndo,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionButton(
              icon: Icons.delete_outline,
              label: 'View Marked',
              onTap: markedCount > 0 ? onViewMarked : null,
              isEnabled: markedCount > 0,
              badgeCount: markedCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final int? badgeCount;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.isEnabled,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isEnabled ? AppColors.darkPrimaryGold : Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? AppColors.darkPrimaryGold : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: 8,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.darkDeleteRed, shape: BoxShape.circle),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
