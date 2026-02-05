import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:hive/hive.dart';

class ImportanceAdapter extends TypeAdapter<Importance> {
  @override
  final int typeId = 6;

  @override
  Importance read(BinaryReader reader) {
    final index = reader.readInt();
    return Importance.values[index];
  }

  @override
  void write(BinaryWriter writer, Importance obj) {
    writer.writeInt(obj.index);
  }
}
