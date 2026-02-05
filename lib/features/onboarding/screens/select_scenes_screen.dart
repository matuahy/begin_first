import 'package:begin_first/features/onboarding/widgets/onboarding_page.dart';
import 'package:flutter/cupertino.dart';

class SelectScenesScreen extends StatelessWidget {
  const SelectScenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('选择场景'),
      ),
      child: const SafeArea(
        child: OnboardingPage(
          title: '设置场景',
          description: '定义常用场景，如家或公司。',
        ),
      ),
    );
  }
}
