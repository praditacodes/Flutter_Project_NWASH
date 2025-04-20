import 'package:geolocator/geolocator.dart';

class GPSService {
  Future<Position?> getCurrentLocation() async {
    try {
      // Step 1: Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("❌ Location services are disabled.");
        await Geolocator.openLocationSettings(); // Prompt to enable
        return null;
      }

      // Step 2: Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("❌ Location permission denied.");
        return null;
      }

      // Step 3: Get current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
        // desiredAccuracy: LocationAccuracy.high, //!This property is deprecated. so, it's preferred to use the latest property through locaiton settings.
      );
      print("✅ Current Location: ${position.latitude}, ${position.longitude}");
      return position;
    } catch (e) {
      print("❌ Error getting location: $e");
      return null;
    }
  }
}
