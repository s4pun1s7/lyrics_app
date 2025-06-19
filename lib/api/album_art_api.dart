import 'package:http/http.dart' as http;
import 'dart:convert';

class AlbumArtResult {
  final String? artworkUrl;
  final String? trackName;
  final String? artistName;
  final String? collectionName;
  final String? trackViewUrl;
  final String? collectionViewUrl;
  final String? releaseDate;
  final String? genre;
  final String? spotifyUrl;

  AlbumArtResult({
    this.artworkUrl,
    this.trackName,
    this.artistName,
    this.collectionName,
    this.trackViewUrl,
    this.collectionViewUrl,
    this.releaseDate,
    this.genre,
    this.spotifyUrl,
  });

  factory AlbumArtResult.fromJson(Map<String, dynamic> json) {
    final artist = json['artistName'] ?? '';
    final track = json['trackName'] ?? '';
    final spotifyQuery = Uri.encodeComponent('$artist $track');
    final spotifyUrl = 'https://open.spotify.com/search/$spotifyQuery';
    return AlbumArtResult(
      artworkUrl: json['artworkUrl100'],
      trackName: track,
      artistName: artist,
      collectionName: json['collectionName'],
      trackViewUrl: json['trackViewUrl'],
      collectionViewUrl: json['collectionViewUrl'],
      releaseDate: json['releaseDate'],
      genre: json['primaryGenreName'],
      spotifyUrl: spotifyUrl,
    );
  }
}

Future<AlbumArtResult?> fetchAlbumArt(String artist, String song) async {
  final query = Uri.encodeComponent('$artist $song');
  final url = Uri.parse(
    'https://itunes.apple.com/search?term=$query&entity=song&limit=1',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['resultCount'] > 0) {
      return AlbumArtResult.fromJson(data['results'][0]);
    }
  }
  return null;
}
