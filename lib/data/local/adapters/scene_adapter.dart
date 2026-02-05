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
    return Scene(
      id: id,
      name: name,
      type: type,
      iconName: iconName,
      defaultItemIds: defaultItemIds,
      isActive: isActive,
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
      ..writeInt(obj.sortOrder);
  }
}
