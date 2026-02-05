import 'package:begin_first/domain/models/location_info.dart';
import 'package:hive/hive.dart';

class LocationInfoAdapter extends TypeAdapter<LocationInfo> {
  @override
  final int typeId = 4;

  @override
  LocationInfo read(BinaryReader reader) {
    final latitude = reader.readDouble();
    final longitude = reader.readDouble();
    final placeName = reader.read() as String?;
    final address = reader.read() as String?;
    return LocationInfo(
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      address: address,
    );
  }

  @override
  void write(BinaryWriter writer, LocationInfo obj) {
    writer
      ..writeDouble(obj.latitude)
      ..writeDouble(obj.longitude)
      ..write(obj.placeName)
      ..write(obj.address);
  }
}
