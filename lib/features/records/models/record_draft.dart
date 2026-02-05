import 'package:begin_first/domain/models/location_info.dart';

class RecordDraft {
  const RecordDraft({
    required this.itemId,
    required this.tempPhotoPath,
    required this.timestamp,
    this.sceneId,
    this.location,
    this.note,
    this.tags = const [],
  });

  final String itemId;
  final String tempPhotoPath;
  final DateTime timestamp;
  final String? sceneId;
  final LocationInfo? location;
  final String? note;
  final List<String> tags;

  RecordDraft copyWith({
    String? itemId,
    String? tempPhotoPath,
    DateTime? timestamp,
    String? sceneId,
    LocationInfo? location,
    String? note,
    List<String>? tags,
  }) {
    return RecordDraft(
      itemId: itemId ?? this.itemId,
      tempPhotoPath: tempPhotoPath ?? this.tempPhotoPath,
      timestamp: timestamp ?? this.timestamp,
      sceneId: sceneId ?? this.sceneId,
      location: location ?? this.location,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }
}
