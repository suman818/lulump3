class AudioTrack {
  const AudioTrack({
    required this.id,
    required this.uri,
    required this.title,
    required this.artist,
  });

  final String id;
  final Uri uri;
  final String title;
  final String artist;
}
