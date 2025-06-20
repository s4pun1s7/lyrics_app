import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/firebase_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LyricsApp());
}

class LyricsApp extends StatefulWidget {
  const LyricsApp({super.key});
  @override
  LyricsAppState createState() => LyricsAppState();
}

class LyricsAppState extends State<LyricsApp> {
  bool _isDarkMode = true;
  late Future<void> _firebaseInitFuture;

  @override
  void initState() {
    super.initState();
    _firebaseInitFuture = FirebaseService.initialize();
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _firebaseInitFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MaterialApp(
          title: 'Lyrics Finder',
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: LyricsHomePage(
            isDarkMode: _isDarkMode,
            toggleTheme: _toggleTheme,
          ),
        );
      },
    );
  }
}
