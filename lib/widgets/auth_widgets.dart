import 'package:flutter/material.dart';
import '../style.dart';

class AuthErrorBanner extends StatelessWidget {
  final String? error;
  const AuthErrorBanner({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    return Container(
      color: Colors.red[100],
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Text(error!, style: TextStyle(color: Colors.red[900])),
    );
  }
}

class AuthButtons extends StatelessWidget {
  final bool isLoading;
  final dynamic user;
  final String? authProvider;
  final void Function(String) onSignIn;
  final VoidCallback onSignOut;
  const AuthButtons({
    super.key,
    required this.isLoading,
    required this.user,
    required this.authProvider,
    required this.onSignIn,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (user == null) {
      return Row(
        children: [
          ElevatedButton(
            onPressed: () => onSignIn('google'),
            child: const Text('Google'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onSignIn('github'),
            child: const Text('GitHub'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onSignIn('anonymous'),
            child: const Text('Anon'),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              user.displayName ?? user.email ?? authProvider ?? 'Signed in',
              style: kSuggestionStyle,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: onSignOut,
          ),
        ],
      );
    }
  }
}
