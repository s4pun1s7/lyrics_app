import 'package:flutter/material.dart';

// Common paddings, text styles, and decorations for the app

const EdgeInsets kPagePadding = EdgeInsets.all(16.0);

const TextStyle kTitleStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);

const TextStyle kSuggestionStyle = TextStyle(
  fontSize: 16,
);

const TextStyle kLyricsStyle = TextStyle(
  fontSize: 16,
  fontFamily: 'monospace',
);

const double kAlbumArtSize = 100.0;

final ButtonStyle kButtonStyle = ElevatedButton.styleFrom(
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  textStyle: TextStyle(fontSize: 16),
);