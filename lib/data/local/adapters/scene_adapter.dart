import 'package:begin_first/domain/models/enums/scene_type.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:hive/hive.dart';

class SceneAdapter extends TypeAdapter<Scene> {
  @override
  final int typeId = 2;

  @override
  Scene read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final type = reader.read() as SceneType;
    final iconName = reader.readString();
    final defaultItemIds = reader.readList().cast<String>();
    final isActive = reader.readBool();
    final sortOrder = reader.readInt();
    var geofenceEnabled = false;
    double? geofenceLatitude;
    double? geofenceLongitude;
    var geofenceRadiusMeters = 180;
    try {
      geofenceEnabled = reader.readBool();
      geofenceLatitude = reader.readDouble();
      geofenceLongitude = reader.readDouble();
      geofenceRadiusMeters = reader.readInt();
      if (!geofenceEnabled) {
        geofenceLatitude = null;
        geofenceLongitude = null;
      }
    } catch (_) {
      geofenceEnabled = false;
      geofenceLatitude = null;
      geofenceLongitude = null;
      geofenceRadiusMeters = 180;
    }
    return Scene(
      id: id,
      name: name,
      type: type,
      iconName: iconName,
      defaultItemIds: defaultItemIds,
      isActive: isActive,
      geofenceEnabled: geofenceEnabled,
      geofenceLatitude: geofenceLatitude,
      geofenceLongitude: geofenceLongitude,
      geofenceRadiusMeters: geofenceRadiusMeters,
      sortOrder: sortOrder,
    );
  }

  @override
  void write(BinaryWriter writer, Scene obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..write(obj.type)
      ..writeString(obj.iconName)
      ..writeList(obj.defaultItemIds)
      ..writeBool(obj.isActive)
      ..writeInt(obj.sortOrder)
      ..writeBool(obj.geofenceEnabled)
      ..writeDouble(obj.geofenceLatitude ?? 0)
      ..writeDouble(obj.geofenceLongitude ?? 0)
      ..writeInt(obj.geofenceRadiusMeters);
  }
}
