# Premium Audio Player

A premium Android music player built with **Flutter and native AndroidX Media3**. The project aims to combine a polished dark interface with reliable local audio playback, queue management, and advanced audio features.

> **Project status: Work in Progress**
>
> Core playback integration and the initial player interface are under development. Some playback controls and planned features are not yet complete.

## Features

### Implemented or under development

- Dark interface with an amber accent color.
- Centralized color palette, typography, and Material theme.
- Native Android playback using AndroidX Media3 ExoPlayer.
- Media session integration through `MediaSessionService`.
- Flutter-to-native communication using MethodChannel and EventChannel.
- Audio file selection using `file_picker`.
- Playback controls for play, pause, stop, and seeking.
- Playback progress updates.
- Queue state management using Riverpod.
- Multiple audio file selection and native playlist loading.
- Shuffle and repeat mode state management.
- Initial Previous and Next navigation integration.

**Note:** Implementation does not necessarily mean a feature is fully tested. Queue navigation, automatic track transitions, repeat and shuffle behavior, background playback, and media-session integration require further verification and refinement.

## Planned Features

- Complete local music library and audio file browsing.
- Track metadata and album artwork.
- Persistent playlists and queue management.
- Reliable Previous and Next controls, including Bluetooth headset controls.
- Correct Repeat Off, Repeat All, and Repeat One behavior.
- Shuffle with consistent queue ordering.
- Background playback and lock-screen controls.
- Playback notification with media controls.
- Equalizer and audio effects.
- Direct playback and enhanced audio modes.
- Improved audio format compatibility and error handling.
- Additional library, playlist, and audio settings screens.
- Improved accessibility and production-level testing.

These are development goals, not claims about currently available functionality.

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI framework |
| Dart | Application logic |
| Kotlin | Native Android integration |
| AndroidX Media3 ExoPlayer | Native audio playback |
| AndroidX Media3 MediaSession | Playback session and media controls |
| Riverpod | Application state management |
| MethodChannel | Flutter-to-Android commands |
| EventChannel | Native playback state updates |
| file_picker | Selecting local audio files |

## Architecture

The application separates the Flutter interface from the native playback engine.

```text
Flutter UI
    |
    v
Riverpod State Management
    |
    v
Playback Queue Service
    |
    v
Native Playback Bridge
    |
    | MethodChannel / EventChannel
    v
MainActivity.kt
    |
    v
PlaybackService.kt
    |
    v
Media3 ExoPlayer
    |
    v
Android Audio Output
```

### Project Structure

```text
premium_audio_player/
├── android/
│   └── app/
│       └── src/main/kotlin/
│           └── com/sumanaswal/premium_audio_player/
│               ├── MainActivity.kt
│               └── PlaybackService.kt
├── lib/
│   ├── app/
│   │   └── app.dart
│   ├── core/
│   │   ├── playback/
│   │   │   └── native_playback_bridge.dart
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       ├── app_text_styles.dart
│   │       └── app_theme.dart
│   ├── features/
│   │   └── player/
│   │       ├── models/
│   │       │   └── audio_track.dart
│   │       ├── providers/
│   │       │   ├── playback_queue_provider.dart
│   │       │   └── playback_queue_service_provider.dart
│   │       ├── services/
│   │       │   └── playback_queue_service.dart
│   │       └── now_playing_screen.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

This structure represents the current development organization. Files and responsibilities may change as the application evolves.

## Requirements

- Flutter SDK compatible with the project's configured version.
- Dart SDK compatible with the Flutter SDK.
- Android SDK and Android build tools.
- Java 17.
- A physical Android device or compatible Android emulator.

The current application targets Android. Other platforms are not currently supported by the native playback implementation.

## Getting Started

### 1. Clone the repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd premium_audio_player
```

Replace the placeholder with your actual GitHub repository URL.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Check the development environment

```bash
flutter doctor
flutter analyze
```

Resolve any blocking environment or compilation errors before continuing.

### 4. Connect an Android device

Enable Developer Options and USB debugging on your Android device, connect it to your computer, and verify that Flutter detects it:

```bash
flutter devices
```

### 5. Run the application

```bash
flutter run
```

For a release APK build:

```bash
flutter build apk --release
```

The release build should be tested on a physical device before distribution.

## Development Notes

### Native playback

The Android playback engine uses Media3 ExoPlayer, exposed through a native playback service. Flutter sends playback commands through a MethodChannel and receives playback snapshots through an EventChannel.

### Audio file access

The application uses `file_picker` to select audio files. File URI handling can vary by Android storage provider, so compatibility should be tested with different file sources and audio formats.

### Queue and playback behavior

The queue state is managed in Dart with Riverpod, while the actual media playlist is managed by Media3. These two layers must remain synchronized.

Repeat and shuffle settings, manual track navigation, automatic track transitions, and external media controls require coordinated behavior between the Flutter state layer and the native player.

### Audio quality

Using ExoPlayer provides a native playback foundation, but it does **not** automatically guarantee bit-perfect output or lossless delivery to every audio device. Direct playback, DSP processing, sample-rate handling, and external DAC behavior require separate implementation and testing.

## Current Limitations

- The user interface is still evolving.
- Library scanning and persistent playlists are not yet complete.
- Some queue controls are under development.
- Metadata and artwork handling require further work.
- Advanced equalization and DSP are planned.
- Background playback and external controls require additional verification.
- Production readiness has not yet been established.

## Roadmap

- [x] Establish the Flutter project foundation.
- [x] Integrate native Media3 playback.
- [x] Create the initial Now Playing interface.
- [x] Centralize colors, typography, and theme.
- [x] Add initial queue and playback state models.
- [ ] Complete native queue navigation.
- [ ] Verify shuffle and repeat behavior.
- [ ] Build the local music library.
- [ ] Add persistent playlists and metadata.
- [ ] Verify notification and lock-screen controls.
- [ ] Implement equalizer and audio enhancements.
- [ ] Complete device testing and release preparation.

## Contributing

This is an actively developed personal project. Suggestions, bug reports, and technical feedback are welcome.

Before submitting changes:

1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Test playback changes on an Android device.
4. Document any known limitations.

## License

No license has been selected yet. Unless a license is added to the repository, the project should not be assumed to permit redistribution, modification, or commercial use.

---

**Premium Audio Player** — building a refined local music playback experience with Flutter and native Android audio technology.