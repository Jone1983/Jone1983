import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget personalizado para exibir vídeos do YouTube Shorts
class YouTubeShortsWidget extends StatefulWidget {
  /// ID do vídeo do YouTube (obrigatório)
  final String videoId;
  
  /// Largura do widget (opcional)
  final double? width;
  
  /// Altura do widget (opcional)
  final double? height;
  
  /// Se o vídeo deve tocar automaticamente (padrão: false)
  final bool autoPlay;
  
  /// Se deve mostrar os controles do player (padrão: true)
  final bool showControls;
  
  /// Se permite tela cheia (padrão: true)
  final bool allowFullscreen;
  
  /// Callback chamado quando o vídeo inicia
  final VoidCallback? onVideoStart;
  
  /// Callback chamado quando o vídeo termina
  final VoidCallback? onVideoEnd;
  
  /// Callback chamado quando ocorre um erro
  final Function(String errorMessage)? onError;

  const YouTubeShortsWidget({
    Key? key,
    required this.videoId,
    this.width,
    this.height,
    this.autoPlay = false,
    this.showControls = true,
    this.allowFullscreen = true,
    this.onVideoStart,
    this.onVideoEnd,
    this.onError,
  }) : super(key: key);

  @override
  State<YouTubeShortsWidget> createState() => _YouTubeShortsWidgetState();
}

class _YouTubeShortsWidgetState extends State<YouTubeShortsWidget> {
  late YoutubePlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      _controller = YoutubePlayerController(
        initialVideoId: widget.videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: false,
          enableCaption: false,
          controlsVisibleAtStart: widget.showControls,
          hideControls: !widget.showControls,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          startAt: 0,
        ),
      );

      _controller.addListener(_onPlayerStateChange);
      
      // Simula o fim do carregamento após um delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      _handleError('Erro ao inicializar o player: $e');
    }
  }

  void _onPlayerStateChange() {
    if (_controller.value.isReady && _isLoading) {
      setState(() {
        _isLoading = false;
      });
    }

    if (_controller.value.playerState == PlayerState.playing && !_hasError) {
      widget.onVideoStart?.call();
    }

    if (_controller.value.playerState == PlayerState.ended) {
      widget.onVideoEnd?.call();
    }

    if (_controller.value.hasError) {
      _handleError(_controller.value.errorDescription ?? 'Erro desconhecido no player');
    }
  }

  void _handleError(String errorMessage) {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = errorMessage;
    });
    widget.onError?.call(errorMessage);
  }

  Future<void> _openInYouTube() async {
    final url = 'https://www.youtube.com/watch?v=${widget.videoId}';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _handleError('Não foi possível abrir o YouTube');
      }
    } catch (e) {
      _handleError('Erro ao abrir o YouTube: $e');
    }
  }

  void _retry() {
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Player de vídeo ou estados de carregamento/erro
            if (_hasError)
              _buildErrorState()
            else if (_isLoading)
              _buildLoadingState()
            else
              _buildVideoPlayer(),
            
            // Botão "Abrir no YouTube" no canto superior direito
            if (!_hasError)
              Positioned(
                top: 8,
                right: 8,
                child: _buildOpenYouTubeButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      progressColors: const ProgressBarColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
      ),
      onReady: () {
        setState(() {
          _isLoading = false;
        });
      },
      onEnded: (metaData) {
        widget.onVideoEnd?.call();
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          SizedBox(height: 16),
          Text(
            'Carregando vídeo...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              'Erro ao carregar vídeo',
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenYouTubeButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: _openInYouTube,
        icon: const Icon(
          Icons.open_in_new,
          color: Colors.white,
          size: 20,
        ),
        tooltip: 'Abrir no YouTube',
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }
}

/// Função utilitária para extrair o ID do vídeo de URLs do YouTube
String? extractVideoIdFromShortsUrl(String url) {
  // Remove espaços em branco
  url = url.trim();
  
  // Diferentes padrões de URL do YouTube
  final patterns = [
    // YouTube Shorts
    RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]+)'),
    // URL padrão do YouTube
    RegExp(r'youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
    // URL encurtada youtu.be
    RegExp(r'youtu\.be/([a-zA-Z0-9_-]+)'),
    // URL com outros parâmetros
    RegExp(r'youtube\.com/watch\?.*[?&]v=([a-zA-Z0-9_-]+)'),
    // URL do YouTube Music
    RegExp(r'music\.youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
    // URL mobile
    RegExp(r'm\.youtube\.com/watch\?v=([a-zA-Z0-9_-]+)'),
  ];
  
  for (final pattern in patterns) {
    final match = pattern.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
  }
  
  // Se nenhum padrão corresponder, verifica se a string já é um ID válido
  if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) {
    return url;
  }
  
  return null;
}