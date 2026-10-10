import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/permissions/permissions_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/folders/folder_browser_screen.dart';
import '../../features/whatsapp/whatsapp_list_screen.dart';
import '../../features/clean/photo_swipe_screen.dart';
import '../../features/clean/document_swipe_screen.dart';
import '../../features/clean/audio_swipe_screen.dart';
import '../../features/clean/grid_view_screen.dart';
import '../../features/goodbye/goodbye_screen.dart';
import '../widgets/bottom_nav_scaffold.dart';

final GoRouter appRouter = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => BottomNavScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/folders',
        builder: (context, state) => const FolderBrowserScreen(),
      ),
      GoRoute(
        path: '/whatsapp',
        builder: (context, state) => const WhatsAppListScreen(),
      ),
      GoRoute(
        path: '/clean/photo',
        builder: (context, state) => const PhotoSwipeScreen(),
      ),
      GoRoute(
        path: '/clean/document',
        builder: (context, state) => const DocumentSwipeScreen(),
      ),
      GoRoute(
        path: '/clean/audio',
        builder: (context, state) => const AudioSwipeScreen(),
      ),
      GoRoute(
        path: '/clean/grid',
        builder: (context, state) => const GridViewScreen(),
      ),
      GoRoute(
        path: '/goodbye',
        builder: (context, state) => const GoodbyeScreen(),
      ),
    ],
);
