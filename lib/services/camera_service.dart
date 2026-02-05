import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class CameraService {
  Future<String?> takePhoto();
  Future<String?> pickFromGallery();
  Future<bool> hasCameraPermission();
  Future<bool> requestCameraPermission();
}

class CameraServiceImpl implements CameraService {
  CameraServiceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> takePhoto() {
    return _pick(ImageSource.camera);
  }

  @override
  Future<String?> pickFromGallery() {
    return _pick(ImageSource.gallery);
  }

  @override
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<String?> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    return file?.path;
  }
}
