import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/app_background.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _progress = 0.0;
  String _message = "Reading your memories...";
  final List<String> _messages = [
    "Reading your memories...",
    "Scanning your folders...",
    "Counting the gigabytes...",
    "Grouping WhatsApp chats...",
    "Fetching familiar faces...",
    "Almost there...",
  ];
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    final prefs = await SharedPreferences.getInstance();

    // Simulate gradual progress while loading
    _updateProgress(0.1, 0);
    await Future.delayed(800.ms);

    _updateProgress(0.3, 1);
    // Removed premature scan triggers to prevent crashes before permissions are granted
    await Future.delayed(1000.ms);

    _updateProgress(0.5, 2);
    await Future.delayed(800.ms);

    _updateProgress(0.7, 3);
    await Future.delayed(800.ms);

    _updateProgress(0.9, 4);
    await Future.delayed(600.ms);

    _updateProgress(1.0, 5);
    await Future.delayed(600.ms);

    if (mounted) {
      final bool onboardingComplete =
          prefs.getBool('onboarding_complete') ?? false;
      if (onboardingComplete) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    }
  }

  void _updateProgress(double value, int messageIndex) {
    if (mounted) {
      setState(() {
        _progress = value;
        _messageIndex = messageIndex;
        _message = _messages[messageIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      gradientStyle: 1,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/reminisce_logo.png', width: 160)
                .animate()
                .fadeIn(duration: 800.ms, delay: 200.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                ),
            const SizedBox(height: 24),
            Text(
              'Reminisce',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 36,
                color: AppColors.darkPrimaryGold,
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: 48),
            Container(
              width: 220,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: 500.ms,
                    width: 220 * _progress,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimaryGold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: 400.ms,
              child: Text(
                _message,
                key: ValueKey(_message),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkTextMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
