# YouTube Shorts Custom Widget for FlutterFlow

## Overview
This custom widget allows you to embed YouTube Shorts videos directly into your FlutterFlow app with a mobile-optimized design and customizable features.

## Features
- ✅ Optimized for YouTube Shorts (9:16 aspect ratio)
- ✅ Customizable size and appearance
- ✅ Auto-play support with muting
- ✅ Error handling and retry functionality
- ✅ Loading states
- ✅ Open in YouTube app functionality
- ✅ Callback functions for video events
- ✅ URL parsing for different YouTube formats

## Dependencies Required

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.4.4
  url_launcher: ^6.2.4
```

## FlutterFlow Integration Steps

### 1. Add Custom Widget to FlutterFlow

1. Go to your FlutterFlow project
2. Navigate to **Custom Code** > **Custom Widgets**
3. Click **Add Widget**
4. Set the widget name: `YouTubeShortsWidget`
5. Copy the entire content of `youtube_shorts_widget.dart` into the code editor

### 2. Define Widget Properties

In FlutterFlow's Custom Widget settings, add these properties:

| Property Name | Type | Default Value | Required | Description |
|---------------|------|---------------|----------|-------------|
| `videoId` | String | - | ✅ | YouTube video ID (e.g., "dQw4w9WgXcQ") |
| `width` | double | 300.0 | ❌ | Widget width in pixels |
| `height` | double | 533.0 | ❌ | Widget height in pixels (9:16 ratio) |
| `autoPlay` | bool | false | ❌ | Auto-play video on load |
| `showControls` | bool | true | ❌ | Show video controls |
| `allowFullscreen` | bool | true | ❌ | Allow fullscreen mode |

### 3. Usage Examples

#### Basic Usage
```dart
YouTubeShortsWidget(
  videoId: 'dQw4w9WgXcQ',
)
```

#### Advanced Usage with Callbacks
```dart
YouTubeShortsWidget(
  videoId: 'dQw4w9WgXcQ',
  width: 350.0,
  height: 600.0,
  autoPlay: true,
  showControls: true,
  allowFullscreen: true,
  onVideoStart: () {
    print('Video started playing');
  },
  onVideoEnd: () {
    print('Video ended');
  },
  onError: (error) {
    print('Video error: $error');
  },
)
```

#### Using with URL Parser
```dart
String shortsUrl = 'https://www.youtube.com/shorts/dQw4w9WgXcQ';
String videoId = extractVideoIdFromShortsUrl(shortsUrl);

YouTubeShortsWidget(
  videoId: videoId,
)
```

## Widget Parameters Reference

### Required Parameters
- **videoId** (String): The YouTube video ID. You can extract this from any YouTube URL using the provided helper function.

### Optional Parameters
- **width** (double): Width of the widget in pixels. Default: 300.0
- **height** (double): Height of the widget in pixels. Default: 533.0 (9:16 aspect ratio)
- **autoPlay** (bool): Whether to auto-play the video. Default: false
- **showControls** (bool): Whether to show video controls. Default: true
- **allowFullscreen** (bool): Whether to allow fullscreen mode. Default: true

### Callback Functions
- **onVideoStart** (VoidCallback?): Called when video starts playing
- **onVideoEnd** (VoidCallback?): Called when video ends
- **onError** (Function(String)?): Called when an error occurs

## URL Formats Supported

The widget can extract video IDs from these URL formats:
- `https://www.youtube.com/shorts/VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `https://www.youtube.com/watch?v=VIDEO_ID`
- Direct video ID: `VIDEO_ID`

## FlutterFlow Action Setup

### Creating Actions for Video Events

1. **On Video Start Action**:
   - Go to your page's Actions
   - Create a new Action triggered by the widget's `onVideoStart`
   - Add your custom logic (analytics, state updates, etc.)

2. **On Error Action**:
   - Create an Action for `onError`
   - Show error dialog or handle gracefully
   - Optional: Log to analytics

### State Management Integration

```dart
// Example: Update app state when video starts
void onVideoStarted() {
  FFAppState().currentVideoPlaying = true;
  FFAppState().update(() {});
}

// Example: Handle video errors
void onVideoError(String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Video error: $error')),
  );
}
```

## Best Practices

### 1. Performance Optimization
- Use appropriate widget sizes for your target devices
- Consider lazy loading for lists of videos
- Implement proper disposal in stateful widgets

### 2. User Experience
- Always provide loading states
- Handle network errors gracefully
- Consider auto-mute for auto-play videos

### 3. Mobile Optimization
- Use the default 9:16 aspect ratio for Shorts
- Test on various screen sizes
- Consider device orientation changes

### 4. Content Guidelines
- Ensure video IDs are valid
- Handle private or deleted videos
- Respect YouTube's terms of service

## Troubleshooting

### Common Issues

1. **Video not loading**
   - Check internet connection
   - Verify video ID is correct
   - Ensure video is public

2. **WebView not working**
   - Check if webview_flutter is properly installed
   - Verify platform-specific setup for iOS/Android

3. **Auto-play not working**
   - Note: Auto-play is limited by platform policies
   - Videos auto-mute when auto-playing

### Error Handling

The widget includes built-in error handling:
- Shows error message and retry button
- Calls `onError` callback if provided
- Graceful fallback to error state

## Platform Considerations

### Android
- Add internet permission to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
- Add to `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

## Support

For issues or questions:
1. Check the troubleshooting section
2. Verify all dependencies are installed
3. Test with known working video IDs
4. Check Flutter and FlutterFlow documentation

---

*This widget is designed specifically for FlutterFlow integration and follows Flutter best practices for custom widgets.*