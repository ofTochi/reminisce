import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';
import 'widgets/swipe_card.dart';
import 'widgets/filmstrip_bar.dart';
import 'widgets/action_buttons.dart';

class PhotoSwipeScreen extends ConsumerStatefulWidget {
  const PhotoSwipeScreen({super.key});

  @override
  ConsumerState<PhotoSwipeScreen> createState() => _PhotoSwipeScreenState();
}

class _PhotoSwipeScreenState extends ConsumerState<PhotoSwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allFiles = ref.watch(sessionProvider.select((s) => s.allFiles));
    final currentIndex = ref.watch(
      sessionProvider.select((s) => s.currentIndex),
    );
    final markedFiles = ref.watch(sessionProvider.select((s) => s.markedFiles));
    final sourceName = ref.watch(
      sessionProvider.select((s) => s.activeSourceName),
    );
    final sessionNotifier = ref.read(sessionProvider.notifier);

    if (allFiles.isEmpty) {
      return const Scaffold(body: Center(child: Text("No files to clean")));
    }

    return AppBackground(
      gradientStyle: 2,
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            centerTitle: true,
            title: Text(
              sourceName ?? 'Cleanup',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Playfair Display',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.grid_view,
                  color: AppColors.darkPrimaryGold,
                ),
                onPressed: () => context.push('/clean/grid'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '${currentIndex + 1} of ${allFiles.length}',
              style: const TextStyle(
                color: AppColors.darkTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: CardSwiper(
              key: const ValueKey('photo_swiper'), // Keep the swiper stable
              controller: _swiperController,
              cardsCount: allFiles.length,
              initialIndex: currentIndex,
              numberOfCardsDisplayed: 1,
              padding: const EdgeInsets.all(24.0),
              duration: const Duration(milliseconds: 200),
              threshold: 50, // More sensitive swipe
              allowedSwipeDirection: const AllowedSwipeDirection.all(),
              onSwipe: (previousIndex, nextIndex, direction) {
                if (direction == CardSwiperDirection.left) {
                  sessionNotifier.markFile(allFiles[previousIndex]);
                } else if (direction == CardSwiperDirection.bottom) {
                  // Swipe down to undo
                  if (currentIndex > 0) {
                    _swiperController.undo();
                    // onUndo will handle the provider state
                  }
                  return false; // Don't allow it to clear as a "next" swipe
                }

                // For Right and Top, we just move next (already happens by returning true)
                sessionNotifier.jumpToIndex(nextIndex ?? previousIndex + 1);

                if (nextIndex == null || nextIndex >= allFiles.length - 1) {
                  if (markedFiles.isNotEmpty) {
                    context.push('/goodbye');
                  } else {
                    context.pop();
                  }
                }
                return true;
              },
              onUndo: (previousIndex, currentIndex, direction) {
                sessionNotifier.undoLastSwipe();
                return true;
              },
              cardBuilder:
                  (context, index, percentThresholdX, percentThresholdY) {
                    final file = allFiles[index];
                    final isMarked = markedFiles.contains(file);
                    return SwipeCard(
                      file: file,
                      isMarked: isMarked,
                      isTopCard:
                          index == currentIndex, // Video plays only on top
                    );
                  },
            ),
          ),
          FilmstripBar(
            files: allFiles,
            currentIndex: currentIndex,
            markedFiles: markedFiles,
            onJump: (index) {
              _swiperController.moveTo(index);
              sessionNotifier.jumpToIndex(index);
            },
            onToggleMark: (file) {
              if (markedFiles.contains(file)) {
                sessionNotifier.unmarkFile(file);
              } else {
                sessionNotifier.markFile(file);
              }
            },
          ),
          ActionButtons(
            onUndo: () => _swiperController.undo(),
            onViewMarked: () => context.push('/goodbye'),
            markedCount: markedFiles.length,
            canUndo: currentIndex > 0,
          ),
        ],
      ),
    );
  }
}
