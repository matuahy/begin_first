import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:begin_first/domain/models/item.dart';
import 'package:hive/hive.dart';

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0;

  @override
  Item read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final category = reader.read() as Category;
    final importance = reader.read() as Importance;
    final coverImagePath = reader.read() as String?;
    final iconName = reader.read() as String?;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return Item(
      id: id,
      name: name,
      category: category,
      importance: importance,
      coverImagePath: coverImagePath,
      iconName: iconName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..write(obj.category)
      ..write(obj.importance)
      ..write(obj.coverImagePath)
      ..write(obj.iconName)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch)
      ..writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}
