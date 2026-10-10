import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../../../providers/settings_provider.dart';
import '../../../core/widgets/media_fullscreen.dart';

class SwipeCard extends StatefulWidget {
  final FileSystemEntity file;
  final bool isMarked;
  final bool isTopCard;

  const SwipeCard({
    super.key,
    required this.file,
    required this.isMarked,
    this.isTopCard = false,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with RouteAware, WidgetsBindingObserver {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isRouteVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVideo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (_isRouteVisible != isCurrent) {
      _isRouteVisible = isCurrent;
      _handlePlayback();
    }
  }

  @override
  void didUpdateWidget(SwipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _videoController?.dispose();
      _videoController = null;
      _isInitialized = false;
      _initVideo();
    } else if (oldWidget.isTopCard != widget.isTopCard) {
      _handlePlayback();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _videoController?.pause();
    } else if (state == AppLifecycleState.resumed && widget.isTopCard) {
      _videoController?.play();
    }
  }

  void _handlePlayback() {
    if (!_isInitialized || _videoController == null) return;
    if (widget.isTopCard && _isRouteVisible) {
      _videoController?.play();
    } else {
      _videoController?.pause();
    }
  }

  void _initVideo() {
    final path = widget.file.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.3gp') || path.endsWith('.mkv')) {
      _videoController = VideoPlayerController.file(File(widget.file.path))
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _isInitialized = true);
            _videoController?.setLooping(true);
            _handlePlayback();
          }
        }).catchError((e) {
          debugPrint('Video init error: $e');
          if (mounted) {
            setState(() => _isInitialized = false);
          }
        });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(settingsProvider);
        final fit = settings.fitContent ? BoxFit.contain : BoxFit.cover;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: _buildContent(fit),
              ),
              _buildForegroundOverlay(),
              if (widget.isMarked) _buildMarkedOverlay(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.isMarked
                        ? AppColors.darkDeleteRed
                        : AppColors.darkPrimaryGold.withOpacity(0.5),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BoxFit fit) {
    final path = widget.file.path.toLowerCase();
    late Widget media;
    if (path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp')) {
      media = Image.file(File(widget.file.path), fit: fit);
    } else if (_videoController != null && _isInitialized) {
      media = FittedBox(
        fit: fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else {
      media = Container(
        color: AppColors.darkSurface,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.darkPrimaryGold,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => MediaFullscreen.show(context, widget.file),
      onDoubleTap: () {
        if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.3gp') || path.endsWith('.mkv')) {
          if (_videoController != null && _isInitialized) {
            if (_videoController!.value.isPlaying) {
              _videoController?.pause();
            } else {
              _videoController?.play();
            }
          }
        }
      },
      child: media,
    );
  }

  Widget _buildForegroundOverlay() {
    final name = widget.file.path.split('/').last;
    final stats = widget.file.statSync();
    final size = '${(stats.size / (1024 * 1024)).toStringAsFixed(1)} MB';
    final date = DateFormat('MMM d, yyyy').format(stats.modified);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              '$size · $date',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkedOverlay() {
    return Container(
      color: AppColors.darkDeleteRed.withOpacity(0.5),
      child: const Center(
        child: Icon(Icons.delete_forever, color: Colors.white, size: 80),
      ),
    );
  }
}
