import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final retrieveRecordsProvider = Provider.family<AsyncValue<List<Record>>, String>((ref, itemId) {
  return ref.watch(itemRecordsProvider(itemId));
});
