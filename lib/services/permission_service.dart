import 'package:permission_handler/permission_handler.dart' as permission;

abstract class PermissionService {
  Future<bool> ensureCameraPermission();
  Future<bool> ensureLocationPermission();
  Future<bool> ensureNotificationPermission();
  Future<void> openAppSettings();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> ensureCameraPermission() async {
    final status = await permission.Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> ensureLocationPermission() async {
    final status = await permission.Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  @override
  Future<bool> ensureNotificationPermission() async {
    final status = await permission.Permission.notification.request();
    return status.isGranted;
  }

  @override
  Future<void> openAppSettings() async {
    await permission.openAppSettings();
  }
}
