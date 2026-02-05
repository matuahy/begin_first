import 'package:begin_first/shared/widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';

class RecordViewer extends StatelessWidget {
  const RecordViewer({required this.photoPath, this.note, super.key});

  final String? photoPath;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoViewer(path: photoPath),
        if (note != null) ...[
          const SizedBox(height: 12),
          Text(note!),
        ],
      ],
    );
  }
}
