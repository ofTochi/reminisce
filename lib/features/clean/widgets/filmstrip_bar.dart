import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FilmstripBar extends StatefulWidget {
  final List<FileSystemEntity> files;
  final int currentIndex;
  final List<FileSystemEntity> markedFiles;
  final Function(int) onJump;
  final Function(FileSystemEntity) onToggleMark;

  const FilmstripBar({
    super.key,
    required this.files,
    required this.currentIndex,
    required this.markedFiles,
    required this.onJump,
    required this.onToggleMark,
  });

  @override
  State<FilmstripBar> createState() => _FilmstripBarState();
}

class _FilmstripBarState extends State<FilmstripBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(FilmstripBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToCurrent();
    }
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients) return;
    
    // Each item is 56 wide + 8 margin (4 left, 4 right) = 64 total
    const double itemWidth = 64.0;
    final double targetOffset = (widget.currentIndex * itemWidth) - 
                                (MediaQuery.of(context).size.width / 2) + 
                                (itemWidth / 2);
    
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.files.length,
        itemBuilder: (context, index) {
          final file = widget.files[index];
          final isCurrent = index == widget.currentIndex;
          final isMarked = widget.markedFiles.contains(file);

          return GestureDetector(
            onTap: () {
              if (isCurrent) {
                widget.onToggleMark(file);
              } else {
                widget.onJump(index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(4),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.darkPrimaryGold
                      : (isMarked ? AppColors.darkDeleteRed : Colors.transparent),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _buildThumbnail(file),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnail(FileSystemEntity file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.webp')) {
      return Image.file(File(file.path), fit: BoxFit.cover);
    } else if (path.endsWith('.mp4') || path.endsWith('.mov')) {
      return const Center(child: Icon(Icons.videocam, color: Colors.white, size: 20));
    } else if (path.endsWith('.pdf')) {
      return const Center(child: Icon(Icons.picture_as_pdf, color: Colors.white, size: 20));
    } else if (path.endsWith('.mp3') || path.endsWith('.wav') || path.endsWith('.m4a')) {
      return const Center(child: Icon(Icons.audiotrack, color: Colors.white, size: 20));
    }
    return const Icon(Icons.description, color: Colors.white, size: 20);
  }
}
