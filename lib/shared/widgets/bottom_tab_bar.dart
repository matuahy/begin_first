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
          label: 'Items',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.square_grid_2x2),
          label: 'Scenes',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.hand_draw),
          label: 'Nudges',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
