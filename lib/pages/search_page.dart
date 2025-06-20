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
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Padding(
      padding: kPagePadding,
      child: isWide
          ? SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(labelText: 'Artist'),
                          style: kSuggestionStyle,
                          onChanged: onArtistChanged,
                          controller: artistController,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Song Title'),
                          style: kSuggestionStyle,
                          onChanged: onSongChanged,
                          controller: songController,
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
                  ),
                  VerticalDivider(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (artistSuggestions.isNotEmpty) ...[
                          Text('Artist Suggestions', style: kTitleStyle),
                          ...artistSuggestions.map(
                            (suggestion) => ListTile(
                              title: Text(suggestion, style: kSuggestionStyle),
                              onTap: () => onArtistSuggestionTap(suggestion),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        if (songSuggestions.isNotEmpty) ...[
                          Text('Song Suggestions', style: kTitleStyle),
                          ...songSuggestions.map(
                            (suggestion) => ListTile(
                              title: Text(suggestion, style: kSuggestionStyle),
                              onTap: () => onSongSuggestionTap(suggestion),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Artist'),
                    style: kSuggestionStyle,
                    onChanged: onArtistChanged,
                    controller: artistController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Song Title'),
                    style: kSuggestionStyle,
                    onChanged: onSongChanged,
                    controller: songController,
                  ),
                  if (artistSuggestions.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text('Artist Suggestions', style: kTitleStyle),
                    ...artistSuggestions.map(
                      (suggestion) => ListTile(
                        title: Text(suggestion, style: kSuggestionStyle),
                        onTap: () => onArtistSuggestionTap(suggestion),
                      ),
                    ),
                  ],
                  if (songSuggestions.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text('Song Suggestions', style: kTitleStyle),
                    ...songSuggestions.map(
                      (suggestion) => ListTile(
                        title: Text(suggestion, style: kSuggestionStyle),
                        onTap: () => onSongSuggestionTap(suggestion),
                      ),
                    ),
                  ],
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
            ),
    );
  }
}
