import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'style.dart';
import 'pages/search_page.dart';
import 'pages/lyrics_page.dart';
import 'pages/saved_page.dart';
import 'api/suggestions_api.dart';
import 'api/album_art_api.dart';
import 'api/lyrics_api.dart';
import 'models/saved_song.dart';

void main() => runApp(LyricsApp());

class LyricsApp extends StatefulWidget {
  @override
  _LyricsAppState createState() => _LyricsAppState();
}

class _LyricsAppState extends State<LyricsApp> {
  bool _isDarkMode = true;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyrics Finder',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: LyricsHomePage(isDarkMode: _isDarkMode, toggleTheme: _toggleTheme),
    );
  }
}

class LyricsHomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> toggleTheme;

  LyricsHomePage({required this.isDarkMode, required this.toggleTheme});

  @override
  _LyricsHomePageState createState() => _LyricsHomePageState();
}

class _LyricsHomePageState extends State<LyricsHomePage> {
  String _artist = '';
  String _song = '';
  String _lyrics = '';
  String? _albumArtUrl;
  List<String> _artistSuggestions = [];
  List<String> _songSuggestions = [];
  final PageController _pageController = PageController();
  List<SavedSong> _savedSongs = [];
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _songController = TextEditingController();
  Timer? _artistDebounce;
  Timer? _songDebounce;

  Future<void> _onSearch() async {
    try {
      final lyrics = await fetchLyrics(_artist, _song);
      final artUrl = await fetchAlbumArt(_artist, _song);
      setState(() {
        _lyrics = lyrics;
        _albumArtUrl = artUrl;
      });
      _pageController.animateToPage(
        1,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to fetch lyrics or album art. Please try again.',
          ),
        ),
      );
    }
  }

  void _onSave() {
    if (_artist.isNotEmpty && _song.isNotEmpty && _lyrics.isNotEmpty) {
      setState(() {
        _savedSongs.add(
          SavedSong(
            artist: _artist,
            song: _song,
            lyrics: _lyrics,
            albumArtUrl: _albumArtUrl,
          ),
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved!')));
    }
  }

  void _goToSaves() {
    _pageController.animateToPage(
      2,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToSearch() {
    _pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _artistDebounce?.cancel();
    _songDebounce?.cancel();
    _artistController.dispose();
    _songController.dispose();
    super.dispose();
  }

  void _onArtistChanged(String val) {
    _artist = val.trim();
    if (_artistDebounce?.isActive ?? false) _artistDebounce!.cancel();
    _artistDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final suggestions = await fetchSuggestions(_artist, 'musicArtist');
        setState(() {
          _artistSuggestions = suggestions;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch artist suggestions.')),
        );
      }
    });
  }

  void _onArtistSuggestionTap(String suggestion) async {
    setState(() {
      _artist = suggestion;
      _artistController.text = suggestion;
      _artistSuggestions = [];
    });
    // Fetch song suggestions for the selected artist
    try {
      final suggestions = await fetchSuggestions(_artist, 'song');
      setState(() {
        _songSuggestions = suggestions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch song suggestions for artist.')),
      );
    }
  }

  void _onSongChanged(String val) {
    _song = val.trim();
    if (_songDebounce?.isActive ?? false) _songDebounce!.cancel();
    _songDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        // If artist is set, include it in the query for more relevant suggestions
        final query = _artist.isNotEmpty ? '$_artist $_song' : _song;
        final suggestions = await fetchSuggestions(query, 'song');
        setState(() {
          _songSuggestions = suggestions;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch song suggestions.')),
        );
      }
    });
  }

  void _onSongSuggestionTap(String suggestion) {
    setState(() {
      _song = suggestion;
      _songController.text = suggestion;
      _songSuggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lyrics Finder', style: kTitleStyle)),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          // Page 1: Search
          SearchPage(
            isDarkMode: widget.isDarkMode,
            toggleTheme: widget.toggleTheme,
            artist: _artist,
            song: _song,
            artistSuggestions: _artistSuggestions,
            songSuggestions: _songSuggestions,
            onArtistChanged: _onArtistChanged,
            onSongChanged: _onSongChanged,
            onArtistSuggestionTap: _onArtistSuggestionTap,
            onSongSuggestionTap: _onSongSuggestionTap,
            onSearch: _onSearch,
            onGoToSaves: _goToSaves,
            artistController: _artistController,
            songController: _songController,
          ),
          // Page 2: Lyrics & Album Art
          LyricsPage(
            artist: _artist,
            song: _song,
            lyrics: _lyrics,
            albumArtUrl: _albumArtUrl,
            onBackToSearch: _goToSearch,
            onSave: _onSave,
          ),
          // Page 3: Saved Songs (moved to its own widget)
          SavedPage(savedSongs: _savedSongs, onBackToSearch: _goToSearch),
        ],
      ),
    );
  }
}
