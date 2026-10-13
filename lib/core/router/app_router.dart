import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/permissions/permissions_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/folders/folder_browser_screen.dart';
import '../../features/whatsapp/whatsapp_cleaner_screen.dart';
import '../../features/whatsapp/whatsapp_category_screen.dart';
import '../../features/clean/photo_swipe_screen.dart';
import '../../features/clean/document_swipe_screen.dart';
import '../../features/clean/audio_swipe_screen.dart';
import '../../features/clean/grid_view_screen.dart';
import '../../features/goodbye/goodbye_screen.dart';
import '../../models/whatsapp_category.dart';
import '../widgets/bottom_nav_scaffold.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.permissions,
        builder: (context, state) => const PermissionsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => BottomNavScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.analytics,
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.folders,
        builder: (context, state) => const FolderBrowserScreen(),
      ),
      GoRoute(
        path: RouteNames.whatsapp,
        builder: (context, state) => const WhatsAppCleanerScreen(),
      ),
      GoRoute(
        path: RouteNames.whatsappCategory,
        builder: (context, state) {
          final category = state.extra as WhatsAppCategory;
          return WhatsAppCategoryScreen(category: category);
        },
      ),
      GoRoute(
        path: RouteNames.cleanPhoto,
        builder: (context, state) => const PhotoSwipeScreen(),
      ),
      GoRoute(
        path: RouteNames.cleanDocument,
        builder: (context, state) => const DocumentSwipeScreen(),
      ),
      GoRoute(
        path: RouteNames.cleanAudio,
        builder: (context, state) => const AudioSwipeScreen(),
      ),
      GoRoute(
        path: RouteNames.cleanGrid,
        builder: (context, state) => const GridViewScreen(),
      ),
      GoRoute(
        path: RouteNames.goodbye,
        builder: (context, state) => const GoodbyeScreen(),
      ),
    ],
);
