import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/shorts_video_player_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase (você precisa configurar o firebase_options.dart)
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shorts Video Player Example',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: VideoPlayerExample(),
    );
  }
}

class VideoPlayerExample extends StatefulWidget {
  @override
  State<VideoPlayerExample> createState() => _VideoPlayerExampleState();
}

class _VideoPlayerExampleState extends State<VideoPlayerExample> {
  int _currentVideoIndex = 0;
  
  // Lista de vídeos de exemplo
  final List<Map<String, dynamic>> _videos = [
    {
      'cloudflareStreamId': 'seu-cloudflare-stream-id-1',
      'title': 'Primeiro Vídeo Exemplo',
      'description': 'Esta é a descrição do primeiro vídeo que demonstra as funcionalidades do widget.',
      'uploaderId': 'user123',
    },
    {
      'cloudflareStreamId': 'seu-cloudflare-stream-id-2',
      'title': 'Segundo Vídeo Exemplo',
      'description': 'Este é outro vídeo de exemplo para demonstrar a navegação entre vídeos.',
      'uploaderId': 'user456',
    },
    {
      'cloudflareStreamId': 'seu-cloudflare-stream-id-3',
      'title': 'Terceiro Vídeo',
      'description': 'Mais um exemplo de vídeo.',
      'uploaderId': 'user789',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Player
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _videos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentVideoIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return ShortsVideoPlayerWidget(
                  key: ValueKey(_videos[index]['cloudflareStreamId']),
                  videoData: _videos[index],
                  autoPlay: index == _currentVideoIndex, // Auto play apenas o vídeo atual
                  loopMode: true,
                  showControls: false, // Interface minimalista como os Shorts
                  allowFullscreen: true,
                  onVideoStart: () {
                    print('Vídeo ${index + 1} iniciado');
                  },
                  onVideoEnd: () {
                    print('Vídeo ${index + 1} terminou');
                  },
                  onViewCounted: () {
                    print('Visualização contada para vídeo ${index + 1}');
                    _showSnackBar('Visualização registrada!');
                  },
                  onError: (error) {
                    print('Erro no vídeo ${index + 1}: $error');
                    _showSnackBar('Erro ao carregar vídeo: $error');
                  },
                );
              },
            ),
            
            // Indicador de vídeo atual
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_currentVideoIndex + 1} / ${_videos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Botões de navegação (opcional para debug)
            if (false) // Defina como true para mostrar botões de debug
              Positioned(
                bottom: 50,
                right: 20,
                child: Column(
                  children: [
                    FloatingActionButton(
                      mini: true,
                      onPressed: _currentVideoIndex > 0 ? _previousVideo : null,
                      child: const Icon(Icons.arrow_upward),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _currentVideoIndex < _videos.length - 1 ? _nextVideo : null,
                      child: const Icon(Icons.arrow_downward),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _previousVideo() {
    if (_currentVideoIndex > 0) {
      setState(() {
        _currentVideoIndex--;
      });
    }
  }

  void _nextVideo() {
    if (_currentVideoIndex < _videos.length - 1) {
      setState(() {
        _currentVideoIndex++;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Exemplo de uso mais simples do widget
class SimpleVideoPlayerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ShortsVideoPlayerWidget(
        videoData: {
          'cloudflareStreamId': 'seu-cloudflare-stream-id',
          'title': 'Meu Vídeo Incrível',
          'description': 'Este é um vídeo de exemplo para demonstrar o widget ShortsVideoPlayerWidget.',
          'uploaderId': 'user123',
        },
        autoPlay: true,
        loopMode: true,
        showControls: true, // Mostra controles para este exemplo
        allowFullscreen: true,
        onVideoStart: () {
          print('Vídeo iniciado!');
        },
        onVideoEnd: () {
          print('Vídeo terminou!');
        },
        onViewCounted: () {
          print('Visualização contada!');
        },
        onError: (error) {
          print('Erro no vídeo: $error');
        },
      ),
    );
  }
}