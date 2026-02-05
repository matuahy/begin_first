import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/intent.dart' as model;
import 'package:begin_first/features/nudges/providers/intents_provider.dart';
import 'package:begin_first/features/nudges/providers/nudge_provider.dart';
import 'package:begin_first/features/nudges/widgets/intent_list_tile.dart';
import 'package:begin_first/features/nudges/widgets/nudge_card.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:begin_first/services/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NudgesScreen extends ConsumerWidget {
  const NudgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intentsAsync = ref.watch(intentsStreamProvider);
    final randomNudgeAsync = ref.watch(randomNudgeProvider);
    final pendingAsync = ref.watch(pendingNudgesProvider);
    final historyAsync = ref.watch(nudgeHistoryIdsProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('顺手'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.go('/nudges/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                isEmphasized: true,
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('今天顺手推进一点', style: AppTextStyles.heading),
                          SizedBox(height: AppSpacing.xs),
                          Text('不用计时，不追进度，做一点就算赢。', style: AppTextStyles.bodyMuted),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => ref.invalidate(randomNudgeProvider),
                      child: const Icon(CupertinoIcons.refresh),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('随机提醒', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              randomNudgeAsync.when(
                data: (intent) {
                  if (intent == null) {
                    return const EmptyState(
                      title: '暂无可用意图',
                      message: '先新增一条意图，系统会随机给你轻提醒。',
                      icon: CupertinoIcons.sparkles,
                      compact: true,
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NudgeCard(title: intent.title, subtitle: intent.nextStep),
                      const SizedBox(height: AppSpacing.sm),
                      _ScheduleRow(intent: intent),
                    ],
                  );
                },
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (error, stack) => EmptyState(
                  title: '加载提醒失败',
                  message: '$error',
                  icon: CupertinoIcons.exclamationmark_triangle,
                  compact: true,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('已安排', style: AppTextStyles.label),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () async {
                      await ref
                          .read(notificationServiceProvider)
                          .cancelAllNotifications();
                      ref.invalidate(pendingNudgesProvider);
                    },
                    child: const Text('全部取消'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              pendingAsync.when(
                data: (pending) {
                  if (pending.isEmpty) {
                    return const EmptyState(
                      title: '暂无已安排提醒',
                      message: '给随机提醒安排一个时间，稍后会准时出现。',
                      icon: CupertinoIcons.bell,
                      compact: true,
                    );
                  }
                  return Column(
                    children: pending
                        .map(
                          (nudge) => _PendingNudgeTile(nudge: nudge),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (error, stack) => EmptyState(
                  title: '读取失败',
                  message: '加载已安排提醒失败：$error',
                  icon: CupertinoIcons.exclamationmark_triangle,
                  compact: true,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('历史', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              historyAsync.when(
                data: (ids) {
                  final intents =
                      intentsAsync.valueOrNull ?? const <model.Intent>[];
                  final intentMap = {
                    for (final intent in intents) intent.id: intent
                  };
                  final historyIntents = ids
                      .map((id) => intentMap[id])
                      .whereType<model.Intent>()
                      .toList();

                  if (historyIntents.isEmpty) {
                    return const EmptyState(
                      title: '暂无历史',
                      message: '今天先顺手推进一条，历史会在这里沉淀。',
                      icon: CupertinoIcons.clock,
                      compact: true,
                    );
                  }

                  return Column(
                    children: historyIntents
                        .map(
                          (intent) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: NudgeCard(
                                title: intent.title, subtitle: intent.nextStep),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (error, stack) => EmptyState(
                  title: '加载历史失败',
                  message: '$error',
                  icon: CupertinoIcons.exclamationmark_triangle,
                  compact: true,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('意图池', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              intentsAsync.when(
                data: (intents) {
                  if (intents.isEmpty) {
                    return const EmptyState(
                      title: '还没有意图',
                      message: '写下一句你想推进的事，系统会在合适时机提醒你。',
                      icon: CupertinoIcons.pencil,
                      compact: true,
                    );
                  }
                  final active =
                      intents.where((intent) => !intent.isCompleted).toList();
                  final completed =
                      intents.where((intent) => intent.isCompleted).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (active.isNotEmpty) ...[
                        const Text('进行中', style: AppTextStyles.body),
                        const SizedBox(height: AppSpacing.sm),
                        ...active.map((intent) => _IntentTile(intent: intent)),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (completed.isNotEmpty) ...[
                        const Text('已完成', style: AppTextStyles.body),
                        const SizedBox(height: AppSpacing.sm),
                        ...completed.map((intent) => _IntentTile(intent: intent)),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (error, stack) => EmptyState(
                  title: '加载失败',
                  message: '加载意图失败：$error',
                  icon: CupertinoIcons.exclamationmark_triangle,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntentTile extends ConsumerWidget {
  const _IntentTile({required this.intent});

  final model.Intent intent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitleParts = <String>[];
    if (intent.nextStep != null && intent.nextStep!.isNotEmpty) {
      subtitleParts.add(intent.nextStep!);
    }
    if (intent.tags.isNotEmpty) {
      subtitleParts.add(intent.tags.join(', '));
    }
    final subtitle = subtitleParts.isEmpty ? null : subtitleParts.join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: IntentListTile(
        title: intent.title,
        subtitle: subtitle,
        isCompleted: intent.isCompleted,
        onTap: () => context.go('/nudges/${intent.id}/edit'),
        onCompletedChanged: (value) =>
            ref.read(intentActionsProvider).setCompleted(intent, value),
      ),
    );
  }
}

class _ScheduleRow extends ConsumerWidget {
  const _ScheduleRow({required this.intent});

  final model.Intent intent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          onPressed: () =>
              _schedule(context, ref, intent, const Duration(minutes: 30)),
          child: const Text('30分钟'),
        ),
        CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          onPressed: () =>
              _schedule(context, ref, intent, const Duration(hours: 2)),
          child: const Text('2小时'),
        ),
        CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          onPressed: () => _scheduleTonight(context, ref, intent),
          child: const Text('今晚9点'),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          onPressed: () => _pickCustom(context, ref, intent),
          child: const Text('选择时间'),
        ),
      ],
    );
  }

  Future<void> _schedule(
    BuildContext context,
    WidgetRef ref,
    model.Intent intent,
    Duration offset,
  ) async {
    final scheduled = DateTime.now().add(offset);
    await _scheduleAt(context, ref, intent, scheduled);
  }

  Future<void> _scheduleTonight(
      BuildContext context, WidgetRef ref, model.Intent intent) async {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, 21);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _scheduleAt(context, ref, intent, scheduled);
  }

  Future<void> _pickCustom(
      BuildContext context, WidgetRef ref, model.Intent intent) async {
    final initial = DateTime.now().add(const Duration(hours: 1));
    DateTime selected = initial;
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initial,
                  minimumDate: DateTime.now(),
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: CupertinoButton.filled(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('安排'),
                ),
              ),
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      await _scheduleAt(context, ref, intent, selected);
    }
  }

  Future<void> _scheduleAt(
    BuildContext context,
    WidgetRef ref,
    model.Intent intent,
    DateTime time,
  ) async {
    final success = await ref.read(nudgeActionsProvider).scheduleNudge(
          intent: intent,
          scheduledTime: time,
        );
    ref.invalidate(pendingNudgesProvider);
    if (!context.mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(success ? '已安排' : '需要权限'),
        content: Text(
          success ? '提醒已安排。' : '需要通知权限。',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _PendingNudgeTile extends ConsumerWidget {
  const _PendingNudgeTile({required this.nudge});

  final PendingNudge nudge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: NudgeCard(
        title: nudge.title ?? '提醒',
        subtitle: nudge.body,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await ref
                .read(notificationServiceProvider)
                .cancelNotification(nudge.id);
            ref.invalidate(pendingNudgesProvider);
          },
          child: const Icon(CupertinoIcons.xmark_circle),
        ),
      ),
    );
  }
}
