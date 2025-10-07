import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio.dart';

class PlayerProvider extends ChangeNotifier {
  final _player = AudioPlayer();
  Artist? selectedArtist;
  int? currentIndex;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  // --- For showing user feedback (error messages)
  String? errorMessage;

  AudioTrack? get currentTrack {
    if (selectedArtist == null || currentIndex == null) return null;
    return selectedArtist!.audios[currentIndex!];
  }

  void selectArtist(Artist artist) {
    selectedArtist = artist;
    currentIndex = null;
    isPlaying = false;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> playTrack(int index) async {
    if (selectedArtist == null) return;

    currentIndex = index;
    final track = selectedArtist!.audios[index];
    errorMessage = null;
    notifyListeners();

    try {
      // Try to set the URL safely
      await _player.setUrl(track.src);
      _player.play();
      isPlaying = true;

      _player.positionStream.listen((pos) {
        position = pos;
        notifyListeners();
      });
      _player.durationStream.listen((dur) {
        if (dur != null) duration = dur;
        notifyListeners();
      });
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          nextSong();
        }
      });
    } catch (e) {
      // Something went wrong with the URL
      isPlaying = false;
      errorMessage = "⚠️ Bu aýdyma goýmakda näsazlyk boldy. URL adresi nädogry ýa-da elýeterli däl.";
      debugPrint("Audio error: $e");
    }

    notifyListeners();
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
      isPlaying = false;
    } else {
      _player.play();
      isPlaying = true;
    }
    notifyListeners();
  }

  void seek(Duration pos) {
    _player.seek(pos);
  }

  void nextSong() {
    if (selectedArtist != null && currentIndex != null) {
      int next = currentIndex! + 1;
      if (next < selectedArtist!.audios.length) {
        playTrack(next);
      }
    }
  }

  void prevSong() {
    if (selectedArtist != null && currentIndex != null) {
      int prev = currentIndex! - 1;
      if (prev >= 0) {
        playTrack(prev);
      }
    }
  }
}
