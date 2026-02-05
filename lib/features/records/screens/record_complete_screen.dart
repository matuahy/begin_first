import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/location_info.dart';
import 'package:begin_first/features/records/models/record_draft.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:begin_first/shared/widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecordCompleteScreen extends ConsumerStatefulWidget {
  const RecordCompleteScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<RecordCompleteScreen> createState() => _RecordCompleteScreenState();
}

class _RecordCompleteScreenState extends ConsumerState<RecordCompleteScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _attachLocation = false;
  bool _isSaving = false;
  bool _isLocating = false;
  LocationInfo? _location;

  @override
  void dispose() {
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(recordDraftProvider);

    if (draft == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Complete Record'),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Expanded(child: EmptyState(message: 'No draft available.')),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppButton(
                  label: 'Back',
                  onPressed: () => context.go('/items/${widget.itemId}'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Complete Record'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            PhotoViewer(path: draft.tempPhotoPath, height: 200),
            const SizedBox(height: AppSpacing.md),
            CupertinoFormSection.insetGrouped(
              header: const Text('Details'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _noteController,
                  placeholder: 'Note',
                ),
                CupertinoTextFormFieldRow(
                  controller: _tagsController,
                  placeholder: 'Tags (comma separated)',
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('Location'),
              children: [
                CupertinoFormRow(
                  prefix: const Text('Attach location'),
                  child: CupertinoSwitch(
                    value: _attachLocation,
                    onChanged: _isLocating ? null : _toggleLocation,
                  ),
                ),
                if (_attachLocation)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                    ),
                    child: _isLocating
                        ? const CupertinoActivityIndicator()
                        : Text(
                            _location == null
                                ? 'Location unavailable'
                                : _location!.address ?? '${_location!.latitude}, ${_location!.longitude}',
                          ),
                  ),
              ],
            ),
            AppButton(
              label: _isSaving ? 'Saving...' : 'Save Record',
              onPressed: _isSaving ? null : () => _saveRecord(draft),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLocation(bool value) async {
    setState(() {
      _attachLocation = value;
    });

    if (!value) {
      setState(() => _location = null);
      return;
    }

    setState(() => _isLocating = true);
    final location = await ref.read(locationServiceProvider).getCurrentLocation();
    if (mounted) {
      setState(() {
        _location = location;
        _isLocating = false;
      });
    }
  }

  Future<void> _saveRecord(RecordDraft draft) async {
    setState(() => _isSaving = true);
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    await ref.read(recordActionsProvider).saveRecord(
          draft: draft,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          tags: tags,
          location: _attachLocation ? _location : null,
        );

    ref.read(recordDraftProvider.notifier).state = null;
    if (mounted) {
      setState(() => _isSaving = false);
      context.go('/items/${widget.itemId}');
    }
  }
}
