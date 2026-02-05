import 'package:begin_first/data/local/hive_initializer.dart';
import 'package:begin_first/data/repositories/intent_repository_impl.dart';
import 'package:begin_first/data/repositories/item_repository_impl.dart';
import 'package:begin_first/data/repositories/record_repository_impl.dart';
import 'package:begin_first/data/repositories/scene_repository_impl.dart';
import 'package:begin_first/domain/repositories/intent_repository.dart';
import 'package:begin_first/domain/repositories/item_repository.dart';
import 'package:begin_first/domain/repositories/record_repository.dart';
import 'package:begin_first/domain/repositories/scene_repository.dart';
import 'package:begin_first/services/camera_service.dart';
import 'package:begin_first/services/image_storage_service.dart';
import 'package:begin_first/services/location_service.dart';
import 'package:begin_first/services/notification_service.dart';
import 'package:begin_first/services/permission_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hiveBoxesProvider = Provider<HiveBoxes>((ref) => HiveBoxes());

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl(ref.read(hiveBoxesProvider));
});

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepositoryImpl(ref.read(hiveBoxesProvider));
});

final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  return SceneRepositoryImpl(ref.read(hiveBoxesProvider));
});

final intentRepositoryProvider = Provider<IntentRepository>((ref) {
  return IntentRepositoryImpl(ref.read(hiveBoxesProvider));
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraServiceImpl();
});

final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return ImageStorageServiceImpl();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionServiceImpl();
});
