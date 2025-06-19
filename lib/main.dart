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
import 'package:shared_preferences/shared_preferences.dart';

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
  int _selectedIndex = 0;
  List<String> _searchHistory = [];
  SavedSong? _selectedSavedSong;

  @override
  void initState() {
    super.initState();
    _loadSavedSongs();
    _loadSearchHistory();
  }

  Future<void> _loadSavedSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_songs');
    if (saved != null) {
      setState(() {
        _savedSongs = SavedSong.decodeList(saved);
      });
    }
  }

  Future<void> _saveSongs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_songs', SavedSong.encodeList(_savedSongs));
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  void _addToSearchHistory(String artist, String song) {
    final entry = '$artist - $song';
    setState(() {
      _searchHistory.remove(entry);
      _searchHistory.insert(0, entry);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    _saveSearchHistory();
  }

  Future<void> _onSearch() async {
    try {
      final lyrics = await fetchLyrics(_artist, _song);
      final artUrl = await fetchAlbumArt(_artist, _song);
      setState(() {
        _lyrics = lyrics;
        _albumArtUrl = artUrl;
      });
      _addToSearchHistory(_artist, _song);
      _saveSongs();
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
      // Remove any existing save with the same artist and song
      _savedSongs.removeWhere(
        (s) =>
            s.artist.toLowerCase() == _artist.toLowerCase() &&
            s.song.toLowerCase() == _song.toLowerCase(),
      );
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
      _saveSongs();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved!')));
    }
  }

  bool get _isCurrentLyricsSaved {
    return _savedSongs.any((s) =>
      s.artist.toLowerCase() == _artist.toLowerCase() &&
      s.song.toLowerCase() == _song.toLowerCase()
    );
  }

  void _onUnsave() {
    setState(() {
      _savedSongs.removeWhere((s) =>
        s.artist.toLowerCase() == _artist.toLowerCase() &&
        s.song.toLowerCase() == _song.toLowerCase()
      );
    });
    _saveSongs();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed from saved!')),
    );
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

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onSelectSavedSong(SavedSong song) {
    setState(() {
      _selectedSavedSong = song;
      _artist = song.artist;
      _song = song.song;
      _lyrics = song.lyrics;
      _albumArtUrl = song.albumArtUrl;
      _artistController.text = song.artist;
      _songController.text = song.song;
    });
    _pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lyrics Finder', style: kTitleStyle),
        actions: [
          Row(
            children: [
              Text('Dark Mode', style: kSuggestionStyle),
              Switch(value: widget.isDarkMode, onChanged: widget.toggleTheme),
              SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Menu bar above the search area
          Container(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MenuButton(
                  label: 'Search',
                  selected: _selectedIndex == 0,
                  onTap: () => _onMenuTap(0),
                ),
                _MenuButton(
                  label: 'Lyrics',
                  selected: _selectedIndex == 1,
                  onTap: () => _onMenuTap(1),
                ),
                _MenuButton(
                  label: 'Saved',
                  selected: _selectedIndex == 2,
                  onTap: () => _onMenuTap(2),
                ),
              ],
            ),
          ),
          // Centralize the page content
          Expanded(
            child: Center(
              child: SizedBox(
                width: 500, // or MediaQuery for responsiveness
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: [
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
                    LyricsPage(
                      artist: _artist,
                      song: _song,
                      lyrics: _lyrics,
                      albumArtUrl: _albumArtUrl,
                      onSave: _onSave,
                      onUnsave: _onUnsave,
                      isSaved: _isCurrentLyricsSaved,
                    ),
                    SavedPage(
                      savedSongs: _savedSongs,
                      onSelectSong: _onSelectSavedSong,
                      onBackToSearch: _goToSearch,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
