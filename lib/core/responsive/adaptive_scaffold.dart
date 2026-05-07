import 'package:flutter/material.dart';
import 'breakpoints.dart';
import '../../theme/app_colors.dart';

class AdaptiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> destinations;
  final Widget body;

  const AdaptiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  static const _navItems = [
    NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Beranda'),
    NavigationDestination(icon: Icon(Icons.gavel_rounded), label: 'Pengadaan'),
    NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Statistik'),
    NavigationDestination(icon: Icon(Icons.account_balance_rounded), label: 'Ekonomi'),
    NavigationDestination(icon: Icon(Icons.warning_amber_rounded), label: 'Bencana'),
  ];

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          destinations: _navItems,
        ),
      );
    }

    // Tablet/Desktop: NavigationRail
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            extended: AppBreakpoints.isDesktop(context),
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primary.withOpacity(0.15),
            destinations: _navItems.map((d) => NavigationRailDestination(
              icon: d.icon,
              label: Text(d.label),
            )).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
