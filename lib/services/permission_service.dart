import 'package:permission_handler/permission_handler.dart' as permission;

abstract class PermissionService {
  Future<bool> hasCameraPermission();
  Future<bool> hasLocationPermission();
  Future<bool> hasBackgroundLocationPermission();
  Future<bool> hasNotificationPermission();
  Future<bool> ensureCameraPermission();
  Future<bool> ensureLocationPermission();
  Future<bool> ensureBackgroundLocationPermission();
  Future<bool> ensureNotificationPermission();
  Future<void> openAppSettings();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> hasCameraPermission() async {
    final status = await permission.Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> hasLocationPermission() async {
    final status = await permission.Permission.locationWhenInUse.status;
    if (status.isGranted) {
      return true;
    }
    final alwaysStatus = await permission.Permission.locationAlways.status;
    return alwaysStatus.isGranted;
  }

  @override
  Future<bool> hasBackgroundLocationPermission() async {
    final status = await permission.Permission.locationAlways.status;
    return status.isGranted;
  }

  @override
  Future<bool> hasNotificationPermission() async {
    final status = await permission.Permission.notification.status;
    return status.isGranted;
  }

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
  Future<bool> ensureBackgroundLocationPermission() async {
    final hasForeground = await ensureLocationPermission();
    if (!hasForeground) {
      return false;
    }
    final current = await permission.Permission.locationAlways.status;
    if (current.isGranted) {
      return true;
    }
    final always = await permission.Permission.locationAlways.request();
    return always.isGranted;
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
