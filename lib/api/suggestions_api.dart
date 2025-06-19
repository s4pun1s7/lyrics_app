import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> fetchSuggestions(String query, String type) async {
  if (query.isEmpty) return [];
  final url = Uri.parse(
    'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=$type&limit=10',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = List<String>.from(
      data['results'].map((item) => type == 'musicArtist' ? item['artistName'] : item['trackName']),
    );
    // Remove duplicates and sort alphabetically
    final uniqueSorted = results.toSet().toList()..sort();
    if (uniqueSorted.isNotEmpty) return uniqueSorted;
    // Fallback: if no results, try searching both artist and song
    if (type == 'musicArtist') {
      final fallbackUrl = Uri.parse(
        'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=song&limit=10',
      );
      final fallbackResponse = await http.get(fallbackUrl);
      if (fallbackResponse.statusCode == 200) {
        final fallbackData = json.decode(fallbackResponse.body);
        final fallbackResults = List<String>.from(
          fallbackData['results'].map((item) => item['trackName']),
        );
        return fallbackResults.toSet().toList()..sort();
      }
    } else {
      final fallbackUrl = Uri.parse(
        'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=musicArtist&limit=10',
      );
      final fallbackResponse = await http.get(fallbackUrl);
      if (fallbackResponse.statusCode == 200) {
        final fallbackData = json.decode(fallbackResponse.body);
        final fallbackResults = List<String>.from(
          fallbackData['results'].map((item) => item['artistName']),
        );
        return fallbackResults.toSet().toList()..sort();
      }
    }
  }
  return [];
}