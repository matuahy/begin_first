import 'package:begin_first/domain/models/enums/scene_type.dart';

class Scene {
  const Scene({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    this.defaultItemIds = const [],
    this.isActive = true,
    this.geofenceEnabled = false,
    this.geofenceLatitude,
    this.geofenceLongitude,
    this.geofenceRadiusMeters = 180,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final SceneType type;
  final String iconName;
  final List<String> defaultItemIds;
  final bool isActive;
  final bool geofenceEnabled;
  final double? geofenceLatitude;
  final double? geofenceLongitude;
  final int geofenceRadiusMeters;
  final int sortOrder;

  Scene copyWith({
    String? id,
    String? name,
    SceneType? type,
    String? iconName,
    List<String>? defaultItemIds,
    bool? isActive,
    bool? geofenceEnabled,
    double? geofenceLatitude,
    double? geofenceLongitude,
    int? geofenceRadiusMeters,
    int? sortOrder,
  }) {
    return Scene(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      defaultItemIds: defaultItemIds ?? this.defaultItemIds,
      isActive: isActive ?? this.isActive,
      geofenceEnabled: geofenceEnabled ?? this.geofenceEnabled,
      geofenceLatitude: geofenceLatitude ?? this.geofenceLatitude,
      geofenceLongitude: geofenceLongitude ?? this.geofenceLongitude,
      geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
