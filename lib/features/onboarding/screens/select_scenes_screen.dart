import 'package:begin_first/features/onboarding/widgets/onboarding_page.dart';
import 'package:flutter/cupertino.dart';

class SelectScenesScreen extends StatelessWidget {
  const SelectScenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Select Scenes'),
      ),
      child: const SafeArea(
        child: OnboardingPage(
          title: 'Set your scenes',
          description: 'Define common places like home or office.',
        ),
      ),
    );
  }
}
