import 'package:flutter/material.dart';
import '../style.dart';
import 'dart:async';

class LyricsPage extends StatefulWidget {
  final String artist;
  final String song;
  final String lyrics;
  final String? albumArtUrl;
  final VoidCallback onSave;
  final VoidCallback onUnsave;
  final bool isSaved;
  final String fontFamily;
  final double fontSize;
  final double lineHeight;
  final TextAlign textAlign;
  final String? sourceUrl;
  final String? spotifyUrl;

  const LyricsPage({
    super.key,
    required this.artist,
    required this.song,
    required this.lyrics,
    required this.albumArtUrl,
    required this.onSave,
    required this.onUnsave,
    required this.isSaved,
    required this.fontFamily,
    required this.fontSize,
    required this.lineHeight,
    this.textAlign = TextAlign.left,
    this.sourceUrl,
    this.spotifyUrl,
  });

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isAutoScrolling = false;
  double _scrollSpeed = 30; // pixels per second
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
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
    setState(() {
      // Removed color settings
    });
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Lyrics (centered)
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: SelectableText(
                      widget.lyrics,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontFamily: widget.fontFamily,
                        height: widget.lineHeight,
                      ),
                      textAlign: widget.textAlign,
                    ),
                  ),
                ),
                SizedBox(width: 32),
                // Right: Metadata and controls
                SizedBox(
                  width: 260,
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
                      SizedBox(height: 8),
                      if (widget.sourceUrl != null || widget.spotifyUrl != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.sourceUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: InkWell(
                                  onTap: () =>
                                      _launchUrl(context, widget.sourceUrl!),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.link,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'View on iTunes',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (widget.spotifyUrl != null)
                              InkWell(
                                onTap: () =>
                                    _launchUrl(context, widget.spotifyUrl!),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.music_note,
                                      size: 18,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'View on Spotify',
                                      style: TextStyle(
                                        color: Colors.green,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: widget.isSaved
                                ? widget.onUnsave
                                : widget.onSave,
                            style: kButtonStyle,
                            child: Text(widget.isSaved ? 'Unsave' : 'Save'),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _isAutoScrolling
                                ? _stopAutoScroll
                                : _startAutoScroll,
                            style: null,
                            child: Icon(
                              _isAutoScrolling ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                          SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _showScrollSettings,
                            style: null,
                            child: Icon(Icons.speed),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    // Use url_launcher or show a dialog with the link (for web compatibility)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Open Link'),
        content: Text('Open this link in your browser?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // For web, just use launchUrlString if available, else copy to clipboard
              // For now, use canLaunchUrlString and launchUrlString if url_launcher is added
            },
            child: Text('Open'),
          ),
        ],
      ),
    );
  }
}
