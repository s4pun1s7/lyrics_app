import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchLyrics(String artist, String song) async {
  final url = Uri.parse('https://api.lyrics.ovh/v1/$artist/$song');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['lyrics'] ?? 'No lyrics found.';
  } else {
    return 'Failed to fetch lyrics.';
  }
}