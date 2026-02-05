import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/extensions/datetime_ext.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/features/records/widgets/record_card.dart';
import 'package:flutter/cupertino.dart';

class RecordTimeline extends StatelessWidget {
  const RecordTimeline({
    required this.records,
    this.onRecordTap,
    super.key,
  });

  final List<Record> records;
  final ValueChanged<Record>? onRecordTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final subtitleParts = <String>[];
        final location = record.location?.placeName ?? record.location?.address;
        if (location != null && location.isNotEmpty) {
          subtitleParts.add(location);
        }
        if (record.note != null && record.note!.isNotEmpty) {
          subtitleParts.add(record.note!);
        }
        final subtitle = subtitleParts.isEmpty ? null : subtitleParts.join(' · ');
        return RecordCard(
          title: record.timestamp.fullDateTime,
          subtitle: subtitle,
          onTap: onRecordTap == null ? null : () => onRecordTap!(record),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
    );
  }
}
