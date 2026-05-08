import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// 五 Tab 外壳：中间「发布」为凸起圆形加号。
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _labels = ['首页', '社区', '发布', '数据', '我的'];
  static const _icons = [
    Icons.home_rounded,
    Icons.forum_outlined,
    Icons.add,
    Icons.insights_outlined,
    Icons.person_outline_rounded,
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.paddingOf(context).bottom + 6,
        ),
        child: SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavItem(
                        label: _labels[0],
                        icon: _icons[0],
                        selected: idx == 0,
                        onTap: () => _onTap(0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        label: _labels[1],
                        icon: _icons[1],
                        selected: idx == 1,
                        onTap: () => _onTap(1),
                      ),
                    ),
                    const SizedBox(width: 56),
                    Expanded(
                      child: _NavItem(
                        label: _labels[3],
                        icon: _icons[3],
                        selected: idx == 3,
                        onTap: () => _onTap(3),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        label: _labels[4],
                        icon: _icons[4],
                        selected: idx == 4,
                        onTap: () => _onTap(4),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -14,
                child: Material(
                  color: TinyBurnColors.primary,
                  elevation: 6,
                  shadowColor: Colors.black26,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _onTap(2),
                    child: const SizedBox(
                      width: 58,
                      height: 58,
                      child: Icon(
                        Icons.add,
                        size: 30,
                        color: TinyBurnColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: selected ? TinyBurnColors.primary : TinyBurnColors.textSecondary,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? TinyBurnColors.textPrimary : TinyBurnColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
