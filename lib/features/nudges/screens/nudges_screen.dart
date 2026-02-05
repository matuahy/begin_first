import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/intent.dart' as app_intent;
import 'package:begin_first/features/nudges/providers/intents_provider.dart';
import 'package:begin_first/features/nudges/providers/nudge_provider.dart';
import 'package:begin_first/features/nudges/widgets/intent_list_tile.dart';
import 'package:begin_first/features/nudges/widgets/nudge_card.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NudgesScreen extends ConsumerWidget {
  const NudgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intentsAsync = ref.watch(intentsStreamProvider);
    final randomNudgeAsync = ref.watch(randomNudgeProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Nudges'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.go('/nudges/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Random Nudge',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => ref.invalidate(randomNudgeProvider),
                  child: const Icon(CupertinoIcons.refresh),
                ),
              ],
            ),
            randomNudgeAsync.when(
              data: (intent) {
                if (intent == null) {
                  return const EmptyState(message: 'No active intents yet.');
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
              error: (error, stack) =>
                  EmptyState(message: 'Failed to load nudge: $error'),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Intents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            intentsAsync.when(
              data: (intents) {
                if (intents.isEmpty) {
                  return const EmptyState(message: 'No intents yet.');
                }
                final active =
                    intents.where((intent) => !intent.isCompleted).toList();
                final completed =
                    intents.where((intent) => intent.isCompleted).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (active.isNotEmpty) ...[
                      const Text('Active',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      ...active.map((intent) => _IntentTile(intent: intent)),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (completed.isNotEmpty) ...[
                      const Text('Completed',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      ...completed.map((intent) => _IntentTile(intent: intent)),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, stack) =>
                  EmptyState(message: 'Failed to load intents: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntentTile extends ConsumerWidget {
  const _IntentTile({required this.intent});

  final app_intent.Intent intent;

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

  final app_intent.Intent intent;

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
          child: const Text('30 min'),
        ),
        CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          onPressed: () =>
              _schedule(context, ref, intent, const Duration(hours: 2)),
          child: const Text('2 hours'),
        ),
        CupertinoButton.filled(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          onPressed: () => _scheduleTonight(context, ref, intent),
          child: const Text('Tonight 9pm'),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          onPressed: () => _pickCustom(context, ref, intent),
          child: const Text('Pick time'),
        ),
      ],
    );
  }

  Future<void> _schedule(
    BuildContext context,
    WidgetRef ref,
    app_intent.Intent intent,
    Duration offset,
  ) async {
    final scheduled = DateTime.now().add(offset);
    await _scheduleAt(context, ref, intent, scheduled);
  }

  Future<void> _scheduleTonight(
      BuildContext context, WidgetRef ref, app_intent.Intent intent) async {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, 21);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _scheduleAt(context, ref, intent, scheduled);
  }

  Future<void> _pickCustom(
      BuildContext context, WidgetRef ref, app_intent.Intent intent) async {
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
                  child: const Text('Schedule'),
                ),
              ),
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
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
    app_intent.Intent intent,
    DateTime time,
  ) async {
    final success = await ref.read(nudgeActionsProvider).scheduleNudge(
          intent: intent,
          scheduledTime: time,
        );
    if (!context.mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(success ? 'Scheduled' : 'Permission Needed'),
        content: Text(
          success
              ? 'Reminder scheduled.'
              : 'Notification permission is required.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
