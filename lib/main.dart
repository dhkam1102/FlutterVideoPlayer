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
      child: Consumer<VideoPlayerModel>(
        builder: (context, model, child) {
          return MaterialApp(
            home: VideoPlayerScreen(),
            themeMode: model.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
          );
        },
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
        // **Highlighted Change**: Move the theme switch to the top left by placing it in the 'leading' property
        leading: IconButton(
          icon: Icon(model.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: model.toggleThemeMode,
        ),
        title: Text('WebRTC Video Player'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,  // Standard video aspect ratio
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: model.isDarkMode ? Colors.black54 : Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: RTCVideoView(model.localRenderer),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow, color: model.isDarkMode ? Colors.green : Colors.deepPurple),
                  iconSize: 36.0,
                  onPressed: model.play,
                ),
                SizedBox(width: 20.0),
                IconButton(
                  icon: Icon(Icons.pause, color: model.isDarkMode ? Colors.green : Colors.deepPurple),
                  iconSize: 36.0,
                  onPressed: model.pause,
                ),
                SizedBox(width: 20.0),
                IconButton(
                  icon: Icon(Icons.refresh, color: model.isDarkMode ? Colors.green : Colors.deepPurple),
                  iconSize: 36.0,
                  onPressed: model.refresh,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: model.isDarkMode ? Colors.green : Colors.deepPurple,
                inactiveTrackColor: model.isDarkMode ? Colors.green.shade100 : Colors.deepPurple.shade100,
                trackShape: RoundedRectSliderTrackShape(),
                trackHeight: 4.0,
                thumbColor: model.isDarkMode ? Colors.green : Colors.deepPurple,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                overlayColor: model.isDarkMode ? Colors.green.withAlpha(32) : Colors.deepPurple.withAlpha(32),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
              ),
              child: Column(
                children: [
                  Text('Denoise', style: TextStyle(color: model.isDarkMode ? Colors.green : Colors.deepPurple)),
                  Slider(
                    value: model.denoise,
                    onChanged: model.setDenoise,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    label: 'Denoise: ${model.denoise}',
                  ),
                  SizedBox(height: 16.0),
                  Text('Dehaze', style: TextStyle(color: model.isDarkMode ? Colors.green : Colors.deepPurple)),
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
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerModel with ChangeNotifier {
  final localRenderer = RTCVideoRenderer();
  MediaStream? _stream;
  double _denoise = 0.0;
  double _dehaze = 0.0;
  bool _isDarkMode = false;

  VideoPlayerModel() {
    initRenderer();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> initRenderer() async {
    await localRenderer.initialize();
    _stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': false,
    });
    localRenderer.srcObject = _stream;
  }

  double get denoise => _denoise;
  double get dehaze => _dehaze;

  void setDenoise(double value) {
    _denoise = value;
    applyDenoiseFilter();
    notifyListeners();
  }

  void setDehaze(double value) {
    _dehaze = value;
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
      initRenderer();
    }
  }

  void applyDenoiseFilter() {
    print("Denoise filter applied with level $_denoise");
  }

  void applyDehazeFilter() {
    print("Dehaze filter applied with level $_dehaze");
  }

  @override
  void dispose() {
    localRenderer.dispose();
    super.dispose();
  }
}
