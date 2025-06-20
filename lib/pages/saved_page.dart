import 'package:flutter/material.dart';
import '../style.dart';
import '../models/saved_song.dart';

class SavedPage extends StatelessWidget {
  final List<SavedSong> savedSongs;
  final VoidCallback onBackToSearch;
  final void Function(SavedSong) onDeleteSong;
  final void Function(SavedSong) onOpenSong;

  const SavedPage({
    super.key,
    required this.savedSongs,
    required this.onBackToSearch,
    required this.onDeleteSong,
    required this.onOpenSong,
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
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: savedSongs.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final song = savedSongs[index];
                        return ListTile(
                          leading: song.albumArtUrl != null
                              ? Image.network(
                                  song.albumArtUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.music_note),
                                )
                              : const Icon(Icons.music_note),
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => onDeleteSong(song),
                            tooltip: 'Delete',
                          ),
                          onTap: () => onOpenSong(song),
                        );
                      },
                    ),
                  ),
                  VerticalDivider(width: 32),
                  Expanded(
                    flex: 1,
                    child: Container(), // Placeholder for future content
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  savedSongs.isEmpty
                      ? const Center(
                          child: Text(
                            'No saved songs yet.',
                            style: kSuggestionStyle,
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: savedSongs.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final song = savedSongs[index];
                            return ListTile(
                              leading: song.albumArtUrl != null
                                  ? Image.network(
                                      song.albumArtUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.music_note),
                                    )
                                  : const Icon(Icons.music_note),
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
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => onDeleteSong(song),
                                tooltip: 'Delete',
                              ),
                              onTap: () => onOpenSong(song),
                            );
                          },
                        ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Search'),
                      onPressed: onBackToSearch,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
