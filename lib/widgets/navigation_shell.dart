import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../screens/home_page.dart';
import '../screens/history_page.dart';
import '../screens/audience_page.dart';
import '../screens/watchlist_page.dart';
import '../screens/settings_page.dart';

import '../models/reddit_models.dart';

class NavigationShell extends StatefulWidget {
  final Function(String) onSearch; 
  final Function(RedditProfile) onViewProfile;
  final Function(String) onReScan;

  const NavigationShell({
    super.key, 
    required this.onSearch,
    required this.onViewProfile,
    required this.onReScan,
  });

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
      AudiencePage(onViewProfile: widget.onViewProfile),
      WatchlistPage(onViewProfile: widget.onViewProfile),
      HistoryPage(onViewProfile: widget.onViewProfile, onReScan: widget.onReScan),
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
            _buildNavItem(context, 0, FontAwesomeIcons.magnifyingGlass, 'VET'),
            _buildNavItem(context, 1, FontAwesomeIcons.usersViewfinder, 'AUDIENCE'),
            _buildNavItem(context, 2, FontAwesomeIcons.binoculars, 'WATCHLIST'),
            _buildNavItem(context, 3, FontAwesomeIcons.clockRotateLeft, 'HISTORY'),
            _buildNavItem(context, 4, FontAwesomeIcons.gear, 'SETTINGS'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, FaIconData icon, String label) {
    final bool active = _currentIndex == index;
    final Color color = active ? AppTheme.primary : AppTheme.onSurfaceVariant.withAlpha((0.4 * 255).toInt());

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryContainer.withAlpha((0.1 * 255).toInt()) : Colors.transparent,
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
