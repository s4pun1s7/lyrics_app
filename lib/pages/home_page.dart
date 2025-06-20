import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';
import '../widgets/auth_widgets.dart';
import '../style.dart';
import '../models/saved_song.dart';
import '../api/suggestions_api.dart';
import '../api/album_art_api.dart';
import '../api/lyrics_api.dart';
import '../services/firebase_service.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_page.dart';
import 'lyrics_page.dart';
import 'saved_page.dart';
import 'settings_page.dart';

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
  final List<String> _artistSuggestions = [];
  final List<String> _songSuggestions = [];
  final PageController _pageController = PageController();
  final List<SavedSong> _savedSongs = [];
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _songController = TextEditingController();
  Timer? _artistDebounce;
  Timer? _songDebounce;
  int _selectedIndex = 0;
  final List<String> _searchHistory = [];
  String _fontFamily = 'monospace';
  double _fontSize = 16.0;
  double _lineHeight = 1.2;
  TextAlign _textAlign = TextAlign.left;
  String? _userId;
  StreamSubscription? _songsStream;
  String? _authProvider;
  User? _user;
  bool _isLoadingAuth = false;
  String? _authError;
  double _textAreaWidth = 400.0;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    setState(() => _isLoadingAuth = true);
    try {
      _user = FirebaseAuth.instance.currentUser;
      _userId = _user?.uid;
      _authProvider = _user?.providerData.isNotEmpty == true
          ? _user!.providerData[0].providerId
          : null;
      if (_user != null) {
        _listenToSavedSongs();
      }
    } catch (e) {
      _authError = e.toString();
    } finally {
      setState(() => _isLoadingAuth = false);
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoadingAuth = true);
    try {
      final user = await FirebaseService.signInWithGoogle();
      setState(() {
        _user = user;
        _userId = user?.uid;
        _authProvider = user?.providerData.isNotEmpty == true
            ? user!.providerData[0].providerId
            : null;
        _authError = null;
      });
      if (_user != null) {
        _listenToSavedSongs();
      }
    } catch (e) {
      setState(() => _authError = e.toString());
    } finally {
      setState(() => _isLoadingAuth = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoadingAuth = true);
    try {
      await FirebaseService.signOut();
      setState(() {
        _user = null;
        _userId = null;
        _authProvider = null;
        _savedSongs.clear();
        _authError = null;
      });
    } catch (e) {
      setState(() => _authError = e.toString());
    } finally {
      setState(() => _isLoadingAuth = false);
    }
  }

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  void _onArtistChanged(String value) {
    setState(() {
      _artistController.text = value;
      _artistController.selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      );
    });
    _debounceArtistSuggestions(value);
  }

  void _onSongChanged(String value) {
    setState(() {
      _songController.text = value;
      _songController.selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      );
    });
    _debounceSongSuggestions(value);
  }

  void _onArtistSuggestionTap(String suggestion) {
    _onArtistChanged(suggestion);
  }

  void _onSongSuggestionTap(String suggestion) {
    _onSongChanged(suggestion);
  }

  void _debounceArtistSuggestions(String value) {
    _artistDebounce?.cancel();
    _artistDebounce = Timer(const Duration(milliseconds: 300), () async {
      final suggestions = await fetchSuggestions(value, 'musicArtist');
      setState(() {
        _artistSuggestions.clear();
        _artistSuggestions.addAll(suggestions);
      });
    });
  }

  void _debounceSongSuggestions(String value) {
    _songDebounce?.cancel();
    _songDebounce = Timer(const Duration(milliseconds: 300), () async {
      final suggestions = await fetchSuggestions(
        _artistController.text,
        'song',
      );
      setState(() {
        _songSuggestions.clear();
        _songSuggestions.addAll(suggestions);
      });
    });
  }

  Future<void> _onSearch() async {
    setState(() {
      _lyrics = '';
      _albumArtUrl = null;
      _albumArtResult = null;
    });
    final lyrics =
        await fetchLyrics(_artistController.text, _songController.text) ?? '';
    final albumArt = await fetchAlbumArt(
      _artistController.text,
      _songController.text,
    );
    setState(() {
      _lyrics = lyrics;
      _albumArtResult = albumArt;
      _albumArtUrl = albumArt?.artworkUrl;
      _searchHistory.add('${_artistController.text} - ${_songController.text}');
    });
  }

  void _goToSaves() {
    _onMenuTap(2);
  }

  void _goToSearch() {
    _onMenuTap(0);
  }

  void _listenToSavedSongs() {
    _songsStream?.cancel();
    _songsStream = FirebaseService.getSongs(_userId!).listen((snapshot) {
      final docs = snapshot.docs;
      setState(() {
        _savedSongs.clear();
        _savedSongs.addAll(
          docs
              .map(
                (doc) =>
                    SavedSong.fromJson(doc.data()..['firebaseId'] = doc.id),
              )
              .toList(),
        );
      });
    });
  }

  Future<void> _onSave() async {
    if (_userId == null || _lyrics.isEmpty) return;
    final song = SavedSong(
      artist: _artistController.text,
      song: _songController.text,
      lyrics: _lyrics,
      albumArtUrl: _albumArtUrl,
      firebaseId: null,
    );
    await FirebaseService.saveSong(_userId!, song.toJson());
  }

  Future<void> _onUnsave() async {
    if (_userId == null) return;
    final match = _savedSongs.firstWhereOrNull(
      (s) =>
          s.artist == _artistController.text && s.song == _songController.text,
    );
    if (match?.firebaseId != null) {
      await FirebaseService.deleteSong(_userId!, match!.firebaseId!);
    }
  }

  bool get _isCurrentLyricsSaved {
    return _savedSongs.firstWhereOrNull(
          (s) =>
              s.artist == _artistController.text &&
              s.song == _songController.text,
        ) !=
        null;
  }

  Future<void> _onDeleteSong(SavedSong song) async {
    if (_userId == null || song.firebaseId == null) return;
    await FirebaseService.deleteSong(_userId!, song.firebaseId!);
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

  void _onOpenSavedSong(SavedSong song) {
    setState(() {
      _artist = song.artist;
      _song = song.song;
      _lyrics = song.lyrics;
      _albumArtUrl = song.albumArtUrl;
      // If you have AlbumArtResult, you can reconstruct it here if needed
      // _albumArtResult = ...
      _selectedIndex = 1; // Go to Lyrics page
      _pageController.jumpToPage(1);
    });
  }

  void _onTextAreaWidthChanged(double width) {
    setState(() {
      _textAreaWidth = width;
    });
  }

  @override
  void dispose() {
    _artistDebounce?.cancel();
    _songDebounce?.cancel();
    _pageController.dispose();
    _artistController.dispose();
    _songController.dispose();
    super.dispose();
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
              const SizedBox(width: 16),
              AuthButtons(
                isLoading: _isLoadingAuth,
                user: _user,
                authProvider: _authProvider,
                onSignIn: (_) => _signIn(),
                onSignOut: _signOut,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          AuthErrorBanner(error: _authError),
          Container(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withAlpha((0.1 * 255).toInt()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MenuButton(
                  label: 'Search',
                  selected: _selectedIndex == 0,
                  onTap: () => _onMenuTap(0),
                ),
                MenuButton(
                  label: 'Lyrics',
                  selected: _selectedIndex == 1,
                  onTap: () => _onMenuTap(1),
                ),
                MenuButton(
                  label: 'Saved',
                  selected: _selectedIndex == 2,
                  onTap: () => _onMenuTap(2),
                ),
                MenuButton(
                  label: 'Settings',
                  selected: _selectedIndex == 3,
                  onTap: () => _onMenuTap(3),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 500,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
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
                      fontFamily: _fontFamily,
                      fontSize: _fontSize,
                      lineHeight: _lineHeight,
                      textAlign: _textAlign,
                      sourceUrl: _albumArtResult?.trackViewUrl,
                      spotifyUrl: _albumArtResult?.spotifyUrl,
                      textAreaWidth: _textAreaWidth,
                    ),
                    SavedPage(
                      savedSongs: _savedSongs,
                      onBackToSearch: _goToSearch,
                      onDeleteSong: _onDeleteSong,
                      onOpenSong: _onOpenSavedSong,
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
                      textAreaWidth: _textAreaWidth,
                      onTextAreaWidthChanged: _onTextAreaWidthChanged,
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
