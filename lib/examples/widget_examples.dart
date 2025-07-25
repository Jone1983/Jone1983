import 'package:flutter/material.dart';
import '../widgets/youtube_shorts_widget.dart';

/// Exemplos de uso do YouTubeShortsWidget
class WidgetExamples {
  
  /// Exemplo básico - uso mínimo
  static Widget exemploBasico() {
    return YouTubeShortsWidget(
      videoId: 'dQw4w9WgXcQ',
    );
  }

  /// Exemplo com configurações personalizadas
  static Widget exemploPersonalizado() {
    return YouTubeShortsWidget(
      videoId: 'jNQXAC9IVRw',
      width: 350,
      height: 500,
      autoPlay: true,
      showControls: false,
      allowFullscreen: true,
      onVideoStart: () => print('Vídeo iniciou!'),
      onVideoEnd: () => print('Vídeo terminou!'),
      onError: (error) => print('Erro: $error'),
    );
  }

  /// Exemplo para lista de vídeos (formato Shorts)
  static Widget exemploListaShorts(List<String> videoIds) {
    return ListView.builder(
      itemCount: videoIds.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: YouTubeShortsWidget(
            videoId: videoIds[index],
            height: 600, // Altura típica de Shorts
            autoPlay: false,
            onVideoStart: () => debugPrint('Shorts ${index + 1} iniciou'),
            onVideoEnd: () => debugPrint('Shorts ${index + 1} terminou'),
            onError: (error) => debugPrint('Erro no Shorts ${index + 1}: $error'),
          ),
        );
      },
    );
  }

  /// Exemplo com carregamento dinâmico via URL
  static Widget exemploCarregamentoDinamico() {
    return _CarregamentoDinamicoWidget();
  }

  /// Exemplo de grid de vídeos
  static Widget exemploGrid(List<String> videoIds) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 9 / 16, // Proporção de vídeo vertical
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: videoIds.length,
      itemBuilder: (context, index) {
        return YouTubeShortsWidget(
          videoId: videoIds[index],
          showControls: false,
          autoPlay: false,
          onVideoStart: () => debugPrint('Grid vídeo ${index + 1} iniciou'),
        );
      },
    );
  }

  /// Exemplo com tratamento avançado de erros
  static Widget exemploTratamentoErros(BuildContext context) {
    return YouTubeShortsWidget(
      videoId: 'video_inexistente', // ID inválido para demonstrar erro
      onError: (errorMessage) {
        // Tratamento personalizado de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro personalizado: $errorMessage'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}

/// Widget para demonstrar carregamento dinâmico
class _CarregamentoDinamicoWidget extends StatefulWidget {
  @override
  _CarregamentoDinamicoWidgetState createState() => _CarregamentoDinamicoWidgetState();
}

class _CarregamentoDinamicoWidgetState extends State<_CarregamentoDinamicoWidget> {
  final TextEditingController _controller = TextEditingController();
  String? _currentVideoId;
  String _status = 'Digite uma URL do YouTube';

  void _loadVideo() {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    final videoId = extractVideoIdFromShortsUrl(url);
    if (videoId != null) {
      setState(() {
        _currentVideoId = videoId;
        _status = 'Vídeo carregado: $videoId';
      });
    } else {
      setState(() {
        _status = 'URL inválida. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'URL do YouTube',
                  hintText: 'Cole aqui a URL do vídeo',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _loadVideo(),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadVideo,
                child: const Text('Carregar Vídeo'),
              ),
              const SizedBox(height: 8),
              Text(
                _status,
                style: TextStyle(
                  color: _currentVideoId != null ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (_currentVideoId != null)
          Expanded(
            child: YouTubeShortsWidget(
              videoId: _currentVideoId!,
              onVideoStart: () => setState(() => _status = 'Reproduzindo...'),
              onVideoEnd: () => setState(() => _status = 'Vídeo terminou'),
              onError: (error) => setState(() => _status = 'Erro: $error'),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Demonstrações práticas de uso
class UseCaseExamples {
  
  /// Use case: Feed de vídeos estilo TikTok/Instagram Reels
  static Widget feedVertical(List<String> videoIds) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videoIds.length,
      itemBuilder: (context, index) {
        return YouTubeShortsWidget(
          videoId: videoIds[index],
          autoPlay: index == 0, // Autoplay apenas no primeiro
          showControls: true,
          onVideoEnd: () {
            // Lógica para avançar automaticamente para o próximo vídeo
            if (index < videoIds.length - 1) {
              // Implementar navegação automática
            }
          },
        );
      },
    );
  }

  /// Use case: Player de vídeo em uma página de detalhes
  static Widget playerDetalhes(String videoId, Map<String, dynamic> videoInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YouTubeShortsWidget(
          videoId: videoId,
          height: 300,
          autoPlay: false,
          showControls: true,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                videoInfo['title'] ?? 'Título do vídeo',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                videoInfo['description'] ?? 'Descrição do vídeo',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.thumb_up_outlined),
                  const SizedBox(width: 4),
                  Text('${videoInfo['likes'] ?? 0}'),
                  const SizedBox(width: 16),
                  Icon(Icons.visibility_outlined),
                  const SizedBox(width: 4),
                  Text('${videoInfo['views'] ?? 0}'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Use case: Playlist de vídeos com navegação
  static Widget playlist(List<String> videoIds, List<String> titles) {
    return _PlaylistWidget(videoIds: videoIds, titles: titles);
  }
}

/// Widget de playlist com navegação
class _PlaylistWidget extends StatefulWidget {
  final List<String> videoIds;
  final List<String> titles;

  const _PlaylistWidget({
    required this.videoIds,
    required this.titles,
  });

  @override
  _PlaylistWidgetState createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<_PlaylistWidget> {
  int _currentIndex = 0;

  void _playNext() {
    if (_currentIndex < widget.videoIds.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Player atual
        Expanded(
          flex: 3,
          child: YouTubeShortsWidget(
            key: ValueKey(_currentIndex), // Força reconstrução
            videoId: widget.videoIds[_currentIndex],
            onVideoEnd: _playNext, // Avança automaticamente
          ),
        ),
        
        // Controles de playlist
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                widget.titles[_currentIndex],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0 ? _playPrevious : null,
                    icon: const Icon(Icons.skip_previous),
                  ),
                  Text('${_currentIndex + 1} / ${widget.videoIds.length}'),
                  IconButton(
                    onPressed: _currentIndex < widget.videoIds.length - 1 ? _playNext : null,
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Lista de vídeos da playlist
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: widget.videoIds.length,
            itemBuilder: (context, index) {
              final isPlaying = index == _currentIndex;
              return ListTile(
                leading: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isPlaying ? Icons.play_arrow : Icons.video_library,
                    color: isPlaying ? Colors.red : Colors.grey,
                  ),
                ),
                title: Text(
                  widget.titles[index],
                  style: TextStyle(
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                    color: isPlaying ? Colors.red : null,
                  ),
                ),
                trailing: isPlaying ? const Icon(Icons.volume_up, color: Colors.red) : null,
                onTap: () => setState(() => _currentIndex = index),
              );
            },
          ),
        ),
      ],
    );
  }
}