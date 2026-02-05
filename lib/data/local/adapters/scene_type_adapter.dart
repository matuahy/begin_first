import 'package:begin_first/domain/models/enums/scene_type.dart';
import 'package:hive/hive.dart';

class SceneTypeAdapter extends TypeAdapter<SceneType> {
  @override
  final int typeId = 7;

  @override
  SceneType read(BinaryReader reader) {
    final index = reader.readInt();
    return SceneType.values[index];
  }

  @override
  void write(BinaryWriter writer, SceneType obj) {
    writer.writeInt(obj.index);
  }
}
