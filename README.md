# ShortsVideoPlayerWidget

Um widget Flutter personalizado para reprodução de vídeos estilo YouTube Shorts, otimizado para Cloudflare Stream e integrado com Firebase.

## ✨ Funcionalidades

- 📱 **Interface estilo Shorts**: UI minimalista e intuitiva
- ⚡ **Performance otimizada**: Carregamento rápido e reprodução suave
- 🎮 **Controles por gestos**: 
  - Toque único para pausar/retomar
  - Toque duplo para avançar/retroceder (10s)
- 📊 **Analytics integradas**: Firebase Analytics automático
- 👁️ **Contador de visualizações**: Sistema único por usuário/sessão
- 🔄 **Reprodução em loop**: Opcional
- 🔇 **Controle de volume**: Mute/unmute fácil
- ⚠️ **Tratamento de erros**: Interface de retry elegante
- 🔧 **Altamente configurável**: Múltiplos parâmetros personalizáveis

## 🚀 Instalação

### 1. Dependências

Adicione as seguintes dependências no seu `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Video player
  video_player: ^2.8.1
  chewie: ^1.7.5
  
  # Firebase
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0
  firebase_analytics: ^10.7.4
  
  # HTTP requests
  http: ^1.1.2
  
  # UI components
  flutter_spinkit: ^5.2.0
```

### 2. Configuração Firebase

1. Configure o Firebase em seu projeto Flutter
2. Adicione os arquivos de configuração (`google-services.json` para Android, `GoogleService-Info.plist` para iOS)
3. Configure as regras do Firestore para permitir escrita na coleção `video_views`

### 3. Configuração Cloudflare Stream

Certifique-se de ter:
- Uma conta Cloudflare Stream
- IDs de vídeo válidos do Cloudflare Stream
- (Opcional) Player Embeds assinados configurados para vídeos privados

## 📖 Uso Básico

```dart
import 'package:flutter/material.dart';
import 'widgets/shorts_video_player_widget.dart';

class MyVideoPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShortsVideoPlayerWidget(
        videoData: {
          'cloudflareStreamId': 'seu-cloudflare-stream-id', // OBRIGATÓRIO
          'title': 'Título do Vídeo',
          'description': 'Descrição do vídeo',
          'uploaderId': 'user123',
        },
        autoPlay: true,
        loopMode: true,
        showControls: false,
        allowFullscreen: true,
        onVideoStart: () => print('Vídeo iniciado'),
        onVideoEnd: () => print('Vídeo terminou'),
        onViewCounted: () => print('Visualização contada'),
        onError: (error) => print('Erro: $error'),
      ),
    );
  }
}
```

## 🎛️ Parâmetros

### Obrigatórios

- **`videoData`** `Map<String, dynamic>`: Dados do vídeo
  - **`cloudflareStreamId`** `String`: ID do vídeo no Cloudflare Stream (OBRIGATÓRIO)
  - `title` `String?`: Título do vídeo (opcional)
  - `description` `String?`: Descrição do vídeo (opcional)
  - `uploaderId` `String?`: ID do usuário que fez upload (opcional)

### Opcionais

- **`autoPlay`** `bool`: Se o vídeo deve iniciar automaticamente (padrão: `true`)
- **`loopMode`** `bool`: Se o vídeo deve se repetir (padrão: `true`)
- **`showControls`** `bool`: Se deve mostrar a barra de progresso (padrão: `false`)
- **`allowFullscreen`** `bool`: Se permite tela cheia (padrão: `true`)

### Callbacks

- **`onVideoStart`** `VoidCallback?`: Chamado quando o vídeo inicia
- **`onVideoEnd`** `VoidCallback?`: Chamado quando o vídeo termina
- **`onViewCounted`** `VoidCallback?`: Chamado quando uma visualização é registrada
- **`onError`** `Function(String error)?`: Chamado em caso de erro

## 🎮 Controles

### Gestos

- **Toque único**: Pausa/retoma o vídeo
- **Toque duplo esquerdo**: Retrocede 10 segundos
- **Toque duplo direito**: Avança 10 segundos

### Botões

- **Mute/Unmute**: Botão no canto superior direito
- **Retry**: Aparece em caso de erro para tentar novamente

## 📱 Exemplo Completo (Estilo Feed)

```dart
class VideoFeed extends StatefulWidget {
  @override
  State<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  final List<Map<String, dynamic>> videos = [
    {
      'cloudflareStreamId': 'video-id-1',
      'title': 'Primeiro Vídeo',
      'description': 'Descrição do primeiro vídeo',
      'uploaderId': 'user1',
    },
    {
      'cloudflareStreamId': 'video-id-2',
      'title': 'Segundo Vídeo',
      'description': 'Descrição do segundo vídeo',
      'uploaderId': 'user2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return ShortsVideoPlayerWidget(
            key: ValueKey(videos[index]['cloudflareStreamId']),
            videoData: videos[index],
            autoPlay: true,
            loopMode: true,
            showControls: false,
            onViewCounted: () {
              // Lógica adicional quando visualização é contada
            },
          );
        },
      ),
    );
  }
}
```

## 🔥 Firebase Integration

### Analytics Events

O widget registra automaticamente os seguintes eventos:

- `video_played`: Quando o vídeo é reproduzido
- `video_paused`: Quando o vídeo é pausado
- `video_completed`: Quando o vídeo termina
- `video_error`: Quando ocorre um erro
- `video_seek`: Quando o usuário pula para frente/trás
- `video_view_counted`: Quando uma visualização é contada

### Firestore Collections

- **`video_views`**: Armazena visualizações únicas
  - `videoId`: ID do vídeo
  - `userId`: ID do usuário
  - `sessionId`: ID da sessão
  - `timestamp`: Timestamp da visualização
  - `metadata`: Metadados do vídeo

## ⚡ Otimizações de Performance

- **Lazy loading**: Vídeos carregam apenas quando necessário
- **Memory management**: Controllers são descartados adequadamente
- **Session tracking**: Evita contagem múltipla de visualizações
- **Error handling**: Recuperação inteligente de erros de rede

## 🛠️ Customização

### URL do Cloudflare Stream

O widget constrói automaticamente a URL do vídeo:
```
https://customer-{ACCOUNT_ID}.cloudflarestream.com/{STREAM_ID}/manifest/video.m3u8
```

Para vídeos privados, você pode modificar a lógica de URL no método `_initializeVideo()`.

### Styling

Personalize cores, tamanhos e animações modificando as constantes no widget:

```dart
// Cores
playedColor: Colors.red,          // Cor da barra de progresso
backgroundColor: Colors.black,     // Cor de fundo

// Animações
Duration(milliseconds: 300),       // Duração das animações
Duration(seconds: 10),            // Tempo de seek
```

## 📋 Requisitos

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Firebase projeto configurado
- Cloudflare Stream conta ativa

## 🐛 Troubleshooting

### Vídeo não carrega

1. Verifique se o `cloudflareStreamId` está correto
2. Confirme a conectividade com a internet
3. Teste a URL do vídeo diretamente no navegador

### Firebase errors

1. Verifique se o Firebase está inicializado
2. Confirme as regras do Firestore
3. Teste a conectividade com o Firebase

### Performance issues

1. Use `Key` únicos para cada widget
2. Descarte controllers adequadamente
3. Limite o número de vídeos carregados simultaneamente

## 📄 Licença

Este projeto está licenciado sob a MIT License.

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor, abra uma issue ou pull request.

## 📞 Suporte

Para suporte e dúvidas, abra uma issue no repositório.
