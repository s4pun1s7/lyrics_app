import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> fetchLyricsFromLyricsOvh(String artist, String song) async {
  final url = Uri.parse(
    'https://api.lyrics.ovh/v1/${Uri.encodeComponent(artist)}/${Uri.encodeComponent(song)}',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['lyrics'] != null && data['lyrics'].toString().trim().isNotEmpty) {
      return data['lyrics'];
    }
  }
  return null;
}

Future<String?> fetchLyricsFromChartLyrics(String artist, String song) async {
  final url = Uri.parse(
    'http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=${Uri.encodeComponent(artist)}&song=${Uri.encodeComponent(song)}',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final xml = response.body;
    final start = xml.indexOf('<Lyric>');
    final end = xml.indexOf('</Lyric>');
    if (start != -1 && end != -1 && end > start) {
      final lyrics = xml.substring(start + 7, end).trim();
      if (lyrics.isNotEmpty) return lyrics;
    }
  }
  return null;
}

Future<String?> fetchLyrics(String artist, String song) async {
  String? lyrics = await fetchLyricsFromLyricsOvh(artist, song);
  if (lyrics == null || lyrics.isEmpty) {
    lyrics = await fetchLyricsFromChartLyrics(artist, song);
  }
  return lyrics;
}
