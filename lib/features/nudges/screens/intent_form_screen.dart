import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';

class IntentFormScreen extends StatelessWidget {
  const IntentFormScreen({this.intentId, super.key});

  final String? intentId;

  @override
  Widget build(BuildContext context) {
    final title = intentId == null ? 'New Intent' : 'Edit Intent';
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: const EmptyState(message: 'Intent form goes here.'),
        ),
      ),
    );
  }
}
