import 'package:flutter/material.dart';
import '../style.dart';

class LyricsPage extends StatelessWidget {
  final String artist;
  final String song;
  final String lyrics;
  final String? albumArtUrl;
  final VoidCallback onBackToSearch;
  final VoidCallback onSave;

  const LyricsPage({
    Key? key,
    required this.artist,
    required this.song,
    required this.lyrics,
    required this.albumArtUrl,
    required this.onBackToSearch,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (albumArtUrl != null)
            SizedBox(
              width: kAlbumArtSize,
              height: kAlbumArtSize,
              child: Image.network(
                albumArtUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.music_note, size: 60),
              ),
            ),
          SizedBox(height: 16),
          Text(
            '$artist - $song',
            style: kTitleStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(lyrics, style: kLyricsStyle),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onBackToSearch,
                child: Text('Back to Search'),
                style: kButtonStyle,
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: onSave,
                child: Text('Save'),
                style: kButtonStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}