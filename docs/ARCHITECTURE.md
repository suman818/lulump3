# Architecture baseline

## Module boundaries

### Flutter app layer
Owns app lifecycle coordination, routing, feature state and the UI. Screens must not own a native player instance.

### Playback contract (planned)
A typed application-facing interface will expose:
- current media item and playback state
- position, duration and buffered position
- play / pause / seek / next / previous
- queue operations
- repeat and shuffle modes
- audio mode and supported capabilities
- errors and Android audio-device events

The implementation will be backed by a Kotlin Media3 `MediaSessionService`. The service owns the player lifecycle so playback continues when Flutter UI is backgrounded or destroyed.

### Library contract (planned)
A repository will abstract MediaStore discovery, metadata normalization, artwork, persisted user collections and missing-file reconciliation. Scanning and artwork work must not block the UI isolate.

### Audio modes (planned)
- Direct / Bit-perfect: app-level EQ and ReplayGain disabled; only report bit-perfect when the active route and implementation can verify it.
- Enhanced / DSP: supported PCM processor chain, EQ, ReplayGain and clipping protection.

Custom C++ DSP is not a default dependency. Evaluate it only if the required processing cannot be implemented reliably in Kotlin/Media3 or profiling justifies native code.

## Error model

Errors should be typed at the boundary (permission denied, file unavailable, unsupported format, output unavailable, playback failure, DSP configuration rejected). UI presentation should translate errors into actionable messages without leaking internal stack traces.

## Testing strategy

- Dart unit tests for state and mapping logic
- Flutter widget tests for screen states
- Kotlin unit tests for native adapters and DSP parameter validation
- Android integration tests for Media3 service lifecycle, focus and media session
- Manual device matrix for output routes, wired/USB/Bluetooth and long playback sessions
