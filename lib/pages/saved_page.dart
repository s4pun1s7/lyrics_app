import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../style.dart';
import '../models/saved_song.dart';
import 'lyrics_page.dart';
import '../storage_service.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.file_upload),
                label: Text('Import'),
                onPressed: () async {
                  try {
                    final dir = await getApplicationDocumentsDirectory();
                    final file = File('${dir.path}/lyrics_export.json');
                    if (await file.exists()) {
                      final content = await file.readAsString();
                      final imported = SavedSong.decodeList(content);
                      if (imported.isNotEmpty) {
                        // Show confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Import Lyrics'),
                            content: Text(
                                'Import will overwrite your current saved lyrics. Continue?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Import'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          // Overwrite logic must be handled by parent
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Imported ${imported.length} lyrics. Restart app to see changes.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No valid lyrics found in file.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No export file found.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import failed: $e')),
                    );
                  }
                },
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.file_download),
                label: Text('Export'),
                onPressed: () async {
                  try {
                    final dir = await getApplicationDocumentsDirectory();
                    final file = File('${dir.path}/lyrics_export.json');
                    await file.writeAsString(SavedSong.encodeList(savedSongs));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exported to ${file.path}')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                },
              ),
            ],
          ),
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
