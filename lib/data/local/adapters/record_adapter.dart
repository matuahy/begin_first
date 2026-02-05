import 'package:begin_first/domain/models/location_info.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:hive/hive.dart';

class RecordAdapter extends TypeAdapter<Record> {
  @override
  final int typeId = 1;

  @override
  Record read(BinaryReader reader) {
    final id = reader.readString();
    final itemId = reader.readString();
    final sceneId = reader.read() as String?;
    final photoPath = reader.readString();
    final timestamp = reader.readDateTime();
    final location = reader.read() as LocationInfo?;
    final note = reader.read() as String?;
    final tags = reader.readList().cast<String>();
    return Record(
      id: id,
      itemId: itemId,
      sceneId: sceneId,
      photoPath: photoPath,
      timestamp: timestamp,
      location: location,
      note: note,
      tags: tags,
    );
  }

  @override
  void write(BinaryWriter writer, Record obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.itemId)
      ..write(obj.sceneId)
      ..writeString(obj.photoPath)
      ..writeDateTime(obj.timestamp)
      ..write(obj.location)
      ..write(obj.note)
      ..writeList(obj.tags);
  }
}
