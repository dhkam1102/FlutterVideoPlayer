import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Gets the video element from the renderer
html.VideoElement? _getVideoElement(RTCVideoRenderer renderer) {
  if (!kIsWeb) return null;
  
  // Find video element by searching the DOM
  final videos = html.document.getElementsByTagName('video');
  if (videos.isEmpty) return null;
  
  // Usually the first video element is our WebRTC video
  return videos.first as html.VideoElement;
}

/// Applies multiple CSS filters to create a video enhancement effect
String _combineFilters(Map<String, String> filters) {
  return filters.entries.map((e) => '${e.key}(${e.value})').join(' ');
}

/// Applies filters to the video element
void _applyFilters(RTCVideoRenderer renderer, Map<String, String> filters) {
  final videoElement = _getVideoElement(renderer);
  if (videoElement != null) {
    videoElement.style.filter = _combineFilters(filters);
  }
}

/// Applies a denoise effect by combining blur and sharpness
void applyDenoise(RTCVideoRenderer renderer, double level) {
  if (renderer.srcObject == null || !kIsWeb) return;
  
  final filters = {
    'blur': '${level * 0.5}px',
    'contrast': '${1 + level * 0.1}',
    'brightness': '${1 + level * 0.05}',
    'saturate': '${1 + level * 0.2}'
  };
  
  _applyFilters(renderer, filters);
  print("Applied denoise filter with level $level");
}

/// Applies a dehaze effect using contrast and brightness
void applyDehaze(RTCVideoRenderer renderer, double level) {
  if (renderer.srcObject == null || !kIsWeb) return;
  
  final filters = {
    'contrast': '${1 + level * 0.3}',
    'brightness': '${1 + level * 0.1}',
    'saturate': '${1 + level * 0.2}',
    'hue-rotate': '${level * 5}deg'
  };
  
  _applyFilters(renderer, filters);
  print("Applied dehaze filter with level $level");
}

/// Applies a warmth filter
void applyWarmth(RTCVideoRenderer renderer, double level) {
  if (renderer.srcObject == null || !kIsWeb) return;
  
  final filters = {
    'sepia': '${level * 0.3}',
    'saturate': '${1 + level * 0.2}',
    'brightness': '${1 + level * 0.05}',
    'contrast': '${1 + level * 0.1}'
  };
  
  _applyFilters(renderer, filters);
  print("Applied warmth filter with level $level");
}

/// Applies a sharpness filter
void applySharpness(RTCVideoRenderer renderer, double level) {
  if (renderer.srcObject == null || !kIsWeb) return;
  
  final filters = {
    'contrast': '${1 + level * 0.3}',
    'brightness': '${1 + level * 0.1}',
  };
  
  _applyFilters(renderer, filters);
  print("Applied sharpness filter with level $level");
}

/// Combines multiple filters with individual levels
void applyMultipleFilters(RTCVideoRenderer renderer, {
  double denoise = 0,
  double dehaze = 0,
  double warmth = 0,
  double sharpness = 0,
}) {
  if (renderer.srcObject == null || !kIsWeb) return;
  
  final filters = {
    'blur': '${denoise * 0.5}px',
    'contrast': '${1 + (dehaze * 0.3 + sharpness * 0.3)}',
    'brightness': '${1 + (dehaze * 0.1 + warmth * 0.05)}',
    'saturate': '${1 + (dehaze * 0.2 + warmth * 0.2)}',
    'sepia': '${warmth * 0.3}',
    'hue-rotate': '${dehaze * 5}deg'
  };
  
  _applyFilters(renderer, filters);
  print("Applied multiple filters");
}

/// Clears all filters
void clearFilters(RTCVideoRenderer renderer) {
  if (!kIsWeb) return;
  
  final videoElement = _getVideoElement(renderer);
  if (videoElement != null) {
    videoElement.style.filter = '';
  }
}