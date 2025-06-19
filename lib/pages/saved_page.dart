import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style.dart';
import '../models/saved_song.dart';
import 'lyrics_page.dart';

class SavedPage extends StatelessWidget {
  final List<SavedSong> savedSongs;
  final VoidCallback onBackToSearch;
  final void Function(SavedSong) onDeleteSong;

  const SavedPage({
    super.key,
    required this.savedSongs,
    required this.onBackToSearch,
    required this.onDeleteSong,
  });

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
                        child: InkWell(
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pop(); // Close drawer/dialog if open
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LyricsPage(
                                  artist: song.artist,
                                  song: song.song,
                                  lyrics: song.lyrics,
                                  albumArtUrl: song.albumArtUrl,
                                  onSave:
                                      () {}, // Provide actual callbacks if needed
                                  onUnsave: () {},
                                  isSaved: true,
                                  fontFamily: 'monospace',
                                  fontSize: 16.0,
                                  lineHeight: 1.2,
                                ),
                              ),
                            );
                          },
                          child: ListTile(
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
                            leading: song.albumArtUrl != null
                                ? Image.network(
                                    song.albumArtUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.music_note),
                                  )
                                : Icon(Icons.music_note),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.copy),
                                  tooltip: 'Copy Lyrics',
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: song.lyrics),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Lyrics copied to clipboard!',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  tooltip: 'Delete',
                                  onPressed: () => onDeleteSong(song),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: onBackToSearch,
              style: kButtonStyle,
              child: Text('Back to Search'),
            ),
          ),
        ],
      ),
    );
  }
}
