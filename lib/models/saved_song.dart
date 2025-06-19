class SavedSong {
  final String artist;
  final String song;
  final String lyrics;
  final String? albumArtUrl;

  SavedSong({
    required this.artist,
    required this.song,
    required this.lyrics,
    this.albumArtUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'artist': artist,
      'song': song,
      'lyrics': lyrics,
      'albumArtUrl': albumArtUrl,
    };
  }
}
