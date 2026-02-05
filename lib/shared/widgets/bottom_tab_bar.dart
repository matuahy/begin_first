import 'package:flutter/cupertino.dart';

class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.square_list),
          label: '物品',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.square_grid_2x2),
          label: '场景',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.hand_draw),
          label: '顺手',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings),
          label: '设置',
        ),
      ],
    );
  }
}
