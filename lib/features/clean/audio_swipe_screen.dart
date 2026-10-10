import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_waveforms/audio_waveforms.dart' hide PlayerState;
import '../../../core/widgets/app_background.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';
import 'widgets/filmstrip_bar.dart';
import 'widgets/action_buttons.dart';

class AudioSwipeScreen extends ConsumerStatefulWidget {
  const AudioSwipeScreen({super.key});

  @override
  ConsumerState<AudioSwipeScreen> createState() => _AudioSwipeScreenState();
}

class _AudioSwipeScreenState extends ConsumerState<AudioSwipeScreen> {
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
      return const Scaffold(body: Center(child: Text("No audio to clean")));
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
              key: const ValueKey('audio_swiper'),
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
                return _AudioCard(file: file, isMarked: isMarked);
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

class _AudioCard extends StatefulWidget {
  final FileSystemEntity file;
  final bool isMarked;

  const _AudioCard({required this.file, required this.isMarked});

  @override
  State<_AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<_AudioCard> {
  late AudioPlayer _player;
  late PlayerController _waveformController;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _waveformController = PlayerController();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _player.setFilePath(widget.file.path);
    await _waveformController.preparePlayer(
      path: widget.file.path,
      noOfSamples: 100,
    );
    _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.file.path.split('/').last;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isMarked ? AppColors.darkDeleteRed : AppColors.darkPrimaryGold.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AudioFileWaveforms(
                size: const Size(double.infinity, 100),
                playerController: _waveformController,
                waveformType: WaveformType.fitWidth,
                playerWaveStyle: const PlayerWaveStyle(
                  fixedWaveColor: AppColors.darkTextMuted,
                  liveWaveColor: AppColors.darkPrimaryGold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.darkPrimaryGold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = _player.duration ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        value: position.inMilliseconds.toDouble(),
                        max: total.inMilliseconds.toDouble(),
                        onChanged: (val) => _player.seek(Duration(milliseconds: val.toInt())),
                        activeColor: AppColors.darkPrimaryGold,
                        inactiveColor: AppColors.darkTextMuted.withOpacity(0.3),
                      ),
                      Text(
                        '${_formatDuration(position)} / ${_formatDuration(total)}',
                        style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_5, size: 32),
                    onPressed: () => _player.seek(_player.position - const Duration(seconds: 5)),
                  ),
                  const SizedBox(width: 24),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return IconButton(
                        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 64, color: AppColors.darkPrimaryGold),
                        onPressed: () => playing ? _player.pause() : _player.play(),
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.forward_5, size: 32),
                    onPressed: () => _player.seek(_player.position + const Duration(seconds: 5)),
                  ),
                ],
              ),
            ],
          ),
          if (widget.isMarked)
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

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
