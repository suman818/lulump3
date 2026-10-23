import 'dart:developer' as developer;

/// Small logging boundary so production code does not call `print` directly.
///
/// Replace or extend this wrapper if structured logging / crash reporting is
/// introduced. Do not log private file paths or user content unnecessarily.
abstract final class AppLogger {
  static void debug(
    String message, {
    String name = 'PremiumAudioPlayer',
  }) {
    developer.log(message, name: name, level: 500);
  }

  static void info(
    String message, {
    String name = 'PremiumAudioPlayer',
  }) {
    developer.log(message, name: name, level: 800);
  }

  static void warning(
    String message, {
    String name = 'PremiumAudioPlayer',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(
    String message, {
    String name = 'PremiumAudioPlayer',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
