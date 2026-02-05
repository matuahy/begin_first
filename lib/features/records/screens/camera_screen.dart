import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/features/records/models/record_draft.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/features/scenes/providers/scene_record_provider.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({required this.itemId, this.sceneId, super.key});

  final String itemId;
  final String? sceneId;

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sceneRecordSessionProvider);
    final progress = session != null && session.sceneId == widget.sceneId
        ? '${session.currentIndex + 1}/${session.itemIds.length}'
        : null;
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Record Photo'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (progress != null) ...[
                Text('Scene recording $progress',
                    style: const TextStyle(color: CupertinoColors.secondaryLabel)),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: CupertinoColors.systemRed),
                ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: _isLoading ? 'Loading...' : 'Take Photo',
                onPressed: _isLoading ? null : _takePhoto,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: _isLoading ? 'Loading...' : 'Pick from Gallery',
                onPressed: _isLoading ? null : _pickFromGallery,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final permissionGranted = await ref.read(permissionServiceProvider).ensureCameraPermission();
    if (!permissionGranted) {
      setState(() {
        _isLoading = false;
        _error = 'Camera permission denied';
      });
      return;
    }

    final path = await ref.read(cameraServiceProvider).takePhoto();
    await _handlePhoto(path);
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final path = await ref.read(cameraServiceProvider).pickFromGallery();
    await _handlePhoto(path);
  }

  Future<void> _handlePhoto(String? path) async {
    if (path == null || path.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No photo selected';
      });
      return;
    }

    ref.read(recordDraftProvider.notifier).state = RecordDraft(
      itemId: widget.itemId,
      tempPhotoPath: path,
      timestamp: DateTime.now(),
      sceneId: widget.sceneId,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/items/${widget.itemId}/record/complete');
    }
  }
}
