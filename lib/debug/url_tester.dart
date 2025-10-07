import 'package:http/http.dart' as http;
import '../data/audios.dart';

/// Simple URL tester for your MP3 links.
/// This file is optional & can be deleted after testing.
class UrlTester {
  static Future<void> testAllUrls() async {
    print('🎧 Starting MP3 URL test...\n');

    for (final artist in artists) {
      print('👤 Checking artist: ${artist.name}');
      for (final track in artist.audios) {
        final url = track.src;
        try {
          final response = await http.head(Uri.parse(url));

          if (response.statusCode == 200) {
            print('✅ ${track.title} → OK (200)');
          } else {
            print('❌ ${track.title} → ERROR ${response.statusCode}');
          }
        } catch (e) {
          print('⚠️ ${track.title} → FAILED ($e)');
        }
      }
      print('---------------------------\n');
    }

    print('✅ URL test finished.');
  }
}

