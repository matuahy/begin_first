import 'package:begin_first/app/providers.dart';
import 'package:begin_first/core/utils/id_generator.dart';
import 'package:begin_first/core/utils/image_utils.dart';
import 'package:begin_first/domain/models/location_info.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/domain/repositories/item_repository.dart';
import 'package:begin_first/domain/repositories/record_repository.dart';
import 'package:begin_first/features/records/models/record_draft.dart';
import 'package:begin_first/services/image_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recordDraftProvider = StateProvider<RecordDraft?>((ref) => null);

final recordsStreamProvider = StreamProvider<List<Record>>((ref) {
  final box = ref.read(hiveBoxesProvider).records;
  List<Record> buildList() {
    final records = box.values.toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Stream<List<Record>> stream() async* {
    yield buildList();
    yield* box.watch().map((_) => buildList());
  }

  return stream();
});

final recordDetailProvider = StreamProvider.family<Record?, String>((ref, recordId) {
  final box = ref.read(hiveBoxesProvider).records;
  Stream<Record?> stream() async* {
    yield box.get(recordId);
    yield* box.watch(key: recordId).map((_) => box.get(recordId));
  }

  return stream();
});

final latestRecordProvider = Provider.family<Record?, String>((ref, itemId) {
  final records = ref.watch(itemRecordsProvider(itemId)).valueOrNull ?? const <Record>[];
  if (records.isEmpty) {
    return null;
  }
  return records.first;
});

final itemRecordsProvider = StreamProvider.family<List<Record>, String>((ref, itemId) {
  final box = ref.read(hiveBoxesProvider).records;
  List<Record> buildList() {
    final records = box.values.where((record) => record.itemId == itemId).toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Stream<List<Record>> stream() async* {
    yield buildList();
    yield* box.watch().map((_) => buildList());
  }

  return stream();
});

final sceneRecordsProvider = StreamProvider.family<List<Record>, String>((ref, sceneId) {
  final box = ref.read(hiveBoxesProvider).records;
  List<Record> buildList() {
    final records = box.values.where((record) => record.sceneId == sceneId).toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Stream<List<Record>> stream() async* {
    yield buildList();
    yield* box.watch().map((_) => buildList());
  }

  return stream();
});

final recordActionsProvider = Provider<RecordActions>((ref) {
  return RecordActions(
    recordRepository: ref.read(recordRepositoryProvider),
    itemRepository: ref.read(itemRepositoryProvider),
    imageStorageService: ref.read(imageStorageServiceProvider),
  );
});

class RecordActions {
  RecordActions({
    required this.recordRepository,
    required this.itemRepository,
    required this.imageStorageService,
  });

  final RecordRepository recordRepository;
  final ItemRepository itemRepository;
  final ImageStorageService imageStorageService;

  Future<Record> saveRecord({
    required RecordDraft draft,
    String? note,
    List<String>? tags,
    LocationInfo? location,
  }) async {
    final fileName = ImageUtils.buildFileName(
      itemId: draft.itemId,
      timestamp: draft.timestamp,
    );
    final storedPath = await imageStorageService.saveImage(
      draft.tempPhotoPath,
      fileName: fileName,
    );
    final record = Record(
      id: IdGenerator.newId(),
      itemId: draft.itemId,
      sceneId: draft.sceneId,
      photoPath: storedPath,
      timestamp: draft.timestamp,
      location: location ?? draft.location,
      note: note ?? draft.note,
      tags: tags ?? draft.tags,
    );
    await recordRepository.createRecord(record);

    final item = await itemRepository.getItemById(draft.itemId);
    if (item != null) {
      final updated = item.copyWith(
        coverImagePath: storedPath,
        updatedAt: DateTime.now(),
      );
      await itemRepository.updateItem(updated);
    }

    return record;
  }

  Future<void> updateRecord(Record record) async {
    await recordRepository.updateRecord(record);
  }

  Future<void> deleteRecord(Record record) async {
    await recordRepository.deleteRecord(record.id);
    await imageStorageService.deleteImage(record.photoPath);

    final latest = await recordRepository.getLatestRecordByItemId(record.itemId);
    final item = await itemRepository.getItemById(record.itemId);
    if (item != null) {
      final updated = item.copyWith(
        coverImagePath: latest?.photoPath,
        updatedAt: DateTime.now(),
      );
      await itemRepository.updateItem(updated);
    }
  }
}
