import 'package:flutter/material.dart';

/// A re-usable styled dialog with a title, description, and a list of actions.
///
/// Usage — simple yes/no:
/// ```dart
/// AppDialog.show(
///   context,
///   title: 'Delete files?',
///   description: 'This cannot be undone.',
///   onYes: () { ... },
/// );
/// ```
///
/// Usage — multiple actions (e.g. session gate):
/// ```dart
/// AppDialog.show(
///   context,
///   title: 'Active session',
///   description: 'You have a session in progress.',
///   actions: [
///     AppDialogAction(label: 'Continue old session', onTap: () { ... }),
///     AppDialogAction(label: 'Start fresh', onTap: () { ... }),
///     AppDialogAction(label: 'Go to goodbye', onTap: () { ... }, isDestructive: true),
///   ],
/// );
/// ```
class AppDialog {
  AppDialog._();

  /// Shows the dialog.  Returns the result of `showDialog`.
  ///
  /// When [actions] is omitted a simple Yes / No pair is shown using
  /// [onYes] and [onNo] (default = `Navigator.pop`).
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    List<AppDialogAction>? actions,
    VoidCallback? onYes,
    VoidCallback? onNo,
    String yesLabel = 'Yes',
    String noLabel = 'Cancel',
  }) {
    final effectiveActions = actions ??
        [
          AppDialogAction(
            label: noLabel,
            onTap: onNo ?? () => Navigator.of(context).pop(),
          ),
          AppDialogAction(
            label: yesLabel,
            onTap: onYes ?? () => Navigator.of(context).pop(),
            isPrimary: true,
          ),
        ];

    return showDialog<void>(
      context: context,
      builder: (ctx) => _AppDialogWidget(
        title: title,
        description: description,
        actions: effectiveActions,
      ),
    );
  }
}

class AppDialogAction {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isPrimary;

  const AppDialogAction({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isPrimary = false,
  });
}

class _AppDialogWidget extends StatelessWidget {
  final String title;
  final String description;
  final List<AppDialogAction> actions;

  const _AppDialogWidget({
    required this.title,
    required this.description,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final Color textPrimary =
        isDark ? Colors.white : const Color(0xFF1A1A2E);
    final Color textMuted =
        isDark ? const Color(0xFF9E9EB8) : const Color(0xFF6B7280);
    final Color gold = const Color(0xFFD4A853);

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: TextStyle(
                color: textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              description,
              style: TextStyle(
                color: textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Actions — laid out as a column of full-width buttons
            ...actions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: _ActionButton(
                      action: action,
                      gold: gold,
                      isDark: isDark,
                      textMuted: textMuted,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final AppDialogAction action;
  final Color gold;
  final bool isDark;
  final Color textMuted;

  const _ActionButton({
    required this.action,
    required this.gold,
    required this.isDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    if (action.isDestructive) {
      return ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          action.onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          elevation: 0,
        ),
        child: Text(action.label,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      );
    }
    if (action.isPrimary) {
      return ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          action.onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          elevation: 0,
        ),
        child: Text(action.label,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      );
    }
    // Secondary / plain
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).pop();
        action.onTap();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: textMuted,
        side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.12)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
      child: Text(action.label,
          style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
