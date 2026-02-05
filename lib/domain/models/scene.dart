import 'package:begin_first/domain/models/enums/scene_type.dart';

class Scene {
  const Scene({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    this.defaultItemIds = const [],
    this.isActive = true,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final SceneType type;
  final String iconName;
  final List<String> defaultItemIds;
  final bool isActive;
  final int sortOrder;

  Scene copyWith({
    String? id,
    String? name,
    SceneType? type,
    String? iconName,
    List<String>? defaultItemIds,
    bool? isActive,
    int? sortOrder,
  }) {
    return Scene(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      defaultItemIds: defaultItemIds ?? this.defaultItemIds,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
