import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../router/route_names.dart';
import '../../../providers/session_provider.dart';

class BottomNavScaffold extends ConsumerWidget {
  final Widget child;

  const BottomNavScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final int currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      body: Stack(
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CustomBottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(index, context),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/analytics')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.analytics);
        break;
      case 2:
        context.go(RouteNames.settings);
        break;
    }
  }
}

class _CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionStatus = ref.watch(sessionProvider).status;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark
        ? AppColors.darkPrimaryGold
        : AppColors.lightPrimaryTerracotta;
    final Color surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // LEFT ISLAND
            Expanded(
              flex: 4,
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: currentIndex == 0
                          ? Icons.home
                          : Icons.home_outlined,
                      label: 'Home',
                      isSelected: currentIndex == 0,
                      onTap: () => onTap(0),
                      primaryColor: primaryColor,
                    ),
                    _NavItem(
                      icon: currentIndex == 1
                          ? Icons.bar_chart
                          : Icons.bar_chart_outlined,
                      label: 'Analytics',
                      isSelected: currentIndex == 1,
                      onTap: () => onTap(1),
                      primaryColor: primaryColor,
                    ),
                    _NavItem(
                      icon: currentIndex == 2
                          ? Icons.settings
                          : Icons.settings_outlined,
                      label: 'Settings',
                      isSelected: currentIndex == 2,
                      onTap: () => onTap(2),
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // RIGHT ISLAND (FAB)
            GestureDetector(
              onTap: () {
                if (sessionStatus == SessionStatus.inProgress) {
                  // Navigate back to active session
                  final session = ref.read(sessionProvider);
                  if (session.activeContentType == ContentType.photo) {
                    context.push(RouteNames.cleanPhoto);
                  } else if (session.activeContentType ==
                      ContentType.document) {
                    context.push(RouteNames.cleanDocument);
                  } else if (session.activeContentType == ContentType.audio) {
                    context.push(RouteNames.cleanAudio);
                  }
                } else if (sessionStatus == SessionStatus.pendingDelete) {
                  context.push(RouteNames.goodbye);
                } else {
                  context.go(RouteNames.home);
                }
              },
              child: Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: sessionStatus == SessionStatus.pendingDelete
                        ? AppColors.darkDeleteRed
                        : primaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (sessionStatus == SessionStatus.pendingDelete
                                  ? AppColors.darkDeleteRed
                                  : primaryColor)
                              .withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    Icon(
                          Icons.auto_fix_high,
                          color: sessionStatus == SessionStatus.pendingDelete
                              ? AppColors.darkDeleteRed
                              : primaryColor,
                          size: 32,
                        )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                          target: sessionStatus == SessionStatus.inProgress
                              ? 1.0
                              : 0.0,
                        )
                        .scaleXY(
                          begin: 1.0,
                          end: 1.18,
                          duration: 900.ms,
                          curve: Curves.easeInOut,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
