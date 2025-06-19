import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<double> onLineHeightChanged;
  final TextAlign textAlign;
  final ValueChanged<TextAlign> onTextAlignChanged;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    required this.onFontFamilyChanged,
    required this.onFontSizeChanged,
    required this.onLineHeightChanged,
    required this.textAlign,
    required this.onTextAlignChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Interface', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(isDarkMode ? 'Dark' : 'Light'),
            trailing: Switch(value: isDarkMode, onChanged: onThemeChanged),
          ),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: const Text('Font Family'),
            subtitle: Text(fontFamily),
            trailing: DropdownButton<String>(
              value: fontFamily,
              items: const [
                DropdownMenuItem(value: 'monospace', child: Text('Monospace')),
                DropdownMenuItem(value: 'serif', child: Text('Serif')),
                DropdownMenuItem(
                  value: 'sans-serif',
                  child: Text('Sans-serif'),
                ),
                DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
              ],
              onChanged: (val) {
                if (val != null) onFontFamilyChanged(val);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Font Size'),
            subtitle: Text(fontSize.toStringAsFixed(1)),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                min: 12,
                max: 32,
                divisions: 20,
                value: fontSize,
                label: fontSize.toStringAsFixed(1),
                onChanged: onFontSizeChanged,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_line_spacing),
            title: const Text('Line Height'),
            subtitle: Text(lineHeight.toStringAsFixed(2)),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                min: 1.0,
                max: 2.5,
                divisions: 15,
                value: lineHeight,
                label: lineHeight.toStringAsFixed(2),
                onChanged: onLineHeightChanged,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_align_left),
            title: const Text('Text Alignment'),
            subtitle: Text(
              textAlign == TextAlign.left
                  ? 'Left'
                  : textAlign == TextAlign.center
                  ? 'Center'
                  : textAlign == TextAlign.right
                  ? 'Right'
                  : 'Justify',
            ),
            trailing: DropdownButton<TextAlign>(
              value: textAlign,
              items: const [
                DropdownMenuItem(value: TextAlign.left, child: Text('Left')),
                DropdownMenuItem(
                  value: TextAlign.center,
                  child: Text('Center'),
                ),
                DropdownMenuItem(value: TextAlign.right, child: Text('Right')),
                DropdownMenuItem(
                  value: TextAlign.justify,
                  child: Text('Justify'),
                ),
              ],
              onChanged: (val) {
                if (val != null) onTextAlignChanged(val);
              },
            ),
          ),
          const Divider(height: 32),
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Lyrics Finder'),
            subtitle: const Text(
              'Version 0.0.1\nA simple app to search, save, and view song lyrics.\nDeveloped with Flutter.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source Code'),
            subtitle: const Text('github.com/s4pun1s7/lyrics_app'),
            onTap: null, // Placeholder for future link
          ),
        ],
      ),
    );
  }
}
