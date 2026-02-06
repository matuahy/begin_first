import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/extensions/datetime_ext.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/features/settings/providers/settings_provider.dart';
import 'package:begin_first/features/settings/widgets/stats_card.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final stats = ref.watch(appStatsProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('我的'),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: AppDecorations.card(emphasized: true),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('你的记录习惯', style: AppTextStyles.heading),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      stats.latestRecordAt == null
                          ? '最近记录：还没有记录'
                          : '最近记录：${stats.latestRecordAt!.fullDateTime}',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(child: StatsCard(title: '物品', value: '${stats.itemCount}')),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: StatsCard(title: '记录', value: '${stats.recordCount}')),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: StatsCard(title: '进行中', value: '${stats.activeIntentCount}')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Text('权限与提醒', style: AppTextStyles.label),
              ),
              const SizedBox(height: AppSpacing.sm),
              CupertinoFormSection.insetGrouped(
                backgroundColor: const Color(0x00000000),
                children: [
                  CupertinoFormRow(
                    prefix: const Text('通知'),
                    child: CupertinoSwitch(
                      value: settings.notificationsEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (value) => _toggleNotifications(context, ref, value),
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text('定位'),
                    child: CupertinoSwitch(
                      value: settings.locationEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (value) => _toggleLocation(context, ref, value),
                    ),
                  ),
                  CupertinoFormRow(
                    prefix: const Text('系统设置'),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => ref.read(permissionServiceProvider).openAppSettings(),
                      child: const Text('打开'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Text('维护', style: AppTextStyles.label),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: '清理未使用图片',
                leadingIcon: CupertinoIcons.trash,
                variant: AppButtonVariant.secondary,
                onPressed: () => _cleanImages(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(BuildContext context, WidgetRef ref, bool value) async {
    if (value) {
      final granted = await ref.read(notificationServiceProvider).requestNotificationPermission();
      if (!granted) {
        await _showMessage(context, '需要权限', '请在系统设置中开启通知权限。');
        return;
      }
    } else {
      await ref.read(notificationServiceProvider).cancelAllNotifications();
    }
    await ref.read(appSettingsProvider.notifier).setNotificationsEnabled(value);
  }

  Future<void> _toggleLocation(BuildContext context, WidgetRef ref, bool value) async {
    if (value) {
      final granted = await ref.read(permissionServiceProvider).ensureLocationPermission();
      if (!granted) {
        await _showMessage(context, '需要权限', '请在系统设置中开启定位权限。');
        return;
      }
    }
    await ref.read(appSettingsProvider.notifier).setLocationEnabled(value);
  }

  Future<void> _cleanImages(BuildContext context, WidgetRef ref) async {
    final recordsAsync = ref.read(recordsStreamProvider);
    if (!recordsAsync.hasValue) {
      await _showMessage(context, '请稍候', '记录仍在加载中。');
      return;
    }
    final records = recordsAsync.value ?? const [];
    final inUse = records.map((record) => record.photoPath).toSet();
    final removed = await ref.read(imageStorageServiceProvider).cleanupUnusedImages(inUse);
    await _showMessage(context, '清理完成', '已删除 $removed 张未使用图片。');
  }

  Future<void> _showMessage(BuildContext context, String title, String message) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
