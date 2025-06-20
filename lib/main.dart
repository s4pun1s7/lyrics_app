import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'style.dart';
import 'pages/search_page.dart';
import 'pages/lyrics_page.dart';
import 'pages/saved_page.dart';
import 'pages/settings_page.dart';
import 'api/suggestions_api.dart';
import 'api/album_art_api.dart';
import 'api/lyrics_api.dart'; // Make sure fetchLyrics is exported from this file.
import 'models/saved_song.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const LyricsApp());
}

class LyricsApp extends StatefulWidget {
  const LyricsApp({super.key});
  @override
  LyricsAppState createState() => LyricsAppState();
}

class LyricsAppState extends State<LyricsApp> {
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

  const LyricsHomePage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  LyricsHomePageState createState() => LyricsHomePageState();
}

class LyricsHomePageState extends State<LyricsHomePage> {
  String _artist = '';
  String _song = '';
  String _lyrics = '';
  String? _albumArtUrl;
  AlbumArtResult? _albumArtResult;
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
  String _fontFamily = 'monospace';
  double _fontSize = 16.0;
  double _lineHeight = 1.2;
  List<Map<String, String>> _recentLyrics = [];
  TextAlign _textAlign = TextAlign.left;
  List<Map<String, String>> _artistSongResults = [];
  bool _showArtistSongDropdown = false;

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
    // If only artist is present, show 10-15 songs by that artist
    if (_artist.isNotEmpty && _song.isEmpty) {
      return;
    }
    // If only song is present, show matching artists with that song title
    if (_song.isNotEmpty && _artist.isEmpty) {
      return;
    }
    // Normal search
    try {
      final lyrics = await fetchLyrics(_artist, _song);
      final artResult = await fetchAlbumArt(_artist, _song);
      if (!mounted) return;
      setState(() {
        _lyrics = lyrics ?? '';
        _albumArtResult = artResult;
        _albumArtUrl = artResult?.artworkUrl;
        if (_artist.isNotEmpty && _song.isNotEmpty && _lyrics.isNotEmpty) {
          _recentLyrics.removeWhere(
            (item) => item['artist'] == _artist && item['song'] == _song,
          );
          _recentLyrics.insert(0, {
            'artist': _artist,
            'song': _song,
            'lyrics': _lyrics,
            'albumArtUrl': _albumArtUrl ?? '',
          });
          if (_recentLyrics.length > 5) {
            _recentLyrics = _recentLyrics.sublist(0, 5);
          }
        }
      });
      _addToSearchHistory(_artist, _song);
      _saveSongs();
      _pageController.animateToPage(
        1,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to fetch lyrics or album art. Please try again.',
          ),
        ),
      );
    }
  }

  Future<List<Map<String, String>>> fetchSongsByArtist(
    String artist, {
    int limit = 15,
  }) async {
    final url = Uri.parse(
      'https://itunes.apple.com/search?term=${Uri.encodeComponent(artist)}&entity=song&limit=$limit',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, String>>.from(
        (data['results'] as List).map(
          (item) => {'artist': item['artistName'], 'song': item['trackName']},
        ),
      );
    }
    return [];
  }

  Future<List<Map<String, String>>> fetchArtistsBySong(
    String song, {
    int limit = 15,
  }) async {
    final url = Uri.parse(
      'https://itunes.apple.com/search?term=${Uri.encodeComponent(song)}&entity=song&limit=$limit',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, String>>.from(
        (data['results'] as List).map(
          (item) => {'artist': item['artistName'], 'song': item['trackName']},
        ),
      );
    }
    return [];
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
    return _savedSongs.any(
      (s) =>
          s.artist.toLowerCase() == _artist.toLowerCase() &&
          s.song.toLowerCase() == _song.toLowerCase(),
    );
  }

  void _onUnsave() {
    setState(() {
      _savedSongs.removeWhere(
        (s) =>
            s.artist.toLowerCase() == _artist.toLowerCase() &&
            s.song.toLowerCase() == _song.toLowerCase(),
      );
    });
    _saveSongs();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed from saved!')));
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

  void _updateArtistSongResults() async {
    if (_artist.isNotEmpty && _song.isNotEmpty) {
      final results = await fetchArtistsBySong(_song);
      setState(() {
        _artistSongResults = results
            .where(
              (item) =>
                  item['artist']!.toLowerCase().contains(
                    _artist.toLowerCase(),
                  ) ||
                  item['song']!.toLowerCase().contains(_song.toLowerCase()),
            )
            .toList();
        _showArtistSongDropdown = _artistSongResults.isNotEmpty;
      });
    } else {
      setState(() {
        _artistSongResults = [];
        _showArtistSongDropdown = false;
      });
    }
  }

  void _onArtistChanged(String val) {
    _artist = val.trim();
    if (_artistDebounce?.isActive ?? false) _artistDebounce!.cancel();
    _artistDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final suggestions = await fetchSuggestions(_artist, 'musicArtist');
        if (!mounted) return;
        setState(() {
          _artistSuggestions = suggestions;
        });
        _updateArtistSongResults();
      } catch (e) {
        if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _songSuggestions = suggestions;
      });
    } catch (e) {
      if (!mounted) return;
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
        final query = _artist.isNotEmpty ? '$_artist $_song' : _song;
        final suggestions = await fetchSuggestions(query, 'song');
        if (!mounted) return;
        setState(() {
          _songSuggestions = suggestions;
        });
        _updateArtistSongResults();
      } catch (e) {
        if (!mounted) return;
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

  void _onArtistSongDropdownSelect(Map<String, String> result) {
    setState(() {
      _artist = result['artist'] ?? '';
      _song = result['song'] ?? '';
      _artistController.text = _artist;
      _songController.text = _song;
      _showArtistSongDropdown = false;
      _artistSongResults = [];
    });
    _onSearch();
  }

  void _onMenuTap(int index) {
    if (index == 1 && (_artist.isEmpty || _song.isEmpty)) {
      // Show recent lyrics if lyrics page is tapped without a search
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Recent Lyrics'),
            content: _recentLyrics.isEmpty
                ? Text('No recent lyrics viewed.')
                : SizedBox(
                    width: 350,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _recentLyrics.length,
                      itemBuilder: (context, i) {
                        final item = _recentLyrics[i];
                        return ListTile(
                          title: Text('${item['artist']} - ${item['song']}'),
                          subtitle: Text(
                            item['lyrics'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() {
                              _artist = item['artist'] ?? '';
                              _song = item['song'] ?? '';
                              _lyrics = item['lyrics'] ?? '';
                              _albumArtUrl = item['albumArtUrl'];
                            });
                            Navigator.of(context).pop();
                            _pageController.animateToPage(
                              1,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onDeleteSong(SavedSong song) {
    setState(() {
      _savedSongs.remove(song);
    });
    _saveSongs();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deleted saved song.')));
  }

  void _onFontFamilyChanged(String family) {
    setState(() {
      _fontFamily = family;
    });
  }

  void _onFontSizeChanged(double size) {
    setState(() {
      _fontSize = size;
    });
  }

  void _onLineHeightChanged(double height) {
    setState(() {
      _lineHeight = height;
    });
  }

  void _onTextAlignChanged(TextAlign align) {
    setState(() {
      _textAlign = align;
    });
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
            color: Theme.of(
              context,
            ).colorScheme.secondary.withAlpha((0.1 * 255).toInt()),
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
                _MenuButton(
                  label: 'Settings',
                  selected: _selectedIndex == 3,
                  onTap: () => _onMenuTap(3),
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
                      artistSongResults: _artistSongResults,
                      showArtistSongDropdown: _showArtistSongDropdown,
                      onArtistSongDropdownSelect: _onArtistSongDropdownSelect,
                    ),
                    LyricsPage(
                      artist: _artist,
                      song: _song,
                      lyrics: _lyrics,
                      albumArtUrl: _albumArtUrl,
                      onSave: _onSave,
                      onUnsave: _onUnsave,
                      isSaved: _isCurrentLyricsSaved,
                      fontFamily: _fontFamily,
                      fontSize: _fontSize,
                      lineHeight: _lineHeight,
                      textAlign: _textAlign,
                      sourceUrl: _albumArtResult?.trackViewUrl,
                      spotifyUrl: _albumArtResult?.spotifyUrl,
                    ),
                    SavedPage(
                      savedSongs: _savedSongs,
                      onBackToSearch: _goToSearch,
                      onDeleteSong: _onDeleteSong,
                    ),
                    SettingsPage(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.toggleTheme,
                      fontFamily: _fontFamily,
                      fontSize: _fontSize,
                      lineHeight: _lineHeight,
                      onFontFamilyChanged: _onFontFamilyChanged,
                      onFontSizeChanged: _onFontSizeChanged,
                      onLineHeightChanged: _onLineHeightChanged,
                      textAlign: _textAlign,
                      onTextAlignChanged: _onTextAlignChanged,
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
