# YouTubeShortsWidget - Flutter

Um widget Flutter personalizado para exibir vídeos do YouTube Shorts com funcionalidades avançadas.

## 🚀 Funcionalidades

- ✅ **Carregamento de vídeos**: Suporte para vídeos do YouTube e YouTube Shorts
- ✅ **Indicador de progresso**: Animação de carregamento durante o carregamento do vídeo
- ✅ **Botão "Abrir no YouTube"**: Botão no canto superior direito para abrir no app YouTube
- ✅ **Tratamento de erros**: Interface amigável para erros com botão "Tentar Novamente"
- ✅ **Callbacks de eventos**: Callbacks para início, fim e erro do vídeo
- ✅ **Configurações personalizáveis**: Controle de tamanho, autoplay, controles e tela cheia
- ✅ **Função utilitária**: Função para extrair ID de vídeo de diferentes URLs do YouTube

## 📦 Instalação

Adicione as dependências no seu `pubspec.yaml`:

```yaml
dependencies:
  youtube_player_flutter: ^8.1.2
  url_launcher: ^6.2.2
```

## 🔧 Uso Básico

```dart
import 'package:flutter/material.dart';
import 'widgets/youtube_shorts_widget.dart';

YouTubeShortsWidget(
  videoId: 'dQw4w9WgXcQ',
  height: 400,
  onVideoStart: () => print('Vídeo iniciou!'),
  onVideoEnd: () => print('Vídeo terminou!'),
  onError: (error) => print('Erro: $error'),
)
```

## 📱 Demo

Execute o projeto para ver uma demonstração completa:

```bash
flutter run
```

## 📋 Parâmetros

### Obrigatórios
- **`videoId`** (String): ID do vídeo do YouTube

### Opcionais
- **`width`** (double?): Largura do widget
- **`height`** (double?): Altura do widget (padrão: 300)
- **`autoPlay`** (bool): Se o vídeo toca automaticamente (padrão: false)
- **`showControls`** (bool): Se mostra os controles do player (padrão: true)
- **`allowFullscreen`** (bool): Se permite tela cheia (padrão: true)
- **`onVideoStart`** (VoidCallback?): Chamado quando o vídeo inicia
- **`onVideoEnd`** (VoidCallback?): Chamado quando o vídeo termina
- **`onError`** (Function(String)?): Chamado quando ocorre um erro

## 🔧 Função Utilitária

```dart
String? videoId = extractVideoIdFromShortsUrl('https://youtube.com/shorts/dQw4w9WgXcQ');
// Retorna: 'dQw4w9WgXcQ'
```

### URLs Suportadas:
- `youtube.com/shorts/VIDEO_ID`
- `youtube.com/watch?v=VIDEO_ID`
- `youtu.be/VIDEO_ID`
- `music.youtube.com/watch?v=VIDEO_ID`
- `m.youtube.com/watch?v=VIDEO_ID`
- IDs diretos de vídeo

## 🧪 Testes

Execute os testes:

```bash
flutter test
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Aplicação de demonstração
├── widgets/
│   └── youtube_shorts_widget.dart  # Widget principal
├── examples/
│   └── widget_examples.dart       # Exemplos de uso
└── README_Widget.md            # Documentação detalhada

test/
└── widget_test.dart            # Testes unitários
```

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

- **@Jone1983**
- 📧 Email: erbertjunp@hotmail.com
- 📱 WhatsApp: +5583991415530
