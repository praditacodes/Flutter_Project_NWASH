import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataSaver {
  static Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _getDataFile() async {
    final path = await _getLocalPath();
    return File('$path/saved_data.json');
  }

  static Future<void> saveData({
    required String imagePath,
    required String audioPath,
    required String transcription,
    required double latitude,
    required double longitude,
    required DateTime dateTime,
  }) async {
    final file = await _getDataFile();

    // Create a new entry
    final newEntry = {
      'imagePath': imagePath,
      'audioPath': audioPath,
      'transcription': transcription,
      'latitude': latitude,
      'longitude': longitude,
      'dateTime': dateTime.toIso8601String(),
    };

    List<dynamic> existingData = [];

    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        existingData = json.decode(contents);
      }
    }

    existingData.add(newEntry);
    await file.writeAsString(json.encode(existingData), flush: true);
  }

  static Future<List<Map<String, dynamic>>> loadData() async {
    final file = await _getDataFile();

    if (await file.exists()) {
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        final List<dynamic> decoded = json.decode(contents);
        return decoded.cast<Map<String, dynamic>>();
      }
    }

    return [];
  }
}
