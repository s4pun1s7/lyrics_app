class SavedSong {
  final String artist;
  final String song;
  final String lyrics;
  final String? albumArtUrl;
  final String? firebaseId;

  SavedSong({
    required this.artist,
    required this.song,
    required this.lyrics,
    this.albumArtUrl,
    this.firebaseId,
  });

  Map<String, dynamic> toJson() => {
    'artist': artist,
    'song': song,
    'lyrics': lyrics,
    'albumArtUrl': albumArtUrl,
  };

  factory SavedSong.fromJson(Map<String, dynamic> json) => SavedSong(
    artist: json['artist'],
    song: json['song'],
    lyrics: json['lyrics'],
    albumArtUrl: json['albumArtUrl'],
    firebaseId: json['firebaseId'],
  );
}
