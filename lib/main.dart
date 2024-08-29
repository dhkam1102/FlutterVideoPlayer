import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoPlayerModel(),
      child: MaterialApp(
        home: VideoPlayerScreen(),
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<VideoPlayerModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('WebRTC Video Player'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(model.localRenderer),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: model.play,
              ),
              IconButton(
                icon: Icon(Icons.pause),
                onPressed: model.pause,
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: model.refresh,
              ),
            ],
          ),
          Slider(
            value: model.denoise,
            onChanged: model.setDenoise,
            min: 0,
            max: 1,
            divisions: 10,
            label: 'Denoise: ${model.denoise}',
          ),
          Slider(
            value: model.dehaze,
            onChanged: model.setDehaze,
            min: 0,
            max: 1,
            divisions: 10,
            label: 'Dehaze: ${model.dehaze}',
          ),
        ],
      ),
    );
  }
}

class VideoPlayerModel with ChangeNotifier {
  final localRenderer = RTCVideoRenderer();
  double _denoise = 0.0;
  double _dehaze = 0.0;

  VideoPlayerModel() {
    initRenderer();
  }

  Future<void> initRenderer() async {
    await localRenderer.initialize();
    // Set up WebRTC stream here
  }

  double get denoise => _denoise;
  double get dehaze => _dehaze;

  void setDenoise(double value) {
    _denoise = value;
    // Apply denoise filter to stream
    applyDenoiseFilter()
    notifyListeners();
  }

  void setDehaze(double value) {
    _dehaze = value;
    // Apply dehaze filter to stream
    applyDehazeFilter(); 
    notifyListeners();
  }

  void play() {
    if (_stream != null) {
      _stream!.getTracks().forEach((track) {
        track.enabled = true;
      });
    }
  }

  void pause() {
    if (_stream != null) {
      _stream!.getTracks().forEach((track) {
        track.enabled = false;
      });
    }
  }

 void refresh() {
    if (_stream != null) {
      _stream!.getTracks().forEach((track) {
        track.stop();
      });
      // re- initializing the stream
      initRenderer(); 
    }
  }

  void applyDenoiseFilter() {
    // Example of applying a denoise filter
    // This is a placeholder; you would need to integrate with
    // a library or custom implementation to apply the actual filter.
    print("Denoise filter applied with level $_denoise");
  }

  void applyDehazeFilter() {
    // Example of applying a dehaze filter
    // This is a placeholder; you would need to integrate with
    // a library or custom implementation to apply the actual filter.
    print("Dehaze filter applied with level $_dehaze");
  }



  @override
  void dispose() {
    localRenderer.dispose();
    super.dispose();
  }
}
