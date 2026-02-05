import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/features/records/widgets/record_timeline.dart';
import 'package:begin_first/features/retrieve/providers/retrieve_provider.dart';
import 'package:begin_first/features/retrieve/widgets/location_card.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:begin_first/shared/widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RetrieveScreen extends ConsumerWidget {
  const RetrieveScreen({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(retrieveRecordsProvider(itemId));

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Retrieve'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: recordsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return const EmptyState(message: 'No records to show.');
              }

              final latest = records.first;
              final location = latest.location;

              return ListView(
                children: [
                  PhotoViewer(path: latest.photoPath, height: 220),
                  const SizedBox(height: AppSpacing.md),
                  if (location != null)
                    LocationCard(
                      title: location.placeName ?? 'Location',
                      subtitle: location.address ?? '${location.latitude}, ${location.longitude}',
                      onTap: () => ref.read(locationServiceProvider).openInMaps(
                            location.latitude,
                            location.longitude,
                            location.placeName,
                          ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  RecordTimeline(records: records),
                ],
              );
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, stack) => EmptyState(message: 'Failed to load records: $error'),
          ),
        ),
      ),
    );
  }
}
