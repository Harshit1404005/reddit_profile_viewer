import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../screens/home_page.dart';
import '../screens/history_page.dart';
import '../screens/signals_page.dart';
import '../screens/settings_page.dart';

class NavigationShell extends StatefulWidget {
  final Function(String) onSearch; // Triggers the Scanning state in Orchestrator

  const NavigationShell({super.key, required this.onSearch});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onSearch: widget.onSearch),
      HistoryPage(),
      SignalsPage(),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildPremiumBottomNav(context),
    );
  }

  Widget _buildPremiumBottomNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: GlassPanel(
        borderRadius: 32,
        blur: 24,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, FontAwesomeIcons.magnifyingGlass, 'SEARCH'),
            _buildNavItem(context, 1, FontAwesomeIcons.clockRotateLeft, 'HISTORY'),
            _buildNavItem(context, 2, FontAwesomeIcons.chartLine, 'TRENDS'),
            _buildNavItem(context, 3, FontAwesomeIcons.gear, 'SETTINGS'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, FaIconData icon, String label) {
    final bool active = _currentIndex == index;
    final Color color = active ? AppTheme.primary : AppTheme.onSurfaceVariant.withOpacity(0.4);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryContainer.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
