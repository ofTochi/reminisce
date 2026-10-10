import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaFullscreen extends StatefulWidget {
  final FileSystemEntity file;

  const MediaFullscreen({super.key, required this.file});

  static void show(BuildContext context, FileSystemEntity file) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black,
      builder: (context) => MediaFullscreen(file: file),
    );
  }

  @override
  State<MediaFullscreen> createState() => _MediaFullscreenState();
}

class _MediaFullscreenState extends State<MediaFullscreen> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final path = widget.file.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mov')) {
      _videoController = VideoPlayerController.file(File(widget.file.path))
        ..initialize().then((_) {
          if (mounted) {
            setState(() => _isInitialized = true);
            _videoController?.play();
            _videoController?.setLooping(true);
          }
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildContent(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final path = widget.file.path.toLowerCase();
    if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.webp')) {
      return InteractiveViewer(
        maxScale: 5.0,
        child: Center(
          child: Image.file(File(widget.file.path), fit: BoxFit.contain),
        ),
      );
    } else if (_videoController != null && _isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
  }
}
