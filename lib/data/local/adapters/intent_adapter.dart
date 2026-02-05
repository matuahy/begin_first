import 'package:begin_first/domain/models/intent.dart';
import 'package:hive/hive.dart';

class IntentAdapter extends TypeAdapter<Intent> {
  @override
  final int typeId = 3;

  @override
  Intent read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final nextStep = reader.read() as String?;
    final tags = reader.readList().cast<String>();
    final isCompleted = reader.readBool();
    final createdAt = reader.readDateTime();
    final updatedAt = reader.readDateTime();
    return Intent(
      id: id,
      title: title,
      nextStep: nextStep,
      tags: tags,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, Intent obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..write(obj.nextStep)
      ..writeList(obj.tags)
      ..writeBool(obj.isCompleted)
      ..writeDateTime(obj.createdAt)
      ..writeDateTime(obj.updatedAt);
  }
}
