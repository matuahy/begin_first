import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';

class NudgesScreen extends StatelessWidget {
  const NudgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Nudges'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: const EmptyState(message: 'No intents yet.'),
        ),
      ),
    );
  }
}
