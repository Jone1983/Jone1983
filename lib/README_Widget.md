# YouTubeShortsWidget

Um widget Flutter personalizado para exibir vídeos do YouTube Shorts com funcionalidades avançadas.

## Características

- ✅ **Carregamento de vídeos**: Suporte para vídeos do YouTube e YouTube Shorts
- ✅ **Indicador de progresso**: Mostra uma animação de carregamento durante o carregamento do vídeo
- ✅ **Botão "Abrir no YouTube"**: Botão no canto superior direito para abrir o vídeo no aplicativo YouTube
- ✅ **Tratamento de erros**: Interface amigável para erros com botão "Tentar Novamente"
- ✅ **Callbacks de eventos**: Callbacks para início, fim e erro do vídeo
- ✅ **Configurações personalizáveis**: Controle de tamanho, autoplay, controles e tela cheia
- ✅ **Função utilitária**: Função para extrair ID de vídeo de diferentes URLs do YouTube

## Instalação

Adicione as seguintes dependências no seu `pubspec.yaml`:

```yaml
dependencies:
  youtube_player_flutter: ^8.1.2
  url_launcher: ^6.2.2
```

## Uso Básico

```dart
import 'package:flutter/material.dart';
import 'widgets/youtube_shorts_widget.dart';

class ExemploUso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YouTubeShortsWidget(
        videoId: 'dQw4w9WgXcQ',
        height: 400,
        onVideoStart: () => print('Vídeo iniciou!'),
        onVideoEnd: () => print('Vídeo terminou!'),
        onError: (error) => print('Erro: $error'),
      ),
    );
  }
}
```

## Parâmetros

### Obrigatórios
- **`videoId`** (String): ID do vídeo do YouTube

### Opcionais
- **`width`** (double?): Largura do widget
- **`height`** (double?): Altura do widget (padrão: 300)
- **`autoPlay`** (bool): Se o vídeo toca automaticamente (padrão: false)
- **`showControls`** (bool): Se mostra os controles do player (padrão: true)
- **`allowFullscreen`** (bool): Se permite tela cheia (padrão: true)

### Callbacks
- **`onVideoStart`** (VoidCallback?): Chamado quando o vídeo inicia
- **`onVideoEnd`** (VoidCallback?): Chamado quando o vídeo termina
- **`onError`** (Function(String)?): Chamado quando ocorre um erro

## Função Utilitária

### extractVideoIdFromShortsUrl(String url)

Extrai o ID do vídeo de diferentes formatos de URL do YouTube:

```dart
// Exemplos de URLs suportadas:
String? videoId;

videoId = extractVideoIdFromShortsUrl('https://youtube.com/shorts/dQw4w9WgXcQ');
// Retorna: 'dQw4w9WgXcQ'

videoId = extractVideoIdFromShortsUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
// Retorna: 'dQw4w9WgXcQ'

videoId = extractVideoIdFromShortsUrl('https://youtu.be/dQw4w9WgXcQ');
// Retorna: 'dQw4w9WgXcQ'

videoId = extractVideoIdFromShortsUrl('dQw4w9WgXcQ');
// Retorna: 'dQw4w9WgXcQ' (se for um ID válido)
```

### URLs Suportadas
- `youtube.com/shorts/VIDEO_ID`
- `youtube.com/watch?v=VIDEO_ID`
- `youtu.be/VIDEO_ID`
- `youtube.com/watch?param1=value&v=VIDEO_ID&param2=value`
- `music.youtube.com/watch?v=VIDEO_ID`
- `m.youtube.com/watch?v=VIDEO_ID`
- IDs diretos de vídeo (11 caracteres)

## Exemplo Avançado

```dart
YouTubeShortsWidget(
  videoId: 'seu_video_id_aqui',
  width: 350,
  height: 500,
  autoPlay: true,
  showControls: false,
  allowFullscreen: false,
  onVideoStart: () {
    print('Vídeo iniciou!');
    // Sua lógica aqui
  },
  onVideoEnd: () {
    print('Vídeo terminou!');
    // Carregar próximo vídeo, por exemplo
  },
  onError: (errorMessage) {
    print('Erro no vídeo: $errorMessage');
    // Mostrar mensagem de erro personalizada
  },
)
```

## Estados do Widget

### 1. Carregamento
- Mostra um `CircularProgressIndicator` com a cor vermelha do YouTube
- Texto "Carregando vídeo..."

### 2. Reprodução
- Exibe o player do YouTube com todos os controles
- Botão "Abrir no YouTube" no canto superior direito

### 3. Erro
- Ícone de erro vermelho
- Mensagem "Erro ao carregar vídeo"
- Descrição detalhada do erro
- Botão "Tentar Novamente" para recarregar

## Funcionalidades Especiais

### Botão "Abrir no YouTube"
- Localizado no canto superior direito do player
- Abre o vídeo no aplicativo YouTube nativo
- Fallback para navegador se o app não estiver instalado

### Tratamento de Erros Robusto
- Captura erros de rede, vídeos privados/removidos
- Interface amigável com opção de retry
- Callbacks para tratamento personalizado de erros

### Design Responsivo
- Bordas arredondadas
- Cores consistentes com o tema do YouTube
- Adaptação automática ao tamanho especificado

## Considerações Técnicas

- O widget usa o `youtube_player_flutter` para reprodução de vídeos
- Requer conexão com internet para funcionar
- O `url_launcher` é usado para abrir links externos
- Gerenciamento automático de estado do player
- Dispose automático de recursos para evitar vazamentos de memória

## Limitações

- Depende da API do YouTube (vídeos privados/removidos não funcionarão)
- Requer permissões de internet
- O autoplay pode não funcionar em alguns dispositivos devido a políticas do sistema
- Alguns vídeos podem ter restrições de incorporação