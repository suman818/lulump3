import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/playback/native_playback_bridge.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/audio_track.dart';
import 'providers/playback_queue_provider.dart' as queue;

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  final NativePlaybackBridge _bridge = NativePlaybackBridge.instance;

  PlaybackSnapshot? _snapshot;
  StreamSubscription<PlaybackSnapshot>? _subscription;
  Timer? _progressTimer;

  bool _busy = false;
  bool _connected = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final initial = await _bridge.connect();
      if (!mounted) return;

      setState(() {
        _snapshot = initial;
        _connected = true;
        _error = null;
      });

      _subscription = _bridge.snapshots.listen(
        (snapshot) {
          if (!mounted) return;
          setState(() => _snapshot = snapshot);
        },
        onError: (Object error) {
          if (!mounted) return;
          setState(() => _error = error.toString());
        },
      );
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) async {
          if (!mounted || !_connected) return;

          try {
            final updated = await _bridge.getSnapshot();

            if (mounted) {
              setState(() => _snapshot = updated);
            }
          } catch (_) {
            // Ignore temporary polling errors; stream events remain active.
          }
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_busy) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await action();
      final updated = await _bridge.getSnapshot();
      if (mounted) setState(() => _snapshot = updated);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _chooseAudio() async {
    if (_busy) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty || !mounted) return;

      final tracks = <AudioTrack>[];

      for (final file in result.files) {
        final identifier = file.identifier;

        if (identifier == null || identifier.isEmpty) {
          continue;
        }

        tracks.add(
          AudioTrack(
            id: identifier,
            uri: Uri.parse(identifier),
            title: file.name,
            artist: 'Local audio',
          ),
        );
      }

      if (tracks.isEmpty) {
        setState(() {
          _error = 'No selected files had usable media URIs.';
        });
        return;
      }

      setState(() {
        _busy = true;
        _error = null;
      });

      await ref.read(queue.playbackQueueProvider.notifier).loadQueue(
            tracks,
            startIndex: 0,
            autoPlay: true,
          );

      final updated = await _bridge.getSnapshot();

      if (mounted) {
        setState(() {
          _snapshot = updated;
          _connected = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String _formatTime(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutesPart = seconds ~/ 60;
    final secondsPart = seconds % 60;

    return '$minutesPart:${secondsPart.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final duration = snapshot?.durationMs ?? 0;
    final position = snapshot?.positionMs ?? 0;
    final safePosition = position.clamp(0, duration > 0 ? duration : 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      _roundIcon(
                        Icons.keyboard_arrow_down_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'NOW PLAYING',
                              style: AppTextStyles.overline,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'LOCAL LIBRARY',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _roundIcon(
                        Icons.more_horiz_rounded,
                        onTap: _chooseAudio,
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.20),
                                  AppColors.accent.withValues(alpha: 0.02),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.graphic_eq_rounded,
                            color: AppColors.accent,
                            size: 108,
                          ),
                          Positioned(
                            bottom: 18,
                            child: Text(
                              snapshot?.title.isNotEmpty == true
                                  ? 'LOCAL AUDIO'
                                  : 'READY TO PLAY',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot?.title.isNotEmpty == true
                                  ? snapshot!.title
                                  : 'No track selected',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.trackTitle,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              snapshot?.artist.isNotEmpty == true
                                  ? snapshot!.artist
                                  : 'Choose a local audio file',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.trackArtist,
                            ),
                          ],
                        ),
                      ),
                      _roundIcon(
                        Icons.favorite_border_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.accent,
                      inactiveTrackColor: const Color(0xFF383630),
                      thumbColor: AppColors.textPrimary,
                      overlayColor: AppColors.accent.withValues(alpha: 0.12),
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 5),
                    ),
                    child: Slider(
                      value: safePosition.toDouble(),
                      min: 0,
                      max: duration > 0 ? duration.toDouble() : 1,
                      onChanged: duration <= 0
                          ? null
                          : (value) {
                              setState(() {
                                if (_snapshot != null) {
                                  _snapshot = PlaybackSnapshot(
                                    isPlaying: _snapshot!.isPlaying,
                                    playbackState: _snapshot!.playbackState,
                                    positionMs: value.round(),
                                    durationMs: _snapshot!.durationMs,
                                    title: _snapshot!.title,
                                    artist: _snapshot!.artist,
                                  );
                                }
                              });
                            },
                      onChangeEnd: duration <= 0
                          ? null
                          : (value) => _runAction(
                                () => _bridge.seekTo(
                                  Duration(milliseconds: value.round()),
                                ),
                              ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(position),
                          style: AppTextStyles.playbackTime,
                        ),
                        Text(
                          '-${_formatTime((duration - position).clamp(0, duration))}',
                          style: AppTextStyles.playbackTime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _roundIcon(
                        Icons.shuffle_rounded,
                        color: ref.watch(queue.playbackQueueProvider).isShuffled
                            ? AppColors.accent
                            : AppColors.textPrimary,
                        onTap: () {
                          ref
                              .read(queue.playbackQueueProvider.notifier)
                              .toggleShuffle();
                        },
                      ),
                      _roundIcon(
                        Icons.skip_previous_rounded,
                        onTap: () {
                          ref
                              .read(queue.playbackQueueProvider.notifier)
                              .previous();
                        },
                      ),
                      GestureDetector(
                        onTap: !_connected || _busy
                            ? null
                            : () {
                                final playing = _snapshot?.isPlaying ?? false;
                                _runAction(
                                  playing ? _bridge.pause : _bridge.play,
                                );
                              },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            (snapshot?.isPlaying ?? false)
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 38,
                            color: const Color(0xFF17130A),
                          ),
                        ),
                      ),
                      _roundIcon(
                        Icons.skip_next_rounded,
                        onTap: () {
                          ref.read(queue.playbackQueueProvider.notifier).next();
                        },
                      ),
                      _roundIcon(
                        ref.watch(queue.playbackQueueProvider).repeatMode ==
                                queue.RepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color:
                            ref.watch(queue.playbackQueueProvider).repeatMode ==
                                    queue.RepeatMode.off
                                ? AppColors.textSecondary
                                : AppColors.accent,
                        onTap: () {
                          ref
                              .read(queue.playbackQueueProvider.notifier)
                              .cycleRepeatMode();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.equalizer_rounded,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Audio engine',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Native Media3 playback',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _connected ? Icons.check_circle : Icons.error_outline,
                          color: _connected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _chooseAudio,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Choose audio file'),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundIcon(
    IconData icon, {
    required VoidCallback onTap,
    Color? color,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: color ?? AppColors.textPrimary,
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        fixedSize: const Size(44, 44),
      ),
    );
  }
}
