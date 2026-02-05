import 'package:begin_first/app/providers.dart';
import 'package:begin_first/data/local/hive_initializer.dart';
import 'package:begin_first/domain/models/intent.dart';
import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/nudges/providers/intents_provider.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  const AppSettings({
    required this.isFirstLaunch,
    required this.notificationsEnabled,
    required this.locationEnabled,
  });

  final bool isFirstLaunch;
  final bool notificationsEnabled;
  final bool locationEnabled;

  AppSettings copyWith({
    bool? isFirstLaunch,
    bool? notificationsEnabled,
    bool? locationEnabled,
  }) {
    return AppSettings(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
    );
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(ref.read(hiveBoxesProvider));
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._boxes) : super(_load(_boxes));

  final HiveBoxes _boxes;
  static const _firstLaunchKey = 'isFirstLaunch';
  static const _notificationsKey = 'notificationsEnabled';
  static const _locationKey = 'locationEnabled';

  static AppSettings _load(HiveBoxes boxes) {
    final settings = boxes.settings;
    return AppSettings(
      isFirstLaunch: settings.get(_firstLaunchKey, defaultValue: true) as bool,
      notificationsEnabled: settings.get(_notificationsKey, defaultValue: true) as bool,
      locationEnabled: settings.get(_locationKey, defaultValue: true) as bool,
    );
  }

  Future<void> completeOnboarding() async {
    await _boxes.settings.put(_firstLaunchKey, false);
    state = state.copyWith(isFirstLaunch: false);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _boxes.settings.put(_notificationsKey, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> setLocationEnabled(bool enabled) async {
    await _boxes.settings.put(_locationKey, enabled);
    state = state.copyWith(locationEnabled: enabled);
  }
}

class AppStats {
  const AppStats({
    required this.itemCount,
    required this.recordCount,
    required this.activeIntentCount,
    required this.latestRecordAt,
  });

  final int itemCount;
  final int recordCount;
  final int activeIntentCount;
  final DateTime? latestRecordAt;
}

final appStatsProvider = Provider<AppStats>((ref) {
  final items = ref.watch(itemsStreamProvider).valueOrNull ?? const <Item>[];
  final records = ref.watch(recordsStreamProvider).valueOrNull ?? const <Record>[];
  final intents = ref.watch(intentsStreamProvider).valueOrNull ?? const <Intent>[];
  final activeIntents = intents.where((intent) => !intent.isCompleted).length;
  final latestRecordAt = records.isEmpty ? null : records.first.timestamp;

  return AppStats(
    itemCount: items.length,
    recordCount: records.length,
    activeIntentCount: activeIntents,
    latestRecordAt: latestRecordAt,
  );
});
