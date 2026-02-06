import 'dart:isolate';
import 'dart:ui';

import 'package:begin_first/domain/models/scene.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _managedGeofencePrefix = 'scene:';
const _pendingCheckoutSceneIdKey = 'pendingCheckoutSceneId';
const _pendingCheckoutTriggeredAtKey = 'pendingCheckoutTriggeredAt';
const _geofenceConfigPrefix = 'sceneGeofenceConfig:';
const systemGeofenceSendPortName = 'begin_first_geofence_send_port';

class PendingCheckoutTrigger {
  const PendingCheckoutTrigger({
    required this.sceneId,
    required this.triggeredAt,
  });

  final String sceneId;
  final DateTime triggeredAt;
}

class SystemGeofenceService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await NativeGeofenceManager.instance.initialize();
    _initialized = true;
  }

  Future<void> syncSceneGeofences(List<Scene> scenes) async {
    await initialize();
    final prefs = await SharedPreferences.getInstance();

    final targets = scenes
        .where(
          (scene) =>
              scene.isActive &&
              scene.geofenceEnabled &&
              scene.geofenceLatitude != null &&
              scene.geofenceLongitude != null,
        )
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (targets.length > 20) {
      targets.removeRange(20, targets.length);
    }

    final activeIds = await NativeGeofenceManager.instance.getRegisteredGeofenceIds();
    final managedIds = activeIds.where((id) => id.startsWith(_managedGeofencePrefix)).toSet();
    final targetIds = targets.map((scene) => _sceneGeofenceId(scene.id)).toSet();

    for (final geofenceId in managedIds.difference(targetIds)) {
      await NativeGeofenceManager.instance.removeGeofenceById(geofenceId);
      await prefs.remove(_configKey(_sceneIdFromGeofenceId(geofenceId)));
    }

    for (final scene in targets) {
      final configKey = _configKey(scene.id);
      final nextSignature = _sceneSignature(scene);
      final currentSignature = prefs.getString(configKey);
      final geofenceId = _sceneGeofenceId(scene.id);
      final shouldReplace = managedIds.contains(geofenceId) && currentSignature != nextSignature;
      final shouldCreate = !managedIds.contains(geofenceId);
      if (shouldCreate || shouldReplace) {
        await _upsertSceneGeofence(scene, shouldReplace: shouldReplace);
        await prefs.setString(configKey, nextSignature);
      }
    }
  }

  Future<PendingCheckoutTrigger?> readPendingCheckoutTrigger() async {
    final prefs = await SharedPreferences.getInstance();
    final sceneId = prefs.getString(_pendingCheckoutSceneIdKey);
    if (sceneId == null || sceneId.isEmpty) {
      return null;
    }
    final millis = prefs.getInt(_pendingCheckoutTriggeredAtKey) ?? DateTime.now().millisecondsSinceEpoch;
    return PendingCheckoutTrigger(
      sceneId: sceneId,
      triggeredAt: DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  Future<void> markPendingCheckoutHandled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingCheckoutSceneIdKey);
    await prefs.remove(_pendingCheckoutTriggeredAtKey);
  }

  Future<void> _upsertSceneGeofence(Scene scene, {required bool shouldReplace}) async {
    final geofenceId = _sceneGeofenceId(scene.id);
    if (shouldReplace) {
      await NativeGeofenceManager.instance.removeGeofenceById(geofenceId);
    }

    final geofence = Geofence(
      id: geofenceId,
      location: Location(
        latitude: scene.geofenceLatitude!,
        longitude: scene.geofenceLongitude!,
      ),
      radiusMeters: scene.geofenceRadiusMeters.toDouble(),
      triggers: {GeofenceEvent.exit},
      iosSettings: IosGeofenceSettings(initialTrigger: false),
      androidSettings: AndroidGeofenceSettings(initialTriggers: <GeofenceEvent>{}),
    );

    await NativeGeofenceManager.instance.createGeofence(
      geofence,
      systemGeofenceTriggered,
    );
  }

  static String _sceneGeofenceId(String sceneId) => '$_managedGeofencePrefix$sceneId';

  static String _sceneIdFromGeofenceId(String geofenceId) => geofenceId.substring(_managedGeofencePrefix.length);

  static String _configKey(String sceneId) => '$_geofenceConfigPrefix$sceneId';

  static String _sceneSignature(Scene scene) {
    return '${scene.geofenceLatitude?.toStringAsFixed(6)}:${scene.geofenceLongitude?.toStringAsFixed(6)}:${scene.geofenceRadiusMeters}';
  }

  static Future<void> savePendingTriggerFromGeofence(String geofenceId) async {
    if (!geofenceId.startsWith(_managedGeofencePrefix)) {
      return;
    }
    final sceneId = geofenceId.substring(_managedGeofencePrefix.length);
    if (sceneId.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingCheckoutSceneIdKey, sceneId);
    await prefs.setInt(_pendingCheckoutTriggeredAtKey, DateTime.now().millisecondsSinceEpoch);
    final send = IsolateNameServer.lookupPortByName(systemGeofenceSendPortName);
    send?.send(sceneId);
  }
}

@pragma('vm:entry-point')
Future<void> systemGeofenceTriggered(GeofenceCallbackParams params) async {
  if (params.event != GeofenceEvent.exit) {
    return;
  }
  for (final geofence in params.geofences) {
    if (geofence.id.startsWith(_managedGeofencePrefix)) {
      await SystemGeofenceService.savePendingTriggerFromGeofence(geofence.id);
      break;
    }
  }
}
