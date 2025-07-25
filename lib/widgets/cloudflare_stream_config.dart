import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Configurações para integração com Cloudflare Stream
class CloudflareStreamConfig {
  static const String _baseUrl = 'https://api.cloudflare.com/client/v4';
  
  final String accountId;
  final String apiToken;
  final bool useSignedUrls;
  final Duration urlExpirationTime;

  const CloudflareStreamConfig({
    required this.accountId,
    required this.apiToken,
    this.useSignedUrls = false,
    this.urlExpirationTime = const Duration(hours: 1),
  });

  /// Constrói URL padrão do Cloudflare Stream
  String buildStreamUrl(String streamId) {
    return 'https://customer-$accountId.cloudflarestream.com/$streamId/manifest/video.m3u8';
  }

  /// Constrói URL para thumbnail
  String buildThumbnailUrl(String streamId, {int? time}) {
    final timeParam = time != null ? '?time=${time}s' : '';
    return 'https://customer-$accountId.cloudflarestream.com/$streamId/thumbnails/thumbnail.jpg$timeParam';
  }

  /// Obtém informações detalhadas do vídeo via API
  Future<Map<String, dynamic>?> getVideoInfo(String streamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/accounts/$accountId/stream/$streamId'),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'];
      }
    } catch (e) {
      debugPrint('Erro ao obter informações do vídeo: $e');
    }
    return null;
  }

  /// Gera URL assinada para vídeos privados
  Future<String?> generateSignedUrl(
    String streamId, {
    Map<String, dynamic>? restrictions,
  }) async {
    if (!useSignedUrls) {
      return buildStreamUrl(streamId);
    }

    try {
      final body = {
        'id': streamId,
        'exp': DateTime.now()
            .add(urlExpirationTime)
            .millisecondsSinceEpoch ~/ 1000,
        if (restrictions != null) ...restrictions,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/$accountId/stream/$streamId/token'),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result']['token'];
      }
    } catch (e) {
      debugPrint('Erro ao gerar URL assinada: $e');
    }

    // Fallback para URL padrão
    return buildStreamUrl(streamId);
  }

  /// Lista vídeos da conta
  Future<List<Map<String, dynamic>>> listVideos({
    int? limit,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$_baseUrl/accounts/$accountId/stream')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['result']);
      }
    } catch (e) {
      debugPrint('Erro ao listar vídeos: $e');
    }
    return [];
  }

  /// Obtém estatísticas de visualização de um vídeo
  Future<Map<String, dynamic>?> getVideoAnalytics(
    String streamId, {
    DateTime? since,
    DateTime? until,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (since != null) {
        queryParams['since'] = since.toIso8601String();
      }
      if (until != null) {
        queryParams['until'] = until.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/accounts/$accountId/stream/analytics')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'];
      }
    } catch (e) {
      debugPrint('Erro ao obter analytics: $e');
    }
    return null;
  }

  /// Upload de vídeo para Cloudflare Stream
  Future<String?> uploadVideo({
    required String filePath,
    Map<String, String>? metadata,
  }) async {
    try {
      // Primeiro, obter URL de upload
      final uploadResponse = await http.post(
        Uri.parse('$_baseUrl/accounts/$accountId/stream/direct_upload'),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'maxDurationSeconds': 3600,
          if (metadata != null) 'meta': metadata,
        }),
      );

      if (uploadResponse.statusCode != 200) return null;

      final uploadData = json.decode(uploadResponse.body);
      final uploadUrl = uploadData['result']['uploadURL'];
      final streamId = uploadData['result']['uid'];

      // Upload do arquivo
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final uploadResult = await request.send();
      
      if (uploadResult.statusCode == 200) {
        return streamId;
      }
    } catch (e) {
      debugPrint('Erro ao fazer upload: $e');
    }
    return null;
  }

  /// Configurações de qualidade de vídeo
  static const Map<String, String> qualityPresets = {
    'mobile': '360p',
    'sd': '480p',
    'hd': '720p',
    'fullhd': '1080p',
    'auto': 'auto',
  };

  /// Obtém URL com qualidade específica
  String buildStreamUrlWithQuality(String streamId, String quality) {
    if (quality == 'auto') {
      return buildStreamUrl(streamId);
    }
    return 'https://customer-$accountId.cloudflarestream.com/$streamId/manifest/video_$quality.m3u8';
  }
}

/// Classe para gerenciar configurações de Player Embeds assinados
class SignedPlayerEmbedConfig {
  final String streamId;
  final String? domain;
  final List<String>? allowedOrigins;
  final bool requireSignedUrls;
  final Duration tokenExpiration;
  final Map<String, dynamic>? customData;

  const SignedPlayerEmbedConfig({
    required this.streamId,
    this.domain,
    this.allowedOrigins,
    this.requireSignedUrls = true,
    this.tokenExpiration = const Duration(hours: 1),
    this.customData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': streamId,
      'exp': DateTime.now()
          .add(tokenExpiration)
          .millisecondsSinceEpoch ~/ 1000,
      if (domain != null) 'aud': domain,
      if (allowedOrigins != null) 'origins': allowedOrigins,
      if (customData != null) ...customData!,
    };
  }
}

/// Utilitários para Cloudflare Stream
class CloudflareStreamUtils {
  /// Valida se um Stream ID tem formato correto
  static bool isValidStreamId(String streamId) {
    // Stream IDs são geralmente UUIDs ou identificadores específicos
    final regex = RegExp(r'^[a-fA-F0-9]{32}$|^[a-fA-F0-9-]{36}$');
    return regex.hasMatch(streamId);
  }

  /// Extrai Stream ID de uma URL do Cloudflare
  static String? extractStreamIdFromUrl(String url) {
    final regex = RegExp(r'cloudflarestream\.com/([a-fA-F0-9-]{32,36})');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  /// Converte duração em segundos para formato de timestamp
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// Gera URLs de thumbnail para diferentes momentos do vídeo
  static List<String> generateThumbnailUrls(
    String accountId,
    String streamId,
    int videoDuration, {
    int thumbnailCount = 10,
  }) {
    final thumbnails = <String>[];
    final interval = videoDuration ~/ thumbnailCount;

    for (int i = 0; i < thumbnailCount; i++) {
      final time = i * interval;
      thumbnails.add(
        'https://customer-$accountId.cloudflarestream.com/$streamId/thumbnails/thumbnail.jpg?time=${time}s',
      );
    }

    return thumbnails;
  }
}