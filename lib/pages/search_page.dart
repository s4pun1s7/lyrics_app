import 'package:flutter/material.dart';
import '../style.dart';

class SearchPage extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> toggleTheme;
  final String artist;
  final String song;
  final List<String> artistSuggestions;
  final List<String> songSuggestions;
  final ValueChanged<String> onArtistChanged;
  final ValueChanged<String> onSongChanged;
  final ValueChanged<String> onArtistSuggestionTap;
  final ValueChanged<String> onSongSuggestionTap;
  final VoidCallback onSearch;
  final VoidCallback onGoToSaves;
  final TextEditingController artistController;
  final TextEditingController songController;

  const SearchPage({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.artist,
    required this.song,
    required this.artistSuggestions,
    required this.songSuggestions,
    required this.onArtistChanged,
    required this.onSongChanged,
    required this.onArtistSuggestionTap,
    required this.onSongSuggestionTap,
    required this.onSearch,
    required this.onGoToSaves,
    required this.artistController,
    required this.songController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Artist'),
            style: kSuggestionStyle,
            onChanged: onArtistChanged,
            controller: artistController,
          ),
          if (artistSuggestions.isNotEmpty)
            ...artistSuggestions.map(
              (suggestion) => ListTile(
                title: Text(suggestion, style: kSuggestionStyle),
                onTap: () => onArtistSuggestionTap(suggestion),
              ),
            ),
          TextField(
            decoration: InputDecoration(labelText: 'Song Title'),
            style: kSuggestionStyle,
            onChanged: onSongChanged,
            controller: songController,
          ),
          if (songSuggestions.isNotEmpty)
            ...songSuggestions.map(
              (suggestion) => ListTile(
                title: Text(suggestion, style: kSuggestionStyle),
                onTap: () => onSongSuggestionTap(suggestion),
              ),
            ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onSearch,
                child: Text('Search Lyrics'),
                style: kButtonStyle,
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: onGoToSaves,
                child: Text('Saved'),
                style: kButtonStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
