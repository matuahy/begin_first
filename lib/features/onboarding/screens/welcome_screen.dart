import 'package:begin_first/features/onboarding/widgets/onboarding_page.dart';
import 'package:flutter/cupertino.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('欢迎'),
      ),
      child: const SafeArea(
        child: OnboardingPage(
          title: '欢迎使用',
          description: '用最短时间记录随身物品的位置。',
        ),
      ),
    );
  }
}
