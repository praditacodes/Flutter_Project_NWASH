import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'gps_service.dart';
import 'audio_recorder.dart';
import 'photo_capture.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GPSService _gpsService = GPSService();
  final AudioRecorderService _audioRecorderService = AudioRecorderService();
  final PhotoCaptureService _photoCaptureService = PhotoCaptureService();

  String _currentLocation = '';
  String _audioPath = '';
  String _photoPath = '';
  String _timestamp = '';
  String _recognizedSpeech = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await Permission.microphone.request();
    await Permission.camera.request();
    await Permission.location.request();
    await Permission.speech.request();
    await _audioRecorderService.init();
  }

  Future<void> _getLocation() async {
    var position = await _gpsService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLocation =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
        _timestamp = DateTime.now().toString();
      });
    } else {
      setState(() {
        _currentLocation = 'Location unavailable.';
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_audioRecorderService.isRecording) {
      await _audioRecorderService.stopRecording();
      setState(() {
        _audioPath = _audioRecorderService.audioPath ?? '';
        _recognizedSpeech = _audioRecorderService.recognizedText;
        _timestamp = DateTime.now().toString();
      });
    } else {
      await _audioRecorderService.startRecording();
    }
    setState(() {});
  }

  Future<void> _capturePhoto() async {
    var file = await _photoCaptureService.capturePhoto();
    if (file != null) {
      setState(() {
        _photoPath = file.path;
        _timestamp = DateTime.now().toString();
      });
    }
  }

  @override
  void dispose() {
    _audioRecorderService.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Field Data Capture'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _getLocation,
              icon: Icon(Icons.location_on),
              label: Text('Get Current Location'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
            SizedBox(height: 12),
            MetadataTile(
              title: 'Current Location',
              value: _currentLocation.isNotEmpty
                  ? _currentLocation
                  : 'Location not available.',
              icon: Icons.map,
            ),
            Divider(height: 32),
            ElevatedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(
                  _audioRecorderService.isRecording ? Icons.stop : Icons.mic),
              label: Text(_audioRecorderService.isRecording
                  ? 'Stop Recording'
                  : 'Start Recording'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 12),
            MetadataTile(
              title: 'Audio Path',
              value:
                  _audioPath.isNotEmpty ? _audioPath : 'No audio recorded yet.',
              icon: Icons.audiotrack,
            ),
            SizedBox(height: 12),
            MetadataTile(
              title: 'Recognized Speech',
              value: _recognizedSpeech.isNotEmpty
                  ? _recognizedSpeech
                  : 'No speech recognized yet.',
              icon: Icons.subtitles,
            ),
            Divider(height: 32),
            ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: Icon(Icons.camera_alt),
              label: Text('Capture Photo'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 12),
            _photoPath.isNotEmpty
                ? Column(
                    children: [
                      Image.file(File(_photoPath), height: 200),
                      SizedBox(height: 8),
                      MetadataTile(
                        title: 'Photo Path',
                        value: _photoPath,
                        icon: Icons.photo,
                      ),
                    ],
                  )
                : MetadataTile(
                    title: 'Photo',
                    value: 'No photo captured yet.',
                    icon: Icons.image_not_supported,
                  ),
            Divider(height: 32),
            MetadataTile(
              title: 'Timestamp',
              value: _timestamp.isNotEmpty
                  ? _timestamp
                  : 'No action performed yet.',
              icon: Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }
}

class MetadataTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  MetadataTile({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
