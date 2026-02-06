import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/extensions/datetime_ext.dart';
import 'package:begin_first/features/checkout/providers/checkout_provider.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/features/settings/providers/settings_provider.dart';
import 'package:begin_first/features/settings/widgets/stats_card.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(appStatsProvider);
    final settings = ref.watch(appSettingsProvider);

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
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoFormRow(
                      padding: EdgeInsets.zero,
                      prefix: const Text('自动出门检查'),
                      child: CupertinoSwitch(
                        value: settings.autoCheckoutEnabled,
                        onChanged: (value) => _toggleAutoCheckout(ref, value),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text('权限仅在首次启动请求一次', style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      '地理围栏依赖“始终允许定位”。如需修改通知、定位或相机权限，请前往系统设置。',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: '查看隐私说明',
                      leadingIcon: CupertinoIcons.shield,
                      variant: AppButtonVariant.ghost,
                      onPressed: () => _showPrivacyNote(context),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: '打开系统设置',
                      leadingIcon: CupertinoIcons.settings,
                      variant: AppButtonVariant.ghost,
                      onPressed: () => ref.read(permissionServiceProvider).openAppSettings(),
                    ),
                  ],
                ),
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

  Future<void> _toggleAutoCheckout(WidgetRef ref, bool value) async {
    await ref.read(appSettingsProvider.notifier).setAutoCheckoutEnabled(value);
    ref.invalidate(checkoutGeofenceTriggerProvider);
  }

  Future<void> _showPrivacyNote(BuildContext context) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('隐私说明'),
        content: const Text(
          '地理围栏仅用于自动触发出门检查，位置信息保存在本地设备，不会上传到远端。你可随时关闭自动出门检查或在系统设置中关闭定位权限。',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
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
