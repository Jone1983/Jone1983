import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_shorts_widget_demo/widgets/youtube_shorts_widget.dart';

void main() {
  group('extractVideoIdFromShortsUrl', () {
    test('deve extrair ID de URL do YouTube Shorts', () {
      const url = 'https://youtube.com/shorts/dQw4w9WgXcQ';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });

    test('deve extrair ID de URL padrão do YouTube', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });

    test('deve extrair ID de URL encurtada youtu.be', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });

    test('deve extrair ID de URL com parâmetros adicionais', () {
      const url = 'https://www.youtube.com/watch?si=abc123&v=dQw4w9WgXcQ&feature=share';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });

    test('deve extrair ID de URL do YouTube Music', () {
      const url = 'https://music.youtube.com/watch?v=dQw4w9WgXcQ';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });

    test('deve extrair ID de URL mobile', () {
      const url = 'https://m.youtube.com/watch?v=dQw4w9WgXcQ';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });

    test('deve reconhecer ID válido diretamente', () {
      const videoId = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(videoId);
      
      expect(result, equals(videoId));
    });

    test('deve retornar null para URL inválida', () {
      const url = 'https://example.com/invalid';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, isNull);
    });

    test('deve retornar null para string vazia', () {
      const url = '';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, isNull);
    });

    test('deve remover espaços em branco', () {
      const url = '  https://youtube.com/shorts/dQw4w9WgXcQ  ';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });

    test('deve lidar com URLs complexas com múltiplos parâmetros', () {
      const url = 'https://youtube.com/watch?list=PLrAXtmRdnEQy4Qy2-BfvsXkfYZCjV6hMi&index=1&v=dQw4w9WgXcQ&t=10s';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });

    test('deve retornar null para ID inválido (muito curto)', () {
      const url = 'dQw4w9Wg'; // Menos de 11 caracteres
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, isNull);
    });

    test('deve retornar null para ID inválido (muito longo)', () {
      const url = 'dQw4w9WgXcQextra'; // Mais de 11 caracteres
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, isNull);
    });
  });

  group('YouTubeShortsWidget', () {
    testWidgets('deve criar widget com parâmetros obrigatórios', (WidgetTester tester) async {
      // Este teste verifica se o widget pode ser criado com apenas o parâmetro obrigatório
      expect(
        () => const YouTubeShortsWidget(videoId: 'dQw4w9WgXcQ'),
        returnsNormally,
      );
    });

    testWidgets('deve criar widget com todos os parâmetros', (WidgetTester tester) async {
      // Teste para verificar se todos os parâmetros funcionam corretamente
      expect(
        () => YouTubeShortsWidget(
          videoId: 'dQw4w9WgXcQ',
          width: 300,
          height: 400,
          autoPlay: true,
          showControls: false,
          allowFullscreen: true,
          onVideoStart: () {},
          onVideoEnd: () {},
          onError: (error) {},
        ),
        returnsNormally,
      );
    });

    test('deve ter valores padrão corretos', () {
      const widget = YouTubeShortsWidget(videoId: 'test');
      
      expect(widget.videoId, equals('test'));
      expect(widget.width, isNull);
      expect(widget.height, isNull);
      expect(widget.autoPlay, isFalse);
      expect(widget.showControls, isTrue);
      expect(widget.allowFullscreen, isTrue);
      expect(widget.onVideoStart, isNull);
      expect(widget.onVideoEnd, isNull);
      expect(widget.onError, isNull);
    });
  });
}

/// Testes adicionais para casos específicos
void testCasosEspecificos() {
  group('Casos específicos de URLs', () {
    test('deve lidar com URLs com diferentes protocolos', () {
      final urls = [
        'http://youtube.com/shorts/dQw4w9WgXcQ',
        'https://youtube.com/shorts/dQw4w9WgXcQ',
        'http://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      ];

      for (final url in urls) {
        final result = extractVideoIdFromShortsUrl(url);
        expect(result, equals('dQw4w9WgXcQ'), reason: 'Falhou para URL: $url');
      }
    });

    test('deve lidar com subdomínios diferentes', () {
      final urls = [
        'https://youtube.com/shorts/dQw4w9WgXcQ',
        'https://www.youtube.com/shorts/dQw4w9WgXcQ',
        'https://m.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://music.youtube.com/watch?v=dQw4w9WgXcQ',
      ];

      for (final url in urls) {
        final result = extractVideoIdFromShortsUrl(url);
        expect(result, equals('dQw4w9WgXcQ'), reason: 'Falhou para URL: $url');
      }
    });

    test('deve extrair apenas o primeiro ID válido encontrado', () {
      const url = 'https://youtube.com/watch?v=dQw4w9WgXcQ&feature=related&v=abc123456';
      const expected = 'dQw4w9WgXcQ';
      
      final result = extractVideoIdFromShortsUrl(url);
      
      expect(result, equals(expected));
    });
  });
}