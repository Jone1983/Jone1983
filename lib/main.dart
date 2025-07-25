import 'package:flutter/material.dart';
import 'widgets/youtube_shorts_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Shorts Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _urlController = TextEditingController();
  String? _currentVideoId;
  String _statusMessage = '';

  // Alguns IDs de exemplo do YouTube Shorts
  final List<String> _exampleVideos = [
    'dQw4w9WgXcQ', // Rick Roll (vídeo normal usado como exemplo)
    'jNQXAC9IVRw', // Exemplo de Shorts
    'kJQP7kiw5Fk', // Outro exemplo
  ];

  @override
  void initState() {
    super.initState();
    // Carrega um vídeo de exemplo inicialmente
    _currentVideoId = _exampleVideos.first;
  }

  void _loadVideoFromUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar('Por favor, insira uma URL do YouTube');
      return;
    }

    final videoId = extractVideoIdFromShortsUrl(url);
    if (videoId != null) {
      setState(() {
        _currentVideoId = videoId;
        _statusMessage = 'Vídeo carregado: $videoId';
      });
      _showSnackBar('Vídeo carregado com sucesso!');
    } else {
      _showSnackBar('URL do YouTube inválida');
    }
  }

  void _loadExampleVideo(String videoId) {
    setState(() {
      _currentVideoId = videoId;
      _statusMessage = 'Exemplo carregado: $videoId';
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('YouTube Shorts Widget Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de entrada para URL
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carregar vídeo por URL:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'Cole aqui a URL do YouTube ou YouTube Shorts',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _loadVideoFromUrl,
                      icon: const Icon(Icons.link),
                      label: const Text('Carregar Vídeo'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Vídeos de exemplo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vídeos de exemplo:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _exampleVideos.map((videoId) {
                        return ElevatedButton(
                          onPressed: () => _loadExampleVideo(videoId),
                          child: Text('Exemplo ${_exampleVideos.indexOf(videoId) + 1}'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status message
            if (_statusMessage.isNotEmpty)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Widget do YouTube Shorts
            if (_currentVideoId != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YouTube Shorts Widget:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      YouTubeShortsWidget(
                        videoId: _currentVideoId!,
                        height: 400,
                        autoPlay: false,
                        showControls: true,
                        allowFullscreen: true,
                        onVideoStart: () {
                          setState(() {
                            _statusMessage = 'Vídeo iniciado!';
                          });
                          _showSnackBar('Vídeo iniciou!');
                        },
                        onVideoEnd: () {
                          setState(() {
                            _statusMessage = 'Vídeo terminou!';
                          });
                          _showSnackBar('Vídeo terminou!');
                        },
                        onError: (errorMessage) {
                          setState(() {
                            _statusMessage = 'Erro: $errorMessage';
                          });
                          _showSnackBar('Erro no vídeo: $errorMessage');
                        },
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Informações sobre funcionalidades
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Funcionalidades do Widget:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ Carregamento de vídeos do YouTube e Shorts'),
                    const Text('✅ Indicador de progresso durante carregamento'),
                    const Text('✅ Botão para abrir no YouTube (canto superior direito)'),
                    const Text('✅ Tratamento de erros com botão "Tentar Novamente"'),
                    const Text('✅ Callbacks para eventos (início, fim, erro)'),
                    const Text('✅ Configurações personalizáveis (tamanho, autoplay, controles)'),
                    const Text('✅ Função utilitária para extrair ID de URLs'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}