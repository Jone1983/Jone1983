import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Gerenciador de cache para otimizar performance do player de vídeo
class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  final Map<String, VideoPlayerController> _cachedControllers = {};
  final Map<String, Timer> _disposalTimers = {};
  final int _maxCacheSize = 3; // Máximo de 3 vídeos em cache
  final Duration _cacheTimeout = const Duration(minutes: 5);

  /// Pré-carrega um vídeo para cache
  Future<VideoPlayerController?> preloadVideo(String cloudflareStreamId) async {
    try {
      // Se já está no cache, retorna o controller existente
      if (_cachedControllers.containsKey(cloudflareStreamId)) {
        _cancelDisposal(cloudflareStreamId);
        return _cachedControllers[cloudflareStreamId];
      }

      // Se cache está cheio, remove o mais antigo
      if (_cachedControllers.length >= _maxCacheSize) {
        _removeOldestCache();
      }

      // Cria URL do vídeo
      final videoUrl = _buildCloudflareUrl(cloudflareStreamId);
      
      // Cria e inicializa o controller
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();

      // Adiciona ao cache
      _cachedControllers[cloudflareStreamId] = controller;
      
      // Agenda remoção automática após timeout
      _scheduleDisposal(cloudflareStreamId);

      debugPrint('Vídeo pré-carregado: $cloudflareStreamId');
      return controller;

    } catch (e) {
      debugPrint('Erro ao pré-carregar vídeo $cloudflareStreamId: $e');
      return null;
    }
  }

  /// Obtém um controller do cache ou cria um novo
  Future<VideoPlayerController?> getController(String cloudflareStreamId) async {
    // Verifica se está no cache
    if (_cachedControllers.containsKey(cloudflareStreamId)) {
      _cancelDisposal(cloudflareStreamId);
      return _cachedControllers[cloudflareStreamId];
    }

    // Se não está no cache, carrega normalmente
    return await preloadVideo(cloudflareStreamId);
  }

  /// Remove um controller específico do cache
  void removeFromCache(String cloudflareStreamId) {
    _cancelDisposal(cloudflareStreamId);
    
    final controller = _cachedControllers.remove(cloudflareStreamId);
    controller?.dispose();
    
    debugPrint('Vídeo removido do cache: $cloudflareStreamId');
  }

  /// Agenda a remoção automática de um vídeo do cache
  void _scheduleDisposal(String cloudflareStreamId) {
    _cancelDisposal(cloudflareStreamId);
    
    _disposalTimers[cloudflareStreamId] = Timer(_cacheTimeout, () {
      removeFromCache(cloudflareStreamId);
    });
  }

  /// Cancela a remoção automática de um vídeo
  void _cancelDisposal(String cloudflareStreamId) {
    _disposalTimers[cloudflareStreamId]?.cancel();
    _disposalTimers.remove(cloudflareStreamId);
  }

  /// Remove o cache mais antigo
  void _removeOldestCache() {
    if (_cachedControllers.isEmpty) return;
    
    final oldestKey = _cachedControllers.keys.first;
    removeFromCache(oldestKey);
  }

  /// Constrói a URL do Cloudflare Stream
  String _buildCloudflareUrl(String cloudflareStreamId) {
    // URL padrão do Cloudflare Stream
    return 'https://customer-${cloudflareStreamId.split('-')[0]}.cloudflarestream.com/$cloudflareStreamId/manifest/video.m3u8';
  }

  /// Limpa todo o cache
  void clearCache() {
    // Cancela todos os timers
    for (final timer in _disposalTimers.values) {
      timer.cancel();
    }
    _disposalTimers.clear();

    // Descarta todos os controllers
    for (final controller in _cachedControllers.values) {
      controller.dispose();
    }
    _cachedControllers.clear();

    debugPrint('Cache de vídeos limpo');
  }

  /// Retorna informações sobre o cache
  Map<String, dynamic> getCacheInfo() {
    return {
      'cached_videos': _cachedControllers.length,
      'max_cache_size': _maxCacheSize,
      'cached_ids': _cachedControllers.keys.toList(),
      'pending_disposals': _disposalTimers.length,
    };
  }

  /// Pré-carrega uma lista de vídeos em sequência
  Future<void> preloadVideoList(List<String> cloudflareStreamIds) async {
    for (int i = 0; i < cloudflareStreamIds.length && i < _maxCacheSize; i++) {
      await preloadVideo(cloudflareStreamIds[i]);
    }
  }
}

/// Extensão para facilitar o uso do cache no widget
extension ShortsVideoPlayerCache on VideoCacheManager {
  /// Pré-carrega vídeos adjacentes para navegação suave
  Future<void> preloadAdjacentVideos(
    List<Map<String, dynamic>> videoList,
    int currentIndex,
  ) async {
    final List<String> toPreload = [];
    
    // Adiciona vídeo anterior
    if (currentIndex > 0) {
      final prevId = videoList[currentIndex - 1]['cloudflareStreamId'];
      if (prevId != null) toPreload.add(prevId);
    }
    
    // Adiciona próximo vídeo
    if (currentIndex < videoList.length - 1) {
      final nextId = videoList[currentIndex + 1]['cloudflareStreamId'];
      if (nextId != null) toPreload.add(nextId);
    }
    
    // Pré-carrega os vídeos
    for (final id in toPreload) {
      unawaited(preloadVideo(id));
    }
  }
}