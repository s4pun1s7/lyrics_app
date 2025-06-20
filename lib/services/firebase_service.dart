import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Centralized Firebase initialization for all platforms
  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) return; // Prevent re-initialization
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBSw48KcwPHh3U8jJ7Dx-QlkztdG4--iA0",
          authDomain: "lyricsapp-e9d22.firebaseapp.com",
          projectId: "lyricsapp-e9d22",
          storageBucket: "lyricsapp-e9d22.firebasestorage.app",
          messagingSenderId: "839991212203",
          appId: "1:839991212203:web:9ce378c65322e861c25fee",
          measurementId: "G-RCTB1SLMH6",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  // Sign in anonymously (or replace with email/password, Google, etc.)
  static Future<User?> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  // Sign in with Google
  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web sign-in
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);
      return userCredential.user;
    } else {
      // Mobile/desktop sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    }
  }

  // Sign in with GitHub (web only)
  static Future<User?> signInWithGitHub() async {
    if (!kIsWeb) {
      throw UnimplementedError(
        'GitHub sign-in is only supported on web in this example.',
      );
    }
    GithubAuthProvider githubProvider = GithubAuthProvider();
    final userCredential = await _auth.signInWithPopup(githubProvider);
    return userCredential.user;
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
    // Optionally sign out from GoogleSignIn as well
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }

  // Save user data (example: save a song)
  static Future<void> saveSong(String uid, Map<String, dynamic> song) async {
    await _db.collection('users').doc(uid).collection('songs').add(song);
  }

  // Get all saved songs for a user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getSongs(String uid) {
    return _db.collection('users').doc(uid).collection('songs').snapshots();
  }

  // Delete a song by document ID
  static Future<void> deleteSong(String uid, String songId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('songs')
        .doc(songId)
        .delete();
  }
}
