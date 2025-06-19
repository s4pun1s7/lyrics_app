import 'package:flutter/material.dart';
import '../style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LyricsPage extends StatefulWidget {
  final String artist;
  final String song;
  final String lyrics;
  final String? albumArtUrl;
  final VoidCallback onSave;
  final VoidCallback onUnsave;
  final bool isSaved;

  const LyricsPage({
    Key? key,
    required this.artist,
    required this.song,
    required this.lyrics,
    required this.albumArtUrl,
    required this.onSave,
    required this.onUnsave,
    required this.isSaved,
  }) : super(key: key);

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  double _fontSize = 16;
  String _fontFamily = 'monospace';
  Color _textColor = Colors.black;
  Color _bgColor = Colors.white;

  final ScrollController _scrollController = ScrollController();
  bool _isAutoScrolling = false;
  double _scrollSpeed = 30; // pixels per second
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    setState(() {
      if (_textColor == Colors.black || _textColor == Colors.white) {
        _textColor = isDark ? Colors.white : Colors.black;
      }
      if (_bgColor == Colors.white || _bgColor == Colors.black) {
        _bgColor = isDark ? Colors.black : Colors.white;
      }
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('lyrics_font_size') ?? 16;
      _fontFamily = prefs.getString('lyrics_font_family') ?? 'monospace';
      _textColor = Color(
        prefs.getInt('lyrics_text_color') ?? Colors.black.value,
      );
      _bgColor = Color(prefs.getInt('lyrics_bg_color') ?? Colors.white.value);
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lyrics_font_size', _fontSize);
    await prefs.setString('lyrics_font_family', _fontFamily);
    await prefs.setInt('lyrics_text_color', _textColor.value);
    await prefs.setInt('lyrics_bg_color', _bgColor.value);
  }

  void _resetToDefaultStyle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    setState(() {
      _fontSize = 16;
      _fontFamily = 'monospace';
      _textColor = isDark ? Colors.white : Colors.black;
      _bgColor = isDark ? Colors.black : Colors.white;
    });
    _savePrefs();
  }

  void _showCustomizeSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Font Size'),
                      Slider(
                        value: _fontSize,
                        min: 12,
                        max: 32,
                        divisions: 10,
                        label: _fontSize.round().toString(),
                        onChanged: (v) {
                          setModalState(() => _fontSize = v);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Font Family'),
                      DropdownButton<String>(
                        value: _fontFamily,
                        items: [
                          DropdownMenuItem(
                            value: 'monospace',
                            child: Text('Monospace'),
                          ),
                          DropdownMenuItem(
                            value: 'serif',
                            child: Text('Serif'),
                          ),
                          DropdownMenuItem(value: 'sans', child: Text('Sans')),
                        ],
                        onChanged: (v) {
                          if (v != null) setModalState(() => _fontFamily = v);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Text Color'),
                      GestureDetector(
                        onTap: () async {
                          Color? picked = await showDialog(
                            context: context,
                            builder: (context) =>
                                _ColorPickerDialog(_textColor),
                          );
                          if (picked != null)
                            setModalState(() => _textColor = picked);
                        },
                        child: CircleAvatar(backgroundColor: _textColor),
                      ),
                      Text('Background'),
                      GestureDetector(
                        onTap: () async {
                          Color? picked = await showDialog(
                            context: context,
                            builder: (context) => _ColorPickerDialog(_bgColor),
                          );
                          if (picked != null)
                            setModalState(() => _bgColor = picked);
                        },
                        child: CircleAvatar(backgroundColor: _bgColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          _savePrefs();
                          Navigator.pop(context);
                        },
                        child: Text('Apply'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _resetToDefaultStyle();
                          Navigator.pop(context);
                        },
                        child: Text('Reset to Default'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _startAutoScroll() {
    if (_isAutoScrolling) return;
    setState(() => _isAutoScrolling = true);
    _autoScrollTimer = Timer.periodic(Duration(milliseconds: 16), (_) {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final next = current + _scrollSpeed * 0.016; // 16ms per tick
      if (next >= maxScroll) {
        _scrollController.jumpTo(maxScroll);
        _stopAutoScroll();
      } else {
        _scrollController.jumpTo(next);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    setState(() => _isAutoScrolling = false);
  }

  void _showScrollSettings() {
    showDialog(
      context: context,
      builder: (context) {
        double tempSpeed = _scrollSpeed;
        return AlertDialog(
          title: Text('Auto-Scroll Speed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Speed: ${tempSpeed.toStringAsFixed(0)} px/sec'),
              Slider(
                value: tempSpeed,
                min: 10,
                max: 200,
                divisions: 19,
                label: tempSpeed.toStringAsFixed(0),
                onChanged: (v) {
                  setState(() => _scrollSpeed = v);
                  tempSpeed = v;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  bool get _isCurrentLyricsSaved {
    // This assumes you pass a list of saved songs and current artist/song to this widget or via a callback
    // For now, let's use an InheritedWidget or a callback, but here's a placeholder:
    // Replace with actual logic as needed
    if (widget.lyrics.isEmpty || widget.artist.isEmpty || widget.song.isEmpty)
      return false;
    // You may want to pass a Set<String> of saved keys for efficiency
    // For now, just return false (or true if you have access to saved songs)
    // TODO: Replace with actual logic to check if the current lyrics are saved.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgColor,
      child: Padding(
        padding: kPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.albumArtUrl != null)
              SizedBox(
                width: kAlbumArtSize,
                height: kAlbumArtSize,
                child: Image.network(
                  widget.albumArtUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.music_note, size: 60),
                ),
              ),
            SizedBox(height: 16),
            Text(
              '${widget.artist} - ${widget.song}',
              style: kTitleStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: widget.isSaved ? widget.onUnsave : widget.onSave,
                  child: Text(widget.isSaved ? 'Unsave' : 'Save'),
                  style: kButtonStyle,
                ),
                SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _showCustomizeSheet,
                  child: Icon(Icons.settings),
                ),
                SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _isAutoScrolling
                      ? _stopAutoScroll
                      : _startAutoScroll,
                  child: Icon(
                    _isAutoScrolling ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _showScrollSettings,
                  child: Icon(Icons.speed),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _formatLyricsSections(widget.lyrics),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _formatLyricsSections(String lyrics) {
    final lines = lyrics.trim().split('\n');
    final widgets = <Widget>[];
    bool lastWasBlank = false;
    final sectionRegex = RegExp(
      r'\[(chorus|verse|bridge|intro|outro|hook|pre-chorus|refrain)[^\]]*\]',
      caseSensitive: false,
    );

    for (final line in lines) {
      final trimmed = line.trim();
      final isBlank = trimmed.isEmpty;
      if (isBlank) {
        if (!lastWasBlank) widgets.add(SizedBox(height: 12));
        lastWasBlank = true;
        continue;
      }
      lastWasBlank = false;
      if (sectionRegex.hasMatch(trimmed)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              trimmed,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 1.1 * 16, // Slightly larger
                color: Colors.blueAccent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          SelectableText(
            line,
            style: TextStyle(
              fontSize: _fontSize,
              fontFamily: _fontFamily == 'monospace'
                  ? 'monospace'
                  : _fontFamily == 'serif'
                  ? 'serif'
                  : null,
              color: _textColor,
            ),
            textAlign: TextAlign.left,
          ),
        );
      }
    }
    return widgets;
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const _ColorPickerDialog(this.initialColor);
  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  double _r = 0, _g = 0, _b = 0;
  @override
  void initState() {
    super.initState();
    _r = widget.initialColor.red.toDouble();
    _g = widget.initialColor.green.toDouble();
    _b = widget.initialColor.blue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pick Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _r,
            min: 0,
            max: 255,
            label: 'R: ${_r.round()}',
            activeColor: Colors.red,
            onChanged: (v) => setState(() => _r = v),
          ),
          Slider(
            value: _g,
            min: 0,
            max: 255,
            label: 'G: ${_g.round()}',
            activeColor: Colors.green,
            onChanged: (v) => setState(() => _g = v),
          ),
          Slider(
            value: _b,
            min: 0,
            max: 255,
            label: 'B: ${_b.round()}',
            activeColor: Colors.blue,
            onChanged: (v) => setState(() => _b = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            Color.fromARGB(255, _r.round(), _g.round(), _b.round()),
          ),
          child: Text('Select'),
        ),
      ],
    );
  }
}
