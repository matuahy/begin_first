import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/utils/validators.dart';
import 'package:begin_first/domain/models/enums/scene_type.dart';
import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/scenes/providers/scene_detail_provider.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SceneFormScreen extends ConsumerStatefulWidget {
  const SceneFormScreen({this.sceneId, super.key});

  final String? sceneId;

  @override
  ConsumerState<SceneFormScreen> createState() => _SceneFormScreenState();
}

class _SceneFormScreenState extends ConsumerState<SceneFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  SceneType _type = SceneType.custom;
  bool _isActive = true;
  bool _geofenceEnabled = false;
  bool _isLocatingGeofence = false;
  double? _geofenceLatitude;
  double? _geofenceLongitude;
  double _geofenceRadiusMeters = 180;
  bool _initialized = false;
  bool _isSaving = false;
  final Set<String> _selectedItemIds = <String>{};

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sceneId != null;
    final scenesAsync = ref.watch(scenesStreamProvider);
    final itemsAsync = ref.watch(itemsStreamProvider);
    final scene = widget.sceneId == null
        ? null
        : ref.watch(sceneDetailProvider(widget.sceneId!));
    final items = itemsAsync.valueOrNull ?? const <Item>[];

    final itemRows = itemsAsync.when<List<Widget>>(
      data: (items) {
        if (items.isEmpty) {
          return const [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('暂无物品'),
            ),
          ];
        }
        return items
            .map(
              (item) => CupertinoFormRow(
                prefix: Text(item.name),
                child: CupertinoSwitch(
                  value: _selectedItemIds.contains(item.id),
                  onChanged: (value) => _toggleItem(item.id, value),
                ),
              ),
            )
            .toList();
      },
      loading: () => const [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ],
      error: (error, stack) => [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text('加载物品失败：$error'),
        ),
      ],
    );

    if (isEditing) {
      if (scenesAsync.isLoading) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('编辑场景')),
          child: Center(child: CupertinoActivityIndicator()),
        );
      }
      if (scenesAsync.hasError) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(middle: Text('编辑场景')),
          child: Center(child: Text('加载场景失败：${scenesAsync.error}')),
        );
      }
      if (scene == null) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('编辑场景')),
          child: Center(child: Text('未找到场景')),
        );
      }
    }

    if (!_initialized && scene != null) {
      _nameController.text = scene.name;
      _iconController.text = scene.iconName;
      _type = scene.type;
      _isActive = scene.isActive;
      _geofenceEnabled = scene.geofenceEnabled;
      _geofenceLatitude = scene.geofenceLatitude;
      _geofenceLongitude = scene.geofenceLongitude;
      _geofenceRadiusMeters = scene.geofenceRadiusMeters.toDouble();
      _selectedItemIds
        ..clear()
        ..addAll(scene.defaultItemIds);
      _initialized = true;
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? '编辑场景' : '新建场景'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : () => _save(scene, items),
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('场景信息'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  placeholder: '名称',
                ),
                CupertinoTextFormFieldRow(
                  controller: _iconController,
                  placeholder: '图标名称',
                ),
                CupertinoFormRow(
                  prefix: const Text('类型'),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _selectType,
                    child: Text(_sceneTypeLabel(_type)),
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('启用'),
                  child: CupertinoSwitch(
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('地理围栏（自动触发）'),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                  child: Text('系统级围栏最多同时生效 20 个场景。', style: AppTextStyles.caption),
                ),
                CupertinoFormRow(
                  prefix: const Text('自动出门检查'),
                  child: CupertinoSwitch(
                    value: _geofenceEnabled,
                    onChanged: (value) => setState(() {
                      _geofenceEnabled = value;
                      if (!value) {
                        _geofenceLatitude = null;
                        _geofenceLongitude = null;
                      }
                    }),
                  ),
                ),
                if (_geofenceEnabled) ...[
                  CupertinoFormRow(
                    prefix: const Text('围栏中心'),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _isLocatingGeofence ? null : _captureGeofenceCenter,
                      child: Text(_isLocatingGeofence ? '定位中...' : '使用当前位置'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                    child: Text(
                      _geofenceLatitude == null || _geofenceLongitude == null
                          ? '尚未设置围栏中心'
                          : '中心点：${_geofenceLatitude!.toStringAsFixed(5)}, ${_geofenceLongitude!.toStringAsFixed(5)}',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('围栏半径', style: AppTextStyles.body),
                        Text('${_geofenceRadiusMeters.round()} 米', style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
                    child: CupertinoSlider(
                      value: _geofenceRadiusMeters,
                      min: 80,
                      max: 500,
                      divisions: 21,
                      onChanged: (value) => setState(() => _geofenceRadiusMeters = value),
                    ),
                  ),
                ],
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('默认物品'),
              children: itemRows,
            ),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: Center(child: CupertinoActivityIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(Scene? scene, List<Item> items) async {
    final validation =
        Validators.requiredText(_nameController.text, message: '请填写名称');
    if (validation != null) {
      await _showMessage(validation);
      return;
    }

    if (_geofenceEnabled && (_geofenceLatitude == null || _geofenceLongitude == null)) {
      await _showMessage('请先设置围栏中心，或关闭自动出门检查。');
      return;
    }

    setState(() => _isSaving = true);
    final actions = ref.read(sceneActionsProvider);

    if (scene == null) {
      await actions.createScene(
        name: _nameController.text.trim(),
        type: _type,
        iconName: _iconController.text.trim().isEmpty
            ? 'scene'
            : _iconController.text.trim(),
        defaultItemIds: _orderedSelectedIds(items),
        isActive: _isActive,
        geofenceEnabled: _geofenceEnabled,
        geofenceLatitude: _geofenceEnabled ? _geofenceLatitude : null,
        geofenceLongitude: _geofenceEnabled ? _geofenceLongitude : null,
        geofenceRadiusMeters: _geofenceRadiusMeters.round(),
      );
    } else {
      final updated = Scene(
        id: scene.id,
        name: _nameController.text.trim(),
        type: _type,
        iconName: _iconController.text.trim().isEmpty
            ? scene.iconName
            : _iconController.text.trim(),
        defaultItemIds: _orderedSelectedIds(items),
        isActive: _isActive,
        geofenceEnabled: _geofenceEnabled,
        geofenceLatitude: _geofenceEnabled ? _geofenceLatitude : null,
        geofenceLongitude: _geofenceEnabled ? _geofenceLongitude : null,
        geofenceRadiusMeters: _geofenceRadiusMeters.round(),
        sortOrder: scene.sortOrder,
      );
      await actions.updateScene(updated);
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _captureGeofenceCenter() async {
    setState(() => _isLocatingGeofence = true);
    final location = await ref.read(locationServiceProvider).getCurrentLocation();
    if (!mounted) {
      return;
    }
    setState(() => _isLocatingGeofence = false);
    if (location == null) {
      await _showLocationPermissionDialog();
      return;
    }
    setState(() {
      _geofenceLatitude = location.latitude;
      _geofenceLongitude = location.longitude;
    });
  }

  Future<void> _showLocationPermissionDialog() async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('需要定位权限'),
        content: const Text('无法获取当前位置，请在系统设置中开启定位权限。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(permissionServiceProvider).openAppSettings();
            },
            child: const Text('打开设置'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMessage(String message) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _toggleItem(String itemId, bool value) {
    setState(() {
      if (value) {
        _selectedItemIds.add(itemId);
      } else {
        _selectedItemIds.remove(itemId);
      }
    });
  }

  List<String> _orderedSelectedIds(List<Item> items) {
    final ordered = <String>[];
    for (final item in items) {
      if (_selectedItemIds.contains(item.id)) {
        ordered.add(item.id);
      }
    }
    if (ordered.isEmpty) {
      return _selectedItemIds.toList();
    }
    return ordered;
  }

  Future<void> _selectType() async {
    final result = await showCupertinoModalPopup<SceneType>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('场景类型'),
          actions: SceneType.values
              .map(
                (type) => CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(type),
                  child: Text(_sceneTypeLabel(type)),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        );
      },
    );

    if (result != null) {
      setState(() => _type = result);
    }
  }

  String _sceneTypeLabel(SceneType type) {
    switch (type) {
      case SceneType.home:
        return '家';
      case SceneType.office:
        return '公司';
      case SceneType.parking:
        return '停车';
      case SceneType.travel:
        return '旅行';
      case SceneType.temporary:
        return '临时';
      case SceneType.custom:
        return '自定义';
    }
  }
}
