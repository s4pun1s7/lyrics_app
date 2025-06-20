import 'package:flutter/material.dart';

class SettingsPreview extends StatelessWidget {
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final TextAlign textAlign;
  final double textAreaWidth;
  const SettingsPreview({
    super.key,
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    required this.textAlign,
    required this.textAreaWidth,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: textAreaWidth),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.\nSed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: fontSize,
                  height: lineHeight,
                ),
                textAlign: textAlign,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
