import 'package:begin_first/app/providers.dart';
import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/scenes/providers/scene_detail_provider.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
import 'package:begin_first/features/settings/providers/settings_provider.dart';
import 'package:begin_first/services/system_geofence_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkoutSceneProvider = StateProvider<String?>((ref) => null);
final checkoutCheckedProvider = StateProvider<Set<String>>((ref) => <String>{});

class CheckoutGeofenceTrigger {
  const CheckoutGeofenceTrigger({
    required this.sceneId,
    required this.sceneName,
    required this.triggeredAt,
  });

  final String sceneId;
  final String sceneName;
  final DateTime triggeredAt;
}

final checkoutItemsProvider = Provider<List<Item>>((ref) {
  final items = ref.watch(itemsStreamProvider).valueOrNull ?? const <Item>[];
  final sceneId = ref.watch(checkoutSceneProvider);
  if (sceneId == null) {
    return items;
  }
  final scene = ref.watch(sceneDetailProvider(sceneId));
  if (scene == null) {
    return const <Item>[];
  }
  final itemIds = scene.defaultItemIds.toSet();
  return items.where((item) => itemIds.contains(item.id)).toList();
});

final checkoutGeofenceTriggerProvider = FutureProvider<CheckoutGeofenceTrigger?>((ref) async {
  final scenes = ref.watch(scenesStreamProvider).valueOrNull ?? const <Scene>[];
  final geofenceService = ref.read(systemGeofenceServiceProvider);
  final autoCheckoutEnabled = ref.watch(appSettingsProvider.select((settings) => settings.autoCheckoutEnabled));

  if (!autoCheckoutEnabled) {
    try {
      await geofenceService.syncSceneGeofences(const []);
      await geofenceService.markPendingCheckoutHandled();
    } catch (_) {
      return null;
    }
    return null;
  }

  final hasBackgroundLocation = await ref.read(permissionServiceProvider).hasBackgroundLocationPermission();
  if (!hasBackgroundLocation) {
    await geofenceService.markPendingCheckoutHandled();
    return null;
  }

  try {
    await geofenceService.syncSceneGeofences(scenes);
  } catch (_) {
    return null;
  }

  final pending = await geofenceService.readPendingCheckoutTrigger();
  if (pending == null) {
    return null;
  }

  Scene? scene;
  for (final value in scenes) {
    if (value.id == pending.sceneId) {
      scene = value;
      break;
    }
  }

  if (scene == null || !scene.isActive || !scene.geofenceEnabled) {
    await geofenceService.markPendingCheckoutHandled();
    return null;
  }

  return CheckoutGeofenceTrigger(
    sceneId: scene.id,
    sceneName: scene.name,
    triggeredAt: pending.triggeredAt,
  );
});

final checkoutGeofenceActionsProvider = Provider<CheckoutGeofenceActions>((ref) {
  return CheckoutGeofenceActions(
    geofenceService: ref.read(systemGeofenceServiceProvider),
  );
});

class CheckoutGeofenceActions {
  CheckoutGeofenceActions({required this.geofenceService});

  final SystemGeofenceService geofenceService;

  Future<void> markTriggerHandled() async {
    await geofenceService.markPendingCheckoutHandled();
  }
}
