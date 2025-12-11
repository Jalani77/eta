import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'syllabus_input_screen.dart';
import '../theme/yiri_theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DashboardScreen(),
      SyllabusInputScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_idx]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        indicatorColor: YiriTheme.yiriRed.withOpacity(0.12),
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: YiriTheme.yiriRed),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note, color: YiriTheme.yiriRed),
            label: 'Syllabus',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: YiriTheme.yiriRed),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
