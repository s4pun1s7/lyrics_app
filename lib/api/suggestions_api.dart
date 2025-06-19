import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> fetchSuggestions(String query, String type) async {
  if (query.isEmpty) return [];
  final url = Uri.parse(
    'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=$type&limit=5',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<String>.from(
      data['results'].map((item) => type == 'musicArtist' ? item['artistName'] : item['trackName']),
    );
  }
  return [];
}