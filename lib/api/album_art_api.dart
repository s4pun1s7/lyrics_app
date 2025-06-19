import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> fetchAlbumArt(String artist, String song) async {
  final query = Uri.encodeComponent('$artist $song');
  final url = Uri.parse(
    'https://itunes.apple.com/search?term=$query&entity=song&limit=1',
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['resultCount'] > 0) {
      return data['results'][0]['artworkUrl100'];
    }
  }
  return null;
}