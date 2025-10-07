class AudioTrack {
  final String title;
  final String src;
  final String author;
  final String audioTitle;
  final String durationText;
  final int duration;
  final int playCount;

  AudioTrack({
    required this.title,
    required this.src,
    required this.author,
    String? audioTitle,
    required this.durationText,
    required this.duration,
    this.playCount = 0,
  }) : audioTitle = audioTitle ?? title; // default to title if null
}



class Artist {
  final String name;
  final List<AudioTrack> audios;

  Artist({required this.name, required this.audios});
}
