import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/player/now_playing_screen.dart';

class PremiumAudioPlayerApp extends StatelessWidget {
  const PremiumAudioPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Audio Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const NowPlayingScreen(),
    );
  }
}
