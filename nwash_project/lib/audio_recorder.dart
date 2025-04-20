import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AudioRecorderService extends ChangeNotifier {
  FlutterSoundRecorder? _audioRecorder;
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isRecording = false;
  bool _isListening = false;
  String? _audioPath;
  String _recognizedText = '';

  bool get isRecording => _isRecording;
  bool get isListening => _isListening;
  String? get audioPath => _audioPath;
  String get recognizedText => _recognizedText;

  AudioRecorderService() {
    _audioRecorder = FlutterSoundRecorder();
  }

  Future<void> init() async {
    await _requestPermissions();
    await _audioRecorder!.openRecorder();
  }

  Future<void> _requestPermissions() async {
    var micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) throw '❌ Microphone permission is required';

    var speechStatus = await Permission.speech.request();
    if (!speechStatus.isGranted)
      throw '❌ Speech recognition permission is required';
  }

  Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = join(
      directory.path,
      'audio_${DateTime.now().millisecondsSinceEpoch}.aac',
    );

//! This is was causing the issue as recorder and speech-to-text both were trying to use the microphone at the same time.
    // await _audioRecorder!.startRecorder(
    //   toFile: filePath,
    //   codec: Codec.aacADTS,
    // );

    _audioPath = filePath;
    _isRecording = true;
    notifyListeners();

    // print("🎙️ Started recording: $_audioPath");
    await _startListening();
  }

  Future<void> stopRecording() async {
    await _audioRecorder?.stopRecorder();
    _isRecording = false;
    notifyListeners();

    await _stopListening();
    print("🛑 Recording stopped");
  }

  Future<void> release() async {
    await _audioRecorder?.closeRecorder();
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('🔄 Speech status: $status'),
      onError: (error) => print('⚠️ Speech error: $error'),
    );

    if (available) {
      _isListening = true;
      notifyListeners();

      await _speechToText.listen(
        localeId: 'ne-NP', // Nepali
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          print('🗣️ Recognized Text (Nepali): $_recognizedText');
          notifyListeners(); // ✅ UI will now be updated
        },
      );
    } else {
      print("❌ Speech recognition not available");
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
    print("🛑 Listening stopped");
  }
}
