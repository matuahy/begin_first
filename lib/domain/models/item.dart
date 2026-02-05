import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';

class Item {
  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.importance,
    this.coverImagePath,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final Category category;
  final Importance importance;
  final String? coverImagePath;
  final String? iconName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item copyWith({
    String? id,
    String? name,
    Category? category,
    Importance? importance,
    String? coverImagePath,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      importance: importance ?? this.importance,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
