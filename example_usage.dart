import 'package:flutter/material.dart';
import 'youtube_shorts_widget.dart';

/// Example Flutter app demonstrating YouTube Shorts Widget usage
/// This can be used as a reference for FlutterFlow implementation
class YouTubeShortsExampleApp extends StatelessWidget {
  const YouTubeShortsExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Shorts Widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({Key? key}) : super(key: key);

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  // Sample YouTube Shorts video IDs for demonstration
  final List<String> sampleVideoIds = [
    'dQw4w9WgXcQ', // Rick Roll (classic example)
    'ZbZSe6N_BXs', // Another sample video
    'jNQXAC9IVRw', // Another sample video
  ];

  int currentVideoIndex = 0;
  bool isPlaying = false;
  String? lastError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Shorts Widget Examples'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Basic Usage
            _buildSectionTitle('1. Basic Usage'),
            _buildBasicExample(),
            
            const SizedBox(height: 32),
            
            // Example 2: Custom Size
            _buildSectionTitle('2. Custom Size'),
            _buildCustomSizeExample(),
            
            const SizedBox(height: 32),
            
            // Example 3: With Callbacks
            _buildSectionTitle('3. With Event Callbacks'),
            _buildCallbackExample(),
            
            const SizedBox(height: 16),
            
            // Status Display
            _buildStatusDisplay(),
            
            const SizedBox(height: 32),
            
            // Example 4: URL Parser Demo
            _buildSectionTitle('4. URL Parser Demo'),
            _buildUrlParserExample(),
            
            const SizedBox(height: 32),
            
            // Example 5: Grid Layout
            _buildSectionTitle('5. Grid Layout'),
            _buildGridExample(),
            
            const SizedBox(height: 32),
            
            // Control Panel
            _buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildBasicExample() {
    return Center(
      child: YouTubeShortsWidget(
        videoId: sampleVideoIds[0],
      ),
    );
  }

  Widget _buildCustomSizeExample() {
    return Center(
      child: YouTubeShortsWidget(
        videoId: sampleVideoIds[1],
        width: 250,
        height: 400,
        showControls: true,
        allowFullscreen: true,
      ),
    );
  }

  Widget _buildCallbackExample() {
    return Center(
      child: YouTubeShortsWidget(
        videoId: sampleVideoIds[currentVideoIndex],
        width: 300,
        height: 500,
        autoPlay: false,
        showControls: true,
        onVideoStart: () {
          setState(() {
            isPlaying = true;
            lastError = null;
          });
          _showSnackBar('Video started playing!', Colors.green);
        },
        onVideoEnd: () {
          setState(() {
            isPlaying = false;
          });
          _showSnackBar('Video ended!', Colors.blue);
        },
        onError: (error) {
          setState(() {
            isPlaying = false;
            lastError = error;
          });
          _showSnackBar('Error: $error', Colors.red);
        },
      ),
    );
  }

  Widget _buildStatusDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPlaying ? Icons.play_circle : Icons.pause_circle,
                  color: isPlaying ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(isPlaying ? 'Playing' : 'Paused'),
              ],
            ),
            if (lastError != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Last Error: $lastError',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUrlParserExample() {
    const sampleUrls = [
      'https://www.youtube.com/shorts/dQw4w9WgXcQ',
      'https://youtu.be/ZbZSe6N_BXs',
      'https://www.youtube.com/watch?v=jNQXAC9IVRw',
    ];

    return Column(
      children: [
        const Text(
          'The widget can parse various YouTube URL formats:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...sampleUrls.map((url) => _buildUrlExample(url)).toList(),
      ],
    );
  }

  Widget _buildUrlExample(String url) {
    final videoId = extractVideoIdFromShortsUrl(url);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'URL: $url',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Extracted ID: $videoId',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridExample() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 9 / 16, // Shorts aspect ratio
      ),
      itemCount: sampleVideoIds.length,
      itemBuilder: (context, index) {
        return YouTubeShortsWidget(
          videoId: sampleVideoIds[index],
          width: 150,
          height: 267,
          showControls: true,
          autoPlay: false,
        );
      },
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control Panel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Video Selector
            const Text('Select Video:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(
                sampleVideoIds.length,
                (index) => ChoiceChip(
                  label: Text('Video ${index + 1}'),
                  selected: currentVideoIndex == index,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        currentVideoIndex = index;
                      });
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            const Text('Quick Actions:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      currentVideoIndex = (currentVideoIndex + 1) % sampleVideoIds.length;
                    });
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Next Video'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      lastError = null;
                      isPlaying = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Main function for running the example app
void main() {
  runApp(const YouTubeShortsExampleApp());
}