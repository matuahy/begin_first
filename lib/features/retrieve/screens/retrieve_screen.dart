import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/extensions/datetime_ext.dart';
import 'package:begin_first/features/records/widgets/record_timeline.dart';
import 'package:begin_first/features/retrieve/providers/retrieve_provider.dart';
import 'package:begin_first/features/retrieve/widgets/location_card.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:begin_first/shared/widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RetrieveScreen extends ConsumerStatefulWidget {
  const RetrieveScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<RetrieveScreen> createState() => _RetrieveScreenState();
}

class _RetrieveScreenState extends ConsumerState<RetrieveScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(retrieveRecordsProvider(widget.itemId));

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('找回'),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const EmptyState(
                    title: '暂无记录',
                    message: '先记录一次物品位置，找回模式会在这里给你线索。',
                    icon: CupertinoIcons.search,
                  );
                }

                final safeIndex = _currentIndex >= records.length ? records.length - 1 : _currentIndex;
                if (safeIndex != _currentIndex) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _currentIndex = safeIndex);
                    }
                  });
                }

                final current = records[safeIndex];
                final location = current.location;
                final hasPrevious = safeIndex < records.length - 1;
                final hasNext = safeIndex > 0;

                return ListView(
                  children: [
                    GestureDetector(
                      onHorizontalDragEnd: (details) => _handleSwipe(details.primaryVelocity, safeIndex, records.length),
                      child: AppCard(
                        isEmphasized: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('当前线索', style: AppTextStyles.heading),
                            const SizedBox(height: AppSpacing.sm),
                            PhotoViewer(path: current.photoPath, height: 220),
                            const SizedBox(height: AppSpacing.sm),
                            Text('记录于 ${current.timestamp.fullDateTime}', style: AppTextStyles.bodyMuted),
                            const SizedBox(height: AppSpacing.xs),
                            const Text('提示：左右滑动可切换线索', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: '上一条',
                              leadingIcon: CupertinoIcons.chevron_left,
                              variant: AppButtonVariant.ghost,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.sm),
                              onPressed: hasPrevious ? () => _setIndex(safeIndex + 1, records.length) : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text('${safeIndex + 1}/${records.length}', style: AppTextStyles.bodyMuted),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppButton(
                              label: '下一条',
                              trailingIcon: CupertinoIcons.chevron_right,
                              variant: AppButtonVariant.ghost,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.sm),
                              onPressed: hasNext ? () => _setIndex(safeIndex - 1, records.length) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (location != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      LocationCard(
                        title: location.placeName ?? '位置',
                        subtitle: location.address ?? '${location.latitude}, ${location.longitude}',
                        onTap: () => ref.read(locationServiceProvider).openInMaps(
                              location.latitude,
                              location.longitude,
                              location.placeName,
                            ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: '找到了，更新当前位置',
                      leadingIcon: CupertinoIcons.check_mark_circled,
                      onPressed: () => context.push('/items/${widget.itemId}/record'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('历史记录', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.sm),
                    RecordTimeline(
                      records: records,
                      onRecordTap: (record) => context.push('/records/${record.id}'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, stack) => EmptyState(
                title: '加载记录失败',
                message: '$error',
                icon: CupertinoIcons.exclamationmark_triangle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setIndex(int index, int total) {
    if (total == 0) {
      return;
    }
    final clamped = index < 0
        ? 0
        : (index >= total ? total - 1 : index);
    setState(() => _currentIndex = clamped);
  }

  void _handleSwipe(double? velocity, int currentIndex, int total) {
    final speed = velocity ?? 0;
    if (speed <= -120) {
      _setIndex(currentIndex + 1, total);
    } else if (speed >= 120) {
      _setIndex(currentIndex - 1, total);
    }
  }
}
