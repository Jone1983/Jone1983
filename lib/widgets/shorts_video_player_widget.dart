import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class ShortsVideoPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final bool autoPlay;
  final bool loopMode;
  final bool showControls;
  final bool allowFullscreen;
  final VoidCallback? onVideoStart;
  final VoidCallback? onVideoEnd;
  final VoidCallback? onViewCounted;
  final Function(String error)? onError;

  const ShortsVideoPlayerWidget({
    Key? key,
    required this.videoData,
    this.autoPlay = true,
    this.loopMode = true,
    this.showControls = false,
    this.allowFullscreen = true,
    this.onVideoStart,
    this.onVideoEnd,
    this.onViewCounted,
    this.onError,
  }) : super(key: key);

  @override
  State<ShortsVideoPlayerWidget> createState() => _ShortsVideoPlayerWidgetState();
}

class _ShortsVideoPlayerWidgetState extends State<ShortsVideoPlayerWidget>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isMuted = false;
  bool _showPlayPauseIcon = false;
  bool _showSeekIcon = false;
  bool _isSeekingForward = false;
  bool _hasCountedView = false;
  String? _sessionId;

  late AnimationController _playPauseAnimationController;
  late AnimationController _seekAnimationController;
  late Animation<double> _playPauseAnimation;
  late Animation<double> _seekAnimation;

  Timer? _playPauseTimer;
  Timer? _seekTimer;

  // Firebase instances
  late FirebaseFirestore _firestore;
  late FirebaseAnalytics _analytics;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _initializeAnimations();
    _generateSessionId();
    _initializeVideo();
  }

  void _initializeFirebase() {
    _firestore = FirebaseFirestore.instance;
    _analytics = FirebaseAnalytics.instance;
  }

  void _initializeAnimations() {
    _playPauseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _seekAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _playPauseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _playPauseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _seekAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _seekAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _generateSessionId() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  Future<void> _initializeVideo() async {
    try {
      final cloudflareStreamId = widget.videoData['cloudflareStreamId'];
      if (cloudflareStreamId == null || cloudflareStreamId.isEmpty) {
        throw Exception('cloudflareStreamId é obrigatório');
      }

      // URL do Cloudflare Stream
      final videoUrl = 'https://customer-${cloudflareStreamId.split('-')[0]}.cloudflarestream.com/${cloudflareStreamId}/manifest/video.m3u8';
      
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      
      await _controller!.initialize();
      
      if (widget.loopMode) {
        _controller!.setLooping(true);
      }

      _controller!.addListener(_videoListener);

      if (widget.autoPlay) {
        await _controller!.play();
        _isPlaying = true;
        _onVideoStart();
      }

      setState(() {
        _isLoading = false;
        _hasError = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      
      widget.onError?.call(_errorMessage);
      _analytics.logEvent(
        name: 'video_error',
        parameters: {
          'video_id': widget.videoData['cloudflareStreamId'] ?? 'unknown',
          'error': _errorMessage,
        },
      );
    }
  }

  void _videoListener() {
    if (_controller == null) return;

    final isPlaying = _controller!.value.isPlaying;
    final hasEnded = _controller!.value.position >= _controller!.value.duration;

    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });

      if (isPlaying) {
        _onVideoStart();
        _analytics.logEvent(name: 'video_played', parameters: {
          'video_id': widget.videoData['cloudflareStreamId'] ?? 'unknown',
        });
      } else {
        _analytics.logEvent(name: 'video_paused', parameters: {
          'video_id': widget.videoData['cloudflareStreamId'] ?? 'unknown',
        });
      }
    }

    if (hasEnded && !widget.loopMode) {
      _onVideoEnd();
      _analytics.logEvent(name: 'video_completed', parameters: {
        'video_id': widget.videoData['cloudflareStreamId'] ?? 'unknown',
      });
    }
  }

  void _onVideoStart() {
    widget.onVideoStart?.call();
    _countView();
  }

  void _onVideoEnd() {
    widget.onVideoEnd?.call();
  }

  Future<void> _countView() async {
    if (_hasCountedView) return;

    try {
      final videoId = widget.videoData['cloudflareStreamId'];
      final userId = widget.videoData['uploaderId'] ?? 'anonymous';
      
      // Criar um documento único para esta visualização
      final viewId = '${videoId}_${userId}_${_sessionId}';
      
      await _firestore.collection('video_views').doc(viewId).set({
        'videoId': videoId,
        'userId': userId,
        'sessionId': _sessionId,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': {
          'title': widget.videoData['title'],
          'description': widget.videoData['description'],
        }
      });

      _hasCountedView = true;
      widget.onViewCounted?.call();

      _analytics.logEvent(name: 'video_view_counted', parameters: {
        'video_id': videoId,
        'user_id': userId,
      });

    } catch (e) {
      debugPrint('Erro ao contar visualização: $e');
    }
  }

  void _togglePlayPause() {
    if (_controller == null || _hasError) return;

    setState(() {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      _showPlayPauseIcon = true;
    });

    _playPauseAnimationController.forward().then((_) {
      _playPauseAnimationController.reverse();
    });

    _playPauseTimer?.cancel();
    _playPauseTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showPlayPauseIcon = false;
        });
      }
    });
  }

  void _seekVideo(bool forward) {
    if (_controller == null || _hasError) return;

    final currentPosition = _controller!.value.position;
    final duration = _controller!.value.duration;
    const seekDuration = Duration(seconds: 10);

    Duration newPosition;
    if (forward) {
      newPosition = currentPosition + seekDuration;
      if (newPosition > duration) {
        newPosition = duration;
      }
    } else {
      newPosition = currentPosition - seekDuration;
      if (newPosition < Duration.zero) {
        newPosition = Duration.zero;
      }
    }

    _controller!.seekTo(newPosition);

    setState(() {
      _showSeekIcon = true;
      _isSeekingForward = forward;
    });

    _seekAnimationController.forward().then((_) {
      _seekAnimationController.reverse();
    });

    _seekTimer?.cancel();
    _seekTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showSeekIcon = false;
        });
      }
    });

    _analytics.logEvent(name: 'video_seek', parameters: {
      'video_id': widget.videoData['cloudflareStreamId'] ?? 'unknown',
      'seek_direction': forward ? 'forward' : 'backward',
      'seek_seconds': 10,
    });
  }

  void _toggleMute() {
    if (_controller == null || _hasError) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _hasCountedView = false;
    });

    await _controller?.dispose();
    _controller = null;
    
    await _initializeVideo();
  }

  @override
  void dispose() {
    _playPauseTimer?.cancel();
    _seekTimer?.cancel();
    _playPauseAnimationController.dispose();
    _seekAnimationController.dispose();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Video Player
          if (_controller != null && _controller!.value.isInitialized && !_hasError)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: SpinKitFadingCircle(
                color: Colors.white,
                size: 50.0,
              ),
            ),

          // Error State
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Não foi possível carregar o vídeo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _retry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),

          // Gesture Detector for controls
          if (!_hasError && !_isLoading)
            GestureDetector(
              onTap: _togglePlayPause,
              onDoubleTapDown: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                final tapX = details.localPosition.dx;
                _seekVideo(tapX > screenWidth / 2);
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),

          // Play/Pause Icon
          if (_showPlayPauseIcon)
            Center(
              child: AnimatedBuilder(
                animation: _playPauseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _playPauseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Seek Icon
          if (_showSeekIcon)
            Center(
              child: AnimatedBuilder(
                animation: _seekAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _seekAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isSeekingForward
                                ? Icons.fast_forward
                                : Icons.fast_rewind,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '10s',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Progress Bar
          if (widget.showControls && _controller != null && _controller!.value.isInitialized)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.red,
                  bufferedColor: Colors.white54,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),

          // Mute Button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Video Info
          if (widget.videoData['title'] != null || widget.videoData['description'] != null)
            Positioned(
              bottom: widget.showControls ? 80 : 40,
              left: 20,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.videoData['title'] != null)
                    Text(
                      widget.videoData['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (widget.videoData['description'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        widget.videoData['description'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}