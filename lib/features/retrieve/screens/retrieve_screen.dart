import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/features/records/widgets/record_timeline.dart';
import 'package:begin_first/features/retrieve/providers/retrieve_provider.dart';
import 'package:begin_first/features/retrieve/widgets/location_card.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:begin_first/shared/widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RetrieveScreen extends ConsumerWidget {
  const RetrieveScreen({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(retrieveRecordsProvider(itemId));

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('找回'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: recordsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return const EmptyState(message: '暂无记录');
              }

              final latest = records.first;
              final location = latest.location;

              return ListView(
                children: [
                  PhotoViewer(path: latest.photoPath, height: 220),
                  const SizedBox(height: AppSpacing.md),
                  if (location != null)
                    LocationCard(
                      title: location.placeName ?? '位置',
                      subtitle: location.address ?? '${location.latitude}, ${location.longitude}',
                      onTap: () => ref.read(locationServiceProvider).openInMaps(
                            location.latitude,
                            location.longitude,
                            location.placeName,
                          ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('历史记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  RecordTimeline(
                    records: records,
                    onRecordTap: (record) => context.go('/records/${record.id}'),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, stack) => EmptyState(message: '加载记录失败：$error'),
          ),
        ),
      ),
    );
  }
}
