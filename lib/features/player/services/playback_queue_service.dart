import '../../../core/playback/native_playback_bridge.dart';
import '../models/audio_track.dart';

class PlaybackQueueService {
  PlaybackQueueService(this._bridge);

  final NativePlaybackBridge _bridge;

  Future<void> loadQueue({
    required List<AudioTrack> tracks,
    required int startIndex,
  }) async {
    if (tracks.isEmpty) {
      throw ArgumentError('The playback queue cannot be empty.');
    }

    if (startIndex < 0 || startIndex >= tracks.length) {
      throw RangeError.index(startIndex, tracks, 'startIndex');
    }

    final nativeTracks = tracks.map((track) {
      return <String, String>{
        'uri': track.uri.toString(),
        'title': track.title,
        'artist': track.artist,
      };
    }).toList(growable: false);

    await _bridge.setPlaylist(
      tracks: nativeTracks,
      startIndex: startIndex,
    );
  }

  Future<void> play() => _bridge.play();

  Future<void> pause() => _bridge.pause();

  Future<void> stop() => _bridge.stop();

  Future<void> skipTo(Duration position) => _bridge.seekTo(position);

  Future<void> setShuffleMode(bool enabled) {
    return _bridge.setShuffleMode(enabled);
  }

  Future<void> setRepeatMode(int mode) {
    return _bridge.setRepeatMode(mode);
  }
}
