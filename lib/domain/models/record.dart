import 'package:begin_first/domain/models/location_info.dart';

class Record {
  const Record({
    required this.id,
    required this.itemId,
    this.sceneId,
    required this.photoPath,
    required this.timestamp,
    this.location,
    this.note,
    this.tags = const [],
  });

  final String id;
  final String itemId;
  final String? sceneId;
  final String photoPath;
  final DateTime timestamp;
  final LocationInfo? location;
  final String? note;
  final List<String> tags;

  Record copyWith({
    String? id,
    String? itemId,
    String? sceneId,
    String? photoPath,
    DateTime? timestamp,
    LocationInfo? location,
    String? note,
    List<String>? tags,
  }) {
    return Record(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      sceneId: sceneId ?? this.sceneId,
      photoPath: photoPath ?? this.photoPath,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }
}
