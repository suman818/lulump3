import 'package:flutter_riverpod/flutter_riverpod.dart';

//import '../../../core/playback/native_playback_bridge.dart';
import '../models/audio_track.dart';
import '../services/playback_queue_service.dart';
import 'playback_queue_service_provider.dart';

enum RepeatMode {
  off,
  all,
  one,
}

class PlaybackQueueState {
  const PlaybackQueueState({
    this.tracks = const [],
    this.currentIndex = -1,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.off,
  });

  final List<AudioTrack> tracks;
  final int currentIndex;
  final bool isShuffled;
  final RepeatMode repeatMode;

  AudioTrack? get currentTrack {
    if (currentIndex < 0 || currentIndex >= tracks.length) {
      return null;
    }
    return tracks[currentIndex];
  }

  PlaybackQueueState copyWith({
    List<AudioTrack>? tracks,
    int? currentIndex,
    bool? isShuffled,
    RepeatMode? repeatMode,
  }) {
    return PlaybackQueueState(
      tracks: tracks ?? this.tracks,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}

class PlaybackQueueNotifier extends Notifier<PlaybackQueueState> {
  late PlaybackQueueService _service;

  @override
  PlaybackQueueState build() {
    _service = ref.read(playbackQueueServiceProvider);
    return const PlaybackQueueState();
  }

  Future<void> loadQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    bool autoPlay = true,
  }) async {
    if (tracks.isEmpty) {
      state = const PlaybackQueueState();
      await _service.stop();
      return;
    }

    if (startIndex < 0 || startIndex >= tracks.length) {
      throw RangeError.index(startIndex, tracks, 'startIndex');
    }

    final queue = List<AudioTrack>.unmodifiable(tracks);

    await _service.loadQueue(
      tracks: queue,
      startIndex: startIndex,
    );

    state = state.copyWith(
      tracks: queue,
      currentIndex: startIndex,
    );

    if (autoPlay) {
      await _service.play();
    }
  }

  Future<void> playTrack(int index) async {
    if (index < 0 || index >= state.tracks.length) return;

    await _service.loadQueue(
      tracks: state.tracks,
      startIndex: index,
    );

    state = state.copyWith(currentIndex: index);
    await _service.play();
  }

  Future<void> next() async {
    final index = _nextIndex();
    if (index == null) return;
    await playTrack(index);
  }

  Future<void> previous() async {
    final index = _previousIndex();
    if (index == null) return;
    await playTrack(index);
  }

  Future<void> toggleShuffle() async {
    final enabled = !state.isShuffled;

    state = state.copyWith(isShuffled: enabled);

    await _service.setShuffleMode(enabled);
  }

  Future<void> cycleRepeatMode() async {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };

    state = state.copyWith(repeatMode: nextMode);

    final nativeMode = switch (nextMode) {
      RepeatMode.off => 0,
      RepeatMode.one => 1,
      RepeatMode.all => 2,
    };

    await _service.setRepeatMode(nativeMode);
  }

  int? _nextIndex() {
    if (state.tracks.isEmpty) return null;

    if (state.repeatMode == RepeatMode.one) {
      return state.currentIndex;
    }

    if (state.isShuffled && state.tracks.length > 1) {
      final candidates = List<int>.generate(
        state.tracks.length,
        (index) => index,
      )..remove(state.currentIndex);

      candidates.shuffle();
      return candidates.first;
    }

    if (state.currentIndex < state.tracks.length - 1) {
      return state.currentIndex + 1;
    }

    return state.repeatMode == RepeatMode.all ? 0 : null;
  }

  int? _previousIndex() {
    if (state.tracks.isEmpty) return null;

    if (state.repeatMode == RepeatMode.one) {
      return state.currentIndex;
    }

    if (state.currentIndex > 0) {
      return state.currentIndex - 1;
    }

    return state.repeatMode == RepeatMode.all ? state.tracks.length - 1 : null;
  }
}

final playbackQueueProvider =
    NotifierProvider<PlaybackQueueNotifier, PlaybackQueueState>(
  PlaybackQueueNotifier.new,
);
