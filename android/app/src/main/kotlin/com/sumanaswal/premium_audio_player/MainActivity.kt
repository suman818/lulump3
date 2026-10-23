
package com.sumanaswal.premium_audio_player

import android.content.ComponentName
import android.os.Bundle
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import androidx.media3.common.Player
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.google.common.util.concurrent.ListenableFuture

class MainActivity : FlutterActivity() {

    companion object {
        private const val METHOD_CHANNEL = "premium_audio_player/playback"
        private const val EVENT_CHANNEL = "premium_audio_player/events"
    }

    private var controllerFuture: ListenableFuture<MediaController>? = null
    private var mediaController: MediaController? = null
    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        )
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                eventSink = sink
                emitSnapshot()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            val controller = mediaController

            when (call.method) {
                "connect" -> {
                    connectToPlaybackService(result)
                }

                "play" -> {
                    if (controller == null) {
                        result.error("NOT_CONNECTED", "Player is not connected", null)
                    } else {
                        controller.play()
                        result.success(null)
                    }
                }

                "pause" -> {
                    if (controller == null) {
                        result.error("NOT_CONNECTED", "Player is not connected", null)
                    } else {
                        controller.pause()
                        result.success(null)
                    }
                }

                "stop" -> {
                    if (controller == null) {
                        result.error("NOT_CONNECTED", "Player is not connected", null)
                    } else {
                        controller.stop()
                        result.success(null)
                    }
                }

                
                "skipToNext" -> {
                    if (controller == null) {
                        result.error(
                            "NOT_CONNECTED",
                            "Player is not connected",
                            null
                        )
                    } else {
                        controller.seekToNextMediaItem()
                        result.success(null)
                    }
                }

                "skipToPrevious" -> {
                    if (controller == null) {
                        result.error(
                            "NOT_CONNECTED",
                            "Player is not connected",
                            null
                        )
                    } else {
                        controller.seekToPreviousMediaItem()
                        result.success(null)
                    }
                }


                
                "setShuffleMode" -> {
                    if (controller == null) {
                        result.error(
                            "NOT_CONNECTED",
                            "Player is not connected",
                            null
                        )
                    } else {
                        val enabled =
                            call.argument<Boolean>("enabled")

                        if (enabled == null) {
                            result.error(
                                "INVALID_ARGUMENT",
                                "enabled must be a boolean",
                                null
                            )
                        } else {
                            controller.shuffleModeEnabled = enabled
                            result.success(null)
                        }
                    }
                }

                "setRepeatMode" -> {
                    if (controller == null) {
                        result.error(
                            "NOT_CONNECTED",
                            "Player is not connected",
                            null
                        )
                    } else {
                        val mode = call.argument<Int>("mode")

                        if (mode !in 0..2) {
                            result.error(
                                "INVALID_ARGUMENT",
                                "mode must be 0 (off), 1 (one), or 2 (all)",
                                null
                            )
                        } else {
                            controller.repeatMode = when (mode) {
                                1 -> Player.REPEAT_MODE_ONE
                                2 -> Player.REPEAT_MODE_ALL
                                else -> Player.REPEAT_MODE_OFF
                            }
                            result.success(null)
                        }
                    }
                }


                "seekTo" -> {
                    if (controller == null) {
                        result.error("NOT_CONNECTED", "Player is not connected", null)
                    } else {
                        val position = call.argument<Number>("positionMs")?.toLong()
                        if (position == null || position < 0L) {
                            result.error("INVALID_ARGUMENT", "positionMs must be non-negative", null)
                        } else {
                            controller.seekTo(position)
                            result.success(null)
                        }
                    }
                }

                "setMedia" -> {
                    if (controller == null) {
                        result.error("NOT_CONNECTED", "Player is not connected", null)
                    } else {
                        val uri = call.argument<String>("uri")
                        val title = call.argument<String>("title") ?: "Unknown title"
                        val artist = call.argument<String>("artist") ?: "Unknown artist"

                        if (uri.isNullOrBlank()) {
                            result.error("INVALID_ARGUMENT", "A non-empty uri is required", null)
                        } else {
                            val item = androidx.media3.common.MediaItem.Builder()
                                .setUri(uri)
                                .setMediaMetadata(
                                    androidx.media3.common.MediaMetadata.Builder()
                                        .setTitle(title)
                                        .setArtist(artist)
                                        .build()
                                )
                                .build()

                            controller.setMediaItem(item)
                            controller.prepare()
                            result.success(null)
                        }
                    }
                }
                
                "setPlaylist" -> {
                    if (controller == null) {
                        result.error(
                            "NOT_CONNECTED",
                            "Player is not connected",
                            null
                        )
                    } else {
                        val rawTracks = call.argument<List<*>>("tracks")
                        val startIndex =
                            call.argument<Int>("startIndex") ?: 0

                        if (rawTracks.isNullOrEmpty()) {
                            result.error(
                                "INVALID_ARGUMENT",
                                "Playlist must contain at least one track",
                                null
                            )
                        } else if (
                            startIndex < 0 ||
                            startIndex >= rawTracks.size
                        ) {
                            result.error(
                                "INVALID_ARGUMENT",
                                "startIndex is outside the playlist",
                                null
                            )
                        } else {
                            val items = mutableListOf<
                                androidx.media3.common.MediaItem
                            >()

                            var validationError: String? = null

                            for (rawTrack in rawTracks) {
                                val track = rawTrack as? Map<*, *>
                                val uri = track?.get("uri") as? String
                                val title = track?.get("title") as? String
                                val artist = track?.get("artist") as? String

                                if (uri.isNullOrBlank()) {
                                    validationError =
                                        "Every track must have a non-empty uri"
                                    break
                                }

                                val item =
                                    androidx.media3.common.MediaItem.Builder()
                                        .setUri(uri)
                                        .setMediaMetadata(
                                            androidx.media3.common.MediaMetadata
                                                .Builder()
                                                .setTitle(
                                                    title ?: "Unknown title"
                                                )
                                                .setArtist(
                                                    artist ?: "Unknown artist"
                                                )
                                                .build()
                                        )
                                        .build()

                                items.add(item)
                            }

                            if (validationError != null) {
                                result.error(
                                    "INVALID_ARGUMENT",
                                    validationError,
                                    null
                                )
                            } else {
                                controller.setMediaItems(
                                    items,
                                    startIndex,
                                    0L
                                )
                                controller.prepare()
                                result.success(null)
                            }
                        }
                    }
                }


                "getSnapshot" -> {
                    if (controller == null) {
                        result.error("NOT_CONNECTED", "Player is not connected", null)
                    } else {
                        result.success(snapshot(controller))
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun connectToPlaybackService(result: MethodChannel.Result) {
        mediaController?.let {
            result.success(snapshot(it))
            return
        }

        if (controllerFuture != null) {
            result.error("CONNECTING", "Player connection is already in progress", null)
            return
        }

        val token = SessionToken(
            applicationContext,
            ComponentName(applicationContext, PlaybackService::class.java)
        )

        val future = MediaController.Builder(applicationContext, token).buildAsync()
        controllerFuture = future

        future.addListener({
            try {
                val controller = future.get()
                mediaController = controller
                controller.addListener(playerListener)
                result.success(snapshot(controller))
            } catch (exception: Exception) {
                controllerFuture = null
                result.error(
                    "CONNECTION_FAILED",
                    exception.message ?: "Unable to connect to playback service",
                    null
                )
            }
        }, mainExecutor)
    }

    private val playerListener = object : Player.Listener {
    override fun onEvents(
        player: Player,
        events: Player.Events
    ) {
        emitSnapshot()
    }
}

    private fun snapshot(controller: MediaController): Map<String, Any> {
        return mapOf(
            "isPlaying" to controller.isPlaying,
            "playbackState" to controller.playbackState,
            "positionMs" to controller.currentPosition.coerceAtLeast(0L),
            "durationMs" to controller.duration.coerceAtLeast(0L),
            "title" to (controller.mediaMetadata.title?.toString() ?: ""),
            "artist" to (controller.mediaMetadata.artist?.toString() ?: "")
        )
    }

    private fun emitSnapshot() {
        val controller = mediaController ?: return
        eventSink?.success(snapshot(controller))
    }

    override fun onDestroy() {
        mediaController?.removeListener(playerListener)
        mediaController = null

        controllerFuture?.let {
            MediaController.releaseFuture(it)
        }
        controllerFuture = null

        eventChannel?.setStreamHandler(null)
        eventChannel = null
        eventSink = null

        super.onDestroy()
    }
}
