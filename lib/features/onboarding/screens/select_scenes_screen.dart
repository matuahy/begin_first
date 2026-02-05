import 'package:begin_first/features/onboarding/widgets/onboarding_page.dart';
import 'package:flutter/cupertino.dart';

class SelectScenesScreen extends StatelessWidget {
  const SelectScenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Select Scenes'),
      ),
      child: SafeArea(
        child: OnboardingPage(
          title: 'Set your scenes',
          description: 'Define common places like home or office.',
        ),
      ),
    );
  }
}
