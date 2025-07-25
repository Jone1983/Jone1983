import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom YouTube Shorts Widget for FlutterFlow
/// 
/// This widget displays YouTube Shorts with customizable properties
/// and can be easily integrated into FlutterFlow projects.
class YouTubeShortsWidget extends StatefulWidget {
  final String videoId;
  final double width;
  final double height;
  final bool autoPlay;
  final bool showControls;
  final bool allowFullscreen;
  final VoidCallback? onVideoEnd;
  final VoidCallback? onVideoStart;
  final Function(String)? onError;

  const YouTubeShortsWidget({
    Key? key,
    required this.videoId,
    this.width = 300.0,
    this.height = 533.0, // Standard shorts aspect ratio (9:16)
    this.autoPlay = false,
    this.showControls = true,
    this.allowFullscreen = true,
    this.onVideoEnd,
    this.onVideoStart,
    this.onError,
  }) : super(key: key);

  @override
  State<YouTubeShortsWidget> createState() => _YouTubeShortsWidgetState();
}

class _YouTubeShortsWidgetState extends State<YouTubeShortsWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            widget.onVideoStart?.call();
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
            widget.onError?.call(error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(_buildEmbedUrl()));
  }

  String _buildEmbedUrl() {
    final baseUrl = 'https://www.youtube.com/embed/${widget.videoId}';
    final params = <String, String>{
      'rel': '0',
      'modestbranding': '1',
      'fs': widget.allowFullscreen ? '1' : '0',
      'controls': widget.showControls ? '1' : '0',
      'autoplay': widget.autoPlay ? '1' : '0',
      'mute': widget.autoPlay ? '1' : '0', // Auto-mute for autoplay
      'loop': '1',
      'playlist': widget.videoId,
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  Future<void> _openInYouTube() async {
    final url = 'https://www.youtube.com/shorts/${widget.videoId}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Video Player
            if (!_hasError)
              WebViewWidget(controller: _controller)
            else
              _buildErrorWidget(),

            // Loading Indicator
            if (_isLoading && !_hasError)
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),

            // Open in YouTube Button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _openInYouTube,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.open_in_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading video',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isLoading = true;
              });
              _initializeController();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Factory function for FlutterFlow Custom Widget creation
Widget createYouTubeShortsWidget({
  required String videoId,
  double? width,
  double? height,
  bool? autoPlay,
  bool? showControls,
  bool? allowFullscreen,
  VoidCallback? onVideoEnd,
  VoidCallback? onVideoStart,
  Function(String)? onError,
}) {
  return YouTubeShortsWidget(
    videoId: videoId,
    width: width ?? 300.0,
    height: height ?? 533.0,
    autoPlay: autoPlay ?? false,
    showControls: showControls ?? true,
    allowFullscreen: allowFullscreen ?? true,
    onVideoEnd: onVideoEnd,
    onVideoStart: onVideoStart,
    onError: onError,
  );
}

/// Helper function to extract video ID from YouTube Shorts URL
String extractVideoIdFromShortsUrl(String url) {
  // Handle various YouTube Shorts URL formats
  final patterns = [
    RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]+)'),
    RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)'),
    RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(url);
    if (match != null) {
      return match.group(1)!;
    }
  }
  
  // If no pattern matches, assume the input is already a video ID
  return url;
}