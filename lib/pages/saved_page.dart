import 'package:flutter/material.dart';
import '../style.dart';
import '../models/saved_song.dart';

class SavedPage extends StatelessWidget {
  final List<SavedSong> savedSongs;
  final VoidCallback onBackToSearch;
  final void Function(SavedSong) onSelectSong;

  const SavedPage({
    Key? key,
    required this.savedSongs,
    required this.onBackToSearch,
    required this.onSelectSong,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved Lyrics', style: kTitleStyle),
          SizedBox(height: 16),
          Expanded(
            child: savedSongs.isEmpty
                ? Center(
                    child: Text('No saved songs yet.', style: kSuggestionStyle),
                  )
                : ListView.builder(
                    itemCount: savedSongs.length,
                    itemBuilder: (context, index) {
                      final song = savedSongs[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          onTap: () => onSelectSong(song),
                          leading: song.albumArtUrl != null
                              ? Image.network(
                                  song.albumArtUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.music_note),
                                )
                              : Icon(Icons.music_note),
                          title: Text(
                            '${song.artist} - ${song.song}',
                            style: kSuggestionStyle,
                          ),
                          subtitle: Text(
                            song.lyrics,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: kLyricsStyle,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: onBackToSearch,
              child: Text('Back to Search'),
              style: kButtonStyle,
            ),
          ),
        ],
      ),
    );
  }
}
