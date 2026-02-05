import 'package:begin_first/features/onboarding/widgets/onboarding_page.dart';
import 'package:flutter/cupertino.dart';

class SelectItemsScreen extends StatelessWidget {
  const SelectItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('选择物品'),
      ),
      child: const SafeArea(
        child: OnboardingPage(
          title: '选择常用物品',
          description: '先选择想要记录的物品。',
        ),
      ),
    );
  }
}
