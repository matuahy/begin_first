import 'package:begin_first/features/onboarding/widgets/onboarding_page.dart';
import 'package:flutter/cupertino.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Welcome'),
      ),
      child: const SafeArea(
        child: OnboardingPage(
          title: 'Welcome',
          description: 'Record where your essentials live in seconds.',
        ),
      ),
    );
  }
}
