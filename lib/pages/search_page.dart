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

  // If you want to support artist-song dropdowns, add these parameters:
  final List<Map<String, String>> artistSongResults;
  final bool showArtistSongDropdown;
  final ValueChanged<Map<String, String>> onArtistSongDropdownSelect;

  const SearchPage({
    super.key,
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
    this.artistSongResults = const [],
    this.showArtistSongDropdown = false,
    required this.onArtistSongDropdownSelect,
  });

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
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  children: artistSuggestions
                      .map(
                        (suggestion) => ListTile(
                          title: Text(suggestion, style: kSuggestionStyle),
                          onTap: () => onArtistSuggestionTap(suggestion),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          TextField(
            decoration: InputDecoration(labelText: 'Song Title'),
            style: kSuggestionStyle,
            onChanged: onSongChanged,
            controller: songController,
          ),
          if (songSuggestions.isNotEmpty)
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  children: songSuggestions
                      .map(
                        (suggestion) => ListTile(
                          title: Text(suggestion, style: kSuggestionStyle),
                          onTap: () => onSongSuggestionTap(suggestion),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          // If you want to show the artist-song dropdown:
          if (showArtistSongDropdown && artistSongResults.isNotEmpty)
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  children: artistSongResults
                      .map(
                        (result) => ListTile(
                          title: Text(
                            '${result['artist']} - ${result['song']}',
                            style: kSuggestionStyle,
                          ),
                          onTap: () => onArtistSongDropdownSelect(result),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: kButtonStyle,
                onPressed: onSearch,
                child: Text('Search Lyrics'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                style: kButtonStyle,
                onPressed: onGoToSaves,
                child: Text('Saved'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
