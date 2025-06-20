import 'package:flutter/material.dart';
import '../widgets/settings_preview.dart';
import '../widgets/settings_controls.dart';
import '../widgets/about_section.dart';

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
  final double textAreaWidth;
  final ValueChanged<double> onTextAreaWidthChanged;

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
    required this.textAreaWidth,
    required this.onTextAreaWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      appBar: isWide ? null : AppBar(title: const Text('Settings')),
      body: isWide
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      SettingsControls(
                        isDarkMode: isDarkMode,
                        onThemeChanged: onThemeChanged,
                        fontFamily: fontFamily,
                        fontSize: fontSize,
                        lineHeight: lineHeight,
                        onFontFamilyChanged: onFontFamilyChanged,
                        onFontSizeChanged: onFontSizeChanged,
                        onLineHeightChanged: onLineHeightChanged,
                        textAlign: textAlign,
                        onTextAlignChanged: onTextAlignChanged,
                        textAreaWidth: textAreaWidth,
                        onTextAreaWidthChanged: onTextAreaWidthChanged,
                        onResetDefaults: () => _resetDefaults(context),
                      ),
                      const SizedBox(height: 32),
                      AboutSection(
                        onLaunchUrl: (url) => _launchUrl(context, url),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: SettingsPreview(
                      fontFamily: fontFamily,
                      fontSize: fontSize,
                      lineHeight: lineHeight,
                      textAlign: textAlign,
                      textAreaWidth: textAreaWidth,
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                SettingsControls(
                  isDarkMode: isDarkMode,
                  onThemeChanged: onThemeChanged,
                  fontFamily: fontFamily,
                  fontSize: fontSize,
                  lineHeight: lineHeight,
                  onFontFamilyChanged: onFontFamilyChanged,
                  onFontSizeChanged: onFontSizeChanged,
                  onLineHeightChanged: onLineHeightChanged,
                  textAlign: textAlign,
                  onTextAlignChanged: onTextAlignChanged,
                  textAreaWidth: textAreaWidth,
                  onTextAreaWidthChanged: onTextAreaWidthChanged,
                  onResetDefaults: () => _resetDefaults(context),
                ),
                const SizedBox(height: 24),
                SettingsPreview(
                  fontFamily: fontFamily,
                  fontSize: fontSize,
                  lineHeight: lineHeight,
                  textAlign: textAlign,
                  textAreaWidth: textAreaWidth,
                ),
                const SizedBox(height: 32),
                AboutSection(onLaunchUrl: (url) => _launchUrl(context, url)),
              ],
            ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Link'),
        content: Text('Open this link in your browser?\n\n$url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // For web, just use launchUrlString if available, else copy to clipboard
              // For now, use canLaunchUrlString and launchUrlString if url_launcher is added
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _resetDefaults(BuildContext context) {
    onThemeChanged(false);
    onFontFamilyChanged('monospace');
    onFontSizeChanged(16.0);
    onLineHeightChanged(1.2);
    onTextAlignChanged(TextAlign.left);
    onTextAreaWidthChanged(400.0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults.')),
    );
  }
}
