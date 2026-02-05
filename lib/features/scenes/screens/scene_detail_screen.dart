import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';

class SceneDetailScreen extends StatelessWidget {
  const SceneDetailScreen({required this.sceneId, super.key});

  final String sceneId;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Scene Detail'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Scene ID: $sceneId'),
              const SizedBox(height: AppSpacing.md),
              const Expanded(
                child: EmptyState(message: 'No records yet.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
