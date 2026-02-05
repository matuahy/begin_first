import 'package:begin_first/features/onboarding/widgets/onboarding_page.dart';
import 'package:flutter/cupertino.dart';

class SelectItemsScreen extends StatelessWidget {
  const SelectItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Select Items'),
      ),
      child: const SafeArea(
        child: OnboardingPage(
          title: 'Pick your essentials',
          description: 'Choose items you want to track first.',
        ),
      ),
    );
  }
}
