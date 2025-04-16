import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoCaptureService {
  Future<XFile?> capturePhoto() async {
    // Request camera permission
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.camera);
    } else if (status.isDenied) {
      print('📷 Camera permission denied.');
    } else if (status.isPermanentlyDenied) {
      print(
          '📷 Camera permission permanently denied. Please enable it from settings.');
      openAppSettings(); // Optionally open app settings
    }
    return null;
  }
}
