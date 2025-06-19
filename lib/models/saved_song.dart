import 'dart:convert';

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
  );

  static String encodeList(List<SavedSong> songs) =>
      json.encode(songs.map((s) => s.toJson()).toList());

  static List<SavedSong> decodeList(String songs) =>
      (json.decode(songs) as List<dynamic>)
          .map((item) => SavedSong.fromJson(item))
          .toList();
}
