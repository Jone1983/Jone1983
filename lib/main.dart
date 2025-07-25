import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/shorts_video_player_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  // Nota: Você precisa configurar o arquivo firebase_options.dart
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Erro ao inicializar Firebase: $e');
  }
  
  runApp(ShortsVideoPlayerApp());
}

class ShortsVideoPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shorts Video Player',
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: ShortsVideoFeed(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShortsVideoFeed extends StatefulWidget {
  @override
  State<ShortsVideoFeed> createState() => _ShortsVideoFeedState();
}

class _ShortsVideoFeedState extends State<ShortsVideoFeed> {
  int _currentVideoIndex = 0;
  final PageController _pageController = PageController();
  
  // Lista de vídeos de exemplo
  // IMPORTANTE: Substitua pelos seus próprios cloudflareStreamId
  final List<Map<String, dynamic>> _videos = [
    {
      'cloudflareStreamId': 'exemplo-stream-id-1',
      'title': 'Primeiro Vídeo Incrível',
      'description': 'Este é o primeiro vídeo de exemplo que demonstra todas as funcionalidades do widget de reprodução de vídeo estilo YouTube Shorts.',
      'uploaderId': 'usuario123',
    },
    {
      'cloudflareStreamId': 'exemplo-stream-id-2',
      'title': 'Segundo Vídeo Fantástico',
      'description': 'Um segundo vídeo para mostrar como funciona a navegação vertical entre diferentes conteúdos.',
      'uploaderId': 'usuario456',
    },
    {
      'cloudflareStreamId': 'exemplo-stream-id-3',
      'title': 'Terceiro Vídeo Espetacular',
      'description': 'Mais um exemplo demonstrando a interface minimalista e as funcionalidades de interação.',
      'uploaderId': 'usuario789',
    },
    {
      'cloudflareStreamId': 'exemplo-stream-id-4',
      'title': 'Quarto Vídeo Impressionante',
      'description': 'Demonstração de como o widget lida com diferentes tipos de conteúdo e metadados.',
      'uploaderId': 'usuario101',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Feed de vídeos com navegação vertical
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _videos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentVideoIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final videoData = _videos[index];
                
                return ShortsVideoPlayerWidget(
                  key: ValueKey(videoData['cloudflareStreamId']),
                  videoData: videoData,
                  autoPlay: index == _currentVideoIndex,
                  loopMode: true,
                  showControls: false, // Interface minimalista
                  allowFullscreen: true,
                  onVideoStart: () {
                    debugPrint('Vídeo ${index + 1} iniciado: ${videoData['title']}');
                  },
                  onVideoEnd: () {
                    debugPrint('Vídeo ${index + 1} terminou');
                  },
                  onViewCounted: () {
                    debugPrint('Visualização contada para: ${videoData['title']}');
                    _showSnackBar('✅ Visualização registrada!');
                  },
                  onError: (error) {
                    debugPrint('Erro no vídeo ${index + 1}: $error');
                    _showSnackBar('❌ Erro: $error');
                  },
                );
              },
            ),
            
            // Indicador de posição
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  '${_currentVideoIndex + 1} / ${_videos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Botão de configurações
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: _showSettingsBottomSheet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            
            // Navegação manual (apenas para debug - oculto por padrão)
            if (false) // Defina como true para mostrar controles de debug
              Positioned(
                bottom: 100,
                right: 20,
                child: Column(
                  children: [
                    _buildNavigationButton(
                      Icons.keyboard_arrow_up,
                      () => _navigateToVideo(_currentVideoIndex - 1),
                      enabled: _currentVideoIndex > 0,
                    ),
                    const SizedBox(height: 10),
                    _buildNavigationButton(
                      Icons.keyboard_arrow_down,
                      () => _navigateToVideo(_currentVideoIndex + 1),
                      enabled: _currentVideoIndex < _videos.length - 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    IconData icon,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled 
            ? Colors.black.withOpacity(0.7)
            : Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  void _navigateToVideo(int index) {
    if (index >= 0 && index < _videos.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 100,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚙️ Configurações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  'Sobre o Widget',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'ShortsVideoPlayerWidget v1.0.0',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.white),
                title: const Text(
                  'Total de Vídeos',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${_videos.length} vídeos carregados',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.play_circle, color: Colors.white),
                title: const Text(
                  'Vídeo Atual',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _videos[_currentVideoIndex]['title'],
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          title: const Text(
            '📱 ShortsVideoPlayerWidget',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Widget Flutter personalizado para reprodução de vídeos estilo YouTube Shorts.\n\n'
            '✨ Funcionalidades:\n'
            '• Interface minimalista\n'
            '• Controles por gestos\n'
            '• Integração Firebase\n'
            '• Cloudflare Stream\n'
            '• Analytics automáticas\n'
            '• Contador de visualizações\n'
            '• Tratamento de erros\n\n'
            'Desenvolvido com ❤️ para Flutter',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Fechar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget de exemplo simples para uso básico
class SimpleVideoPlayerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ShortsVideoPlayerWidget(
        videoData: {
          'cloudflareStreamId': 'seu-cloudflare-stream-id-aqui',
          'title': 'Vídeo de Exemplo',
          'description': 'Este é um exemplo de uso simples do ShortsVideoPlayerWidget.',
          'uploaderId': 'exemplo-usuario',
        },
        autoPlay: true,
        loopMode: true,
        showControls: true, // Mostra controles para este exemplo
        allowFullscreen: true,
        onVideoStart: () => debugPrint('▶️ Vídeo iniciado!'),
        onVideoEnd: () => debugPrint('⏹️ Vídeo terminou!'),
        onViewCounted: () => debugPrint('👁️ Visualização contada!'),
        onError: (error) => debugPrint('❌ Erro: $error'),
      ),
    );
  }
}