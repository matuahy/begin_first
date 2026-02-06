import 'package:begin_first/app/theme.dart';
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 14,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        activeColor: AppColors.primary,
        inactiveColor: AppColors.textTertiary,
        backgroundColor: AppColors.tabBarBackground.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.7),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cube_box),
            activeIcon: Icon(CupertinoIcons.cube_box),
            label: '物品',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            activeIcon: Icon(CupertinoIcons.square_grid_2x2),
            label: '场景',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.sparkles),
            activeIcon: Icon(CupertinoIcons.sparkles),
            label: '顺手',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_crop_circle),
            activeIcon: Icon(CupertinoIcons.person_crop_circle),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
