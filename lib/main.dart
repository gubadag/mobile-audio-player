import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/audios.dart';
import 'providers/player_provider.dart';
import 'debug/url_tester.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await UrlTester.testAllUrls();
  runApp(
    ChangeNotifierProvider(
      create: (_) => PlayerProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artist Library',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const ArtistListScreen(),
    );
  }
}

class ArtistListScreen extends StatefulWidget {
  const ArtistListScreen({super.key});

  @override
  State<ArtistListScreen> createState() => _ArtistListScreenState();
}

class _ArtistListScreenState extends State<ArtistListScreen>
    with SingleTickerProviderStateMixin {
  bool sidebarOpen = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void toggleSidebar() {
    setState(() {
      sidebarOpen = !sidebarOpen;
      if (sidebarOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void selectArtistAndCloseSidebar(PlayerProvider player, artist) {
    player.selectArtist(artist);
    if (sidebarOpen) toggleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          player.selectedArtist == null
              ? "🎧 Artist Library"
              : player.selectedArtist!.name,
        ),
        actions: [
          if (player.selectedArtist != null)
            IconButton(
              icon: Icon(sidebarOpen ? Icons.close : Icons.menu),
              onPressed: toggleSidebar,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main content area
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: player.selectedArtist == null
                ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: artists.length,
              itemBuilder: (context, i) {
                final artist = artists[i];
                return GestureDetector(
                  onTap: () => player.selectArtist(artist),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: const AssetImage(
                              'assets/images/artist.png'),
                          radius: 36,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          artist.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.indigo.shade100,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "${player.selectedArtist!.name}'s Songs",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (player.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      player.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: player.selectedArtist!.audios.length,
                    itemBuilder: (context, i) {
                      final song = player.selectedArtist!.audios[i];
                      return ListTile(
                        title: Text(song.title),
                        subtitle: Text(song.author),
                        trailing: IconButton(
                          icon: Icon(
                            player.currentIndex == i && player.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onPressed: () => player.playTrack(i),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Sliding Sidebar
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: 220,
              color: Colors.indigo.shade50,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.indigo.shade100,
                    child: const Text(
                      "Artists",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        for (var artist in artists)
                          Card(
                            color: player.selectedArtist == artist
                                ? Colors.indigo.shade100
                                : Colors.white,
                            child: ListTile(
                              title: Text(artist.name),
                              onTap: () =>
                                  selectArtistAndCloseSidebar(player, artist),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom player
      bottomNavigationBar: player.currentTrack == null
          ? null
          : Container(
        color: Colors.indigo.shade700,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player.currentTrack!.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: player.position.inSeconds
                  .clamp(0, player.duration.inSeconds)
                  .toDouble(),
              max: player.duration.inSeconds.toDouble(),
              onChanged: (val) =>
                  player.seek(Duration(seconds: val.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: player.prevSong,
                ),
                IconButton(
                  color: Colors.white,
                  icon: Icon(
                    player.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                  ),
                  iconSize: 48,
                  onPressed: player.togglePlayPause,
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.skip_next),
                  onPressed: player.nextSong,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
