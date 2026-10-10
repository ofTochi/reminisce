import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';
import 'widgets/filmstrip_bar.dart';
import 'widgets/action_buttons.dart';

class DocumentSwipeScreen extends ConsumerStatefulWidget {
  const DocumentSwipeScreen({super.key});

  @override
  ConsumerState<DocumentSwipeScreen> createState() => _DocumentSwipeScreenState();
}

class _DocumentSwipeScreenState extends ConsumerState<DocumentSwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allFiles = ref.watch(sessionProvider.select((s) => s.allFiles));
    final currentIndex = ref.watch(sessionProvider.select((s) => s.currentIndex));
    final markedFiles = ref.watch(sessionProvider.select((s) => s.markedFiles));
    final sourceName = ref.watch(sessionProvider.select((s) => s.activeSourceName));
    final sessionNotifier = ref.read(sessionProvider.notifier);

    if (allFiles.isEmpty) {
      return const Scaffold(body: Center(child: Text("No documents to clean")));
    }

    return AppBackground(
      gradientStyle: 2,
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(
              '$sourceName · ${currentIndex + 1}/${allFiles.length}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: CardSwiper(
              key: const ValueKey('document_swiper'),
              controller: _swiperController,
              cardsCount: allFiles.length,
              initialIndex: currentIndex,
              onSwipe: (previousIndex, nextIndex, direction) {
                if (direction == CardSwiperDirection.left) {
                  sessionNotifier.markFile(allFiles[previousIndex]);
                }
                sessionNotifier.jumpToIndex(nextIndex ?? previousIndex + 1);
                return true;
              },
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                final file = allFiles[index];
                final isMarked = markedFiles.contains(file);
                return _DocumentCard(file: file, isMarked: isMarked);
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

class _DocumentCard extends StatelessWidget {
  final FileSystemEntity file;
  final bool isMarked;

  const _DocumentCard({required this.file, required this.isMarked});

  @override
  Widget build(BuildContext context) {
    final bool isPdf = file.path.toLowerCase().endsWith('.pdf');
    final name = file.path.split('/').last;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMarked ? AppColors.darkDeleteRed : AppColors.darkPrimaryGold.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.article, color: AppColors.darkPrimaryGold, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isPdf
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: PDFView(
                            filePath: file.path,
                            autoSpacing: true,
                            pageSnap: true,
                            swipeHorizontal: true,
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.insert_drive_file, size: 80, color: AppColors.darkTextMuted),
                            const SizedBox(height: 16),
                            Text(
                              'File preview not available',
                              style: TextStyle(color: AppColors.darkTextMuted.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 60), // Room for footer
            ],
          ),
          if (isMarked)
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkDeleteRed.withOpacity(0.5),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Center(
                child: Icon(Icons.delete_forever, color: Colors.white, size: 80),
              ),
            ),
        ],
      ),
    );
  }
}
