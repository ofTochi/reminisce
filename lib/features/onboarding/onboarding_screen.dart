import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/app_background.dart';
import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Clean by feel, not by list",
      subtitle: "Swipe right to keep. Swipe left to let go.\nOne memory at a time.",
      lottieAsset: 'assets/lottie/swipe_demo.json',
      fallback: const _SwipeFallback(),
    ),
    OnboardingData(
      title: "Clean by who sent it",
      subtitle: "Your WhatsApp media, grouped by the person or group that sent it. Clean chat by chat.",
      lottieAsset: 'assets/lottie/whatsapp_groups.json',
      fallback: const _WhatsAppFallback(),
    ),
    OnboardingData(
      title: "Watch your space come back",
      subtitle: "Track freed storage, build a cleaning streak, and make room for new memories.",
      lottieAsset: 'assets/lottie/storage_clear.json',
      fallback: const _StorageFallback(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      gradientStyle: 1,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => context.go('/permissions'),
              child: const Text(
                'Skip',
                style: TextStyle(color: AppColors.darkPrimaryGold),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 280,
                        child: Lottie.asset(
                          page.lottieAsset,
                          errorBuilder: (context, error, stackTrace) => page.fallback,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 28,
                          color: AppColors.darkPrimaryGold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkTextMuted,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: 300.ms,
                width: _currentPage == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppColors.darkPrimaryGold : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _controller.nextPage(duration: 300.ms, curve: Curves.easeInOut);
                  } else {
                    context.go('/permissions');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Get Started →' : 'Next →',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String lottieAsset;
  final Widget fallback;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.fallback,
  });
}

class _SwipeFallback extends StatelessWidget {
  const _SwipeFallback();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkPrimaryGold.withOpacity(0.3)),
          ),
        ).animate(onPlay: (c) => c.repeat())
         .moveX(begin: 0, end: -300, duration: 1500.ms, curve: Curves.easeIn)
         .fadeOut(duration: 500.ms, delay: 1000.ms),
        Container(
          width: 200,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkPrimaryGold.withOpacity(0.3)),
          ),
        ).animate(onPlay: (c) => c.repeat())
         .moveX(begin: 0, end: 300, duration: 1500.ms, delay: 1500.ms, curve: Curves.easeIn)
         .fadeOut(duration: 500.ms, delay: 2500.ms),
      ],
    );
  }
}

class _WhatsAppFallback extends StatelessWidget {
  const _WhatsAppFallback();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) => 
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 60,
          width: 280,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const CircleAvatar(backgroundColor: AppColors.darkPrimaryGold, radius: 20),
              const SizedBox(width: 12),
              Container(height: 12, width: 140, color: AppColors.darkTextMuted.withOpacity(0.2)),
            ],
          ),
        ).animate()
         .slideX(begin: 1.0, end: 0, duration: 600.ms, delay: (index * 200).ms)
         .fadeIn()
      ),
    );
  }
}

class _StorageFallback extends StatelessWidget {
  const _StorageFallback();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: 0.8,
              strokeWidth: 12,
              backgroundColor: AppColors.darkSurface,
              color: AppColors.darkPrimaryGold,
            ).animate(onPlay: (c) => c.repeat())
             .custom(duration: 2000.ms, builder: (context, value, child) {
               return CircularProgressIndicator(
                 value: 0.8 - (value * 0.6),
                 strokeWidth: 12,
                 backgroundColor: AppColors.darkSurface,
                 color: AppColors.darkPrimaryGold,
               );
             }),
          ),
          const Icon(Icons.storage, size: 60, color: AppColors.darkPrimaryGold),
        ],
      ),
    );
  }
}
