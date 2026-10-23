
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/playback/native_playback_bridge.dart';
import '../services/playback_queue_service.dart';

final playbackQueueServiceProvider = Provider<PlaybackQueueService>((ref) {
  return PlaybackQueueService(
    NativePlaybackBridge.instance,
  );
});
