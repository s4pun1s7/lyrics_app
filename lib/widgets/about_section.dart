import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  final void Function(String url) onLaunchUrl;
  const AboutSection({super.key, required this.onLaunchUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lyrics App\nA simple, responsive lyrics viewer and editor.',
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () =>
              onLaunchUrl('https://github.com/martinivanov/lyrics_app'),
          child: const Text(
            'Source Code on GitHub',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
