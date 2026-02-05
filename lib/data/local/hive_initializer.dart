import 'package:begin_first/core/constants/storage_keys.dart';
import 'package:begin_first/data/local/adapters/category_adapter.dart';
import 'package:begin_first/data/local/adapters/importance_adapter.dart';
import 'package:begin_first/data/local/adapters/intent_adapter.dart';
import 'package:begin_first/data/local/adapters/item_adapter.dart';
import 'package:begin_first/data/local/adapters/location_info_adapter.dart';
import 'package:begin_first/data/local/adapters/record_adapter.dart';
import 'package:begin_first/data/local/adapters/scene_adapter.dart';
import 'package:begin_first/data/local/adapters/scene_type_adapter.dart';
import 'package:begin_first/domain/models/intent.dart';
import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter();

  Hive
    ..registerAdapter(ItemAdapter())
    ..registerAdapter(RecordAdapter())
    ..registerAdapter(SceneAdapter())
    ..registerAdapter(IntentAdapter())
    ..registerAdapter(LocationInfoAdapter())
    ..registerAdapter(CategoryAdapter())
    ..registerAdapter(ImportanceAdapter())
    ..registerAdapter(SceneTypeAdapter());

  await Hive.openBox<Item>(StorageKeys.items);
  await Hive.openBox<Record>(StorageKeys.records);
  await Hive.openBox<Scene>(StorageKeys.scenes);
  await Hive.openBox<Intent>(StorageKeys.intents);
  await Hive.openBox(StorageKeys.settings);
  await Hive.openBox<String>(StorageKeys.nudgeHistory);
}

class HiveBoxes {
  Box<Item> get items => Hive.box<Item>(StorageKeys.items);
  Box<Record> get records => Hive.box<Record>(StorageKeys.records);
  Box<Scene> get scenes => Hive.box<Scene>(StorageKeys.scenes);
  Box<Intent> get intents => Hive.box<Intent>(StorageKeys.intents);
  Box get settings => Hive.box(StorageKeys.settings);
  Box<String> get nudgeHistory => Hive.box<String>(StorageKeys.nudgeHistory);
}
