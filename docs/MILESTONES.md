# Milestones and exit criteria

## M0 — Specification and design lock
Exit: all 14 mockup screens, navigation and behavior requirements approved.

## M1 — Project foundation (current)
- Create the Flutter Android project using the local SDK.
- Add Riverpod and analyzer configuration.
- Establish the app shell, logging boundary, test structure and architecture notes.
- Validate dependency resolution, analysis, tests and debug build on the user's machine.
Exit: all four local commands complete successfully; Android project builds reproducibly.

## M2 — Native playback proof of concept
- Kotlin Media3 ExoPlayer and MediaSessionService.
- Typed platform-channel contract and playback state mapping.
- Validate local MP3/FLAC/WAV/AAC sample files and background playback.
Exit: device playback, media controls and interruptions pass tests.

## M3 — UI implementation
- Implement approved mockup screens and navigation.
Exit: screen-level visual and interaction acceptance criteria pass.

## M4 — Library and persistence
- MediaStore, metadata, artwork, search, queue, favorites and playlists.
Exit: large-library and missing-file cases pass.

## M5 — Enhanced audio
- EQ, presets, processor chain, ReplayGain and clipping protection.
Exit: DSP behavior and persisted settings validated.

## M6 — Direct output and USB DAC
- Probe output capabilities and investigate device-specific support.
Exit: supported paths verified; unsupported paths reported accurately.

## M7 — Production hardening
- Lifecycle, memory, performance, interruption, device compatibility and release checks.
Exit: release checklist passes and a signed build is produced.
