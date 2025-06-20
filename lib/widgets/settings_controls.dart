import 'package:flutter/material.dart';

class SettingsControls extends StatelessWidget {
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
  final VoidCallback onResetDefaults;
  final double textAreaWidth;
  final ValueChanged<double> onTextAreaWidthChanged;

  const SettingsControls({
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
    required this.onResetDefaults,
    required this.textAreaWidth,
    required this.onTextAreaWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: isDarkMode,
          onChanged: onThemeChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: fontFamily,
          decoration: const InputDecoration(labelText: 'Font Family'),
          items: const [
            DropdownMenuItem(value: 'monospace', child: Text('Monospace')),
            DropdownMenuItem(value: 'serif', child: Text('Serif')),
            DropdownMenuItem(value: 'sans-serif', child: Text('Sans Serif')),
          ],
          onChanged: (val) {
            if (val != null) onFontFamilyChanged(val);
          },
        ),
        const SizedBox(height: 16),
        Slider(
          value: fontSize,
          min: 12,
          max: 32,
          divisions: 20,
          label: fontSize.toStringAsFixed(1),
          onChanged: onFontSizeChanged,
        ),
        Text('Font Size: ${fontSize.toStringAsFixed(1)}'),
        const SizedBox(height: 16),
        Slider(
          value: lineHeight,
          min: 1.0,
          max: 2.0,
          divisions: 20,
          label: lineHeight.toStringAsFixed(2),
          onChanged: onLineHeightChanged,
        ),
        Text('Line Height: ${lineHeight.toStringAsFixed(2)}'),
        const SizedBox(height: 16),
        DropdownButtonFormField<TextAlign>(
          value: textAlign,
          decoration: const InputDecoration(labelText: 'Text Alignment'),
          items: const [
            DropdownMenuItem(value: TextAlign.left, child: Text('Left')),
            DropdownMenuItem(value: TextAlign.center, child: Text('Center')),
            DropdownMenuItem(value: TextAlign.right, child: Text('Right')),
          ],
          onChanged: (val) {
            if (val != null) onTextAlignChanged(val);
          },
        ),
        const SizedBox(height: 16),
        Slider(
          value: textAreaWidth,
          min: 300,
          max: 900,
          divisions: 12,
          label: '${textAreaWidth.toStringAsFixed(0)} px',
          onChanged: onTextAreaWidthChanged,
        ),
        Text('Text Area Width: ${textAreaWidth.toStringAsFixed(0)} px'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onResetDefaults,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset to Defaults'),
        ),
      ],
    );
  }
}
