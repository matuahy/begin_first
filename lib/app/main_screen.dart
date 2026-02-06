import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:begin_first/features/checkout/providers/checkout_provider.dart';
import 'package:begin_first/services/system_geofence_service.dart';
import 'package:begin_first/shared/widgets/bottom_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  String? _lastTriggeredSceneId;
  Timer? _geofencePollTimer;
  final ReceivePort _geofenceReceivePort = ReceivePort();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    IsolateNameServer.removePortNameMapping(systemGeofenceSendPortName);
    IsolateNameServer.registerPortWithName(_geofenceReceivePort.sendPort, systemGeofenceSendPortName);
    _geofenceReceivePort.listen((_) {
      if (mounted) {
        ref.invalidate(checkoutGeofenceTriggerProvider);
      }
    });
    _geofencePollTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (mounted) {
        ref.invalidate(checkoutGeofenceTriggerProvider);
      }
    });
  }

  @override
  void dispose() {
    _geofencePollTimer?.cancel();
    _geofenceReceivePort.close();
    IsolateNameServer.removePortNameMapping(systemGeofenceSendPortName);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(checkoutGeofenceTriggerProvider);
    }
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CheckoutGeofenceTrigger?>>(checkoutGeofenceTriggerProvider, (previous, next) {
      final trigger = next.valueOrNull;
      if (trigger == null) {
        _lastTriggeredSceneId = null;
        return;
      }
      if (_lastTriggeredSceneId == trigger.sceneId) {
        return;
      }
      _lastTriggeredSceneId = trigger.sceneId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _startCheckoutFromTrigger(trigger));
    });

    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: widget.navigationShell),
          BottomTabBar(
            currentIndex: widget.navigationShell.currentIndex,
            onTap: _onTap,
          ),
        ],
      ),
    );
  }

  Future<void> _startCheckoutFromTrigger(CheckoutGeofenceTrigger trigger) async {
    if (!mounted) {
      return;
    }

    await ref.read(checkoutGeofenceActionsProvider).markTriggerHandled();
    ref.invalidate(checkoutGeofenceTriggerProvider);

    if (!mounted) {
      return;
    }

    final currentPath = GoRouterState.of(context).uri.path;
    ref.read(checkoutSceneProvider.notifier).state = trigger.sceneId;
    ref.read(checkoutCheckedProvider.notifier).state = <String>{};

    if (currentPath != '/checkout') {
      GoRouter.of(context).push('/checkout');
    }
  }
}
