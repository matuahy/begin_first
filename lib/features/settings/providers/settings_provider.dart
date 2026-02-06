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
    required this.initialPermissionsRequested,
    required this.autoCheckoutEnabled,
  });

  final bool isFirstLaunch;
  final bool initialPermissionsRequested;
  final bool autoCheckoutEnabled;

  AppSettings copyWith({
    bool? isFirstLaunch,
    bool? initialPermissionsRequested,
    bool? autoCheckoutEnabled,
  }) {
    return AppSettings(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      initialPermissionsRequested: initialPermissionsRequested ?? this.initialPermissionsRequested,
      autoCheckoutEnabled: autoCheckoutEnabled ?? this.autoCheckoutEnabled,
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
  static const _initialPermissionsRequestedKey = 'initialPermissionsRequested';
  static const _autoCheckoutEnabledKey = 'autoCheckoutEnabled';

  static AppSettings _load(HiveBoxes boxes) {
    final settings = boxes.settings;
    return AppSettings(
      isFirstLaunch: settings.get(_firstLaunchKey, defaultValue: true) as bool,
      initialPermissionsRequested: settings.get(_initialPermissionsRequestedKey, defaultValue: false) as bool,
      autoCheckoutEnabled: settings.get(_autoCheckoutEnabledKey, defaultValue: true) as bool,
    );
  }

  Future<void> completeOnboarding() async {
    await _boxes.settings.put(_firstLaunchKey, false);
    state = state.copyWith(isFirstLaunch: false);
  }

  Future<void> markInitialPermissionsRequested() async {
    if (state.initialPermissionsRequested) {
      return;
    }
    await _boxes.settings.put(_initialPermissionsRequestedKey, true);
    state = state.copyWith(initialPermissionsRequested: true);
  }

  Future<void> setAutoCheckoutEnabled(bool enabled) async {
    await _boxes.settings.put(_autoCheckoutEnabledKey, enabled);
    state = state.copyWith(autoCheckoutEnabled: enabled);
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
