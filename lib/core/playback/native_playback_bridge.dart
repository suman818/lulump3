import 'dart:async';

import 'package:flutter/services.dart';

class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.isPlaying,
    required this.playbackState,
    required this.positionMs,
    required this.durationMs,
    required this.title,
    required this.artist,
  });

  final bool isPlaying;
  final int playbackState;
  final int positionMs;
  final int durationMs;
  final String title;
  final String artist;

  factory PlaybackSnapshot.fromMap(Map<Object?, Object?> map) {
    return PlaybackSnapshot(
      isPlaying: map['isPlaying'] as bool? ?? false,
      playbackState: (map['playbackState'] as num?)?.toInt() ?? 1,
      positionMs: (map['positionMs'] as num?)?.toInt() ?? 0,
      durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      artist: map['artist'] as String? ?? '',
    );
  }
}

class NativePlaybackBridge {
  NativePlaybackBridge._();

  static final NativePlaybackBridge instance = NativePlaybackBridge._();

  static const MethodChannel _methodChannel =
      MethodChannel('premium_audio_player/playback');

  static const EventChannel _eventChannel =
      EventChannel('premium_audio_player/events');

  Stream<PlaybackSnapshot>? _snapshots;

  Stream<PlaybackSnapshot> get snapshots {
    return _snapshots ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is Map)
        .map(
          (event) => PlaybackSnapshot.fromMap(
            Map<Object?, Object?>.from(event as Map),
          ),
        )
        .asBroadcastStream();
  }

  Future<PlaybackSnapshot> connect() async {
    final result = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'connect',
    );

    if (result == null) {
      throw PlatformException(
        code: 'EMPTY_SNAPSHOT',
        message: 'Native playback service returned no player state.',
      );
    }

    return PlaybackSnapshot.fromMap(result);
  }

  Future<void> play() => _methodChannel.invokeMethod<void>('play');

  Future<void> pause() => _methodChannel.invokeMethod<void>('pause');

  Future<void> stop() => _methodChannel.invokeMethod<void>('stop');

  Future<void> seekTo(Duration position) {
    return _methodChannel.invokeMethod<void>(
      'seekTo',
      {'positionMs': position.inMilliseconds},
    );
  }

  Future<void> setMedia({
    required Uri uri,
    required String title,
    required String artist,
  }) {
    return _methodChannel.invokeMethod<void>(
      'setMedia',
      {
        'uri': uri.toString(),
        'title': title,
        'artist': artist,
      },
    );
  }

  Future<void> setPlaylist({
    required List<Map<String, String>> tracks,
    required int startIndex,
  }) {
    return _methodChannel.invokeMethod<void>(
      'setPlaylist',
      {
        'tracks': tracks,
        'startIndex': startIndex,
      },
    );
  }

  Future<void> setShuffleMode(bool enabled) {
    return _methodChannel.invokeMethod<void>(
      'setShuffleMode',
      {'enabled': enabled},
    );
  }

  Future<void> setRepeatMode(int mode) {
    return _methodChannel.invokeMethod<void>(
      'setRepeatMode',
      {'mode': mode},
    );
  }

  Future<void> skipToNext() {
    return _methodChannel.invokeMethod<void>('skipToNext');
  }

  Future<void> skipToPrevious() {
    return _methodChannel.invokeMethod<void>('skipToPrevious');
  }

  Future<PlaybackSnapshot> getSnapshot() async {
    final result = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'getSnapshot',
    );

    if (result == null) {
      throw PlatformException(
        code: 'EMPTY_SNAPSHOT',
        message: 'Native playback service returned no player state.',
      );
    }

    return PlaybackSnapshot.fromMap(result);
  }
}
