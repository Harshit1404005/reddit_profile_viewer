import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/reddit_models.dart';
import 'theme/app_theme.dart';
import 'screens/splash_page.dart';
import 'screens/scanning_page.dart';
import 'screens/dashboard_page.dart';
import 'widgets/navigation_shell.dart';
import 'services/cache_service.dart';

Future<void> main() async {
  // Ensure animations and environment are ready
  WidgetsFlutterBinding.ensureInitialized();
  Animate.restartOnHotReload = true;
  
  try {
    await dotenv.load(fileName: ".env");
    await CacheService.init(); // Initialize Hive and Adapters
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const RedditScopeApp());
}

class RedditScopeApp extends StatelessWidget {
  const RedditScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PersonaPulse Insights',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainOrchestrator(),
    );
  }
}

enum AppState { splash, home, scanning, dashboard }

class MainOrchestrator extends StatefulWidget {
  const MainOrchestrator({super.key});

  @override
  State<MainOrchestrator> createState() => _MainOrchestratorState();
}

class _MainOrchestratorState extends State<MainOrchestrator> {
  AppState _currentState = AppState.splash;
  String? _searchUsername;
  RedditProfile? _scannedProfile;

  void _navigateTo(AppState state, {String? username, RedditProfile? profile}) {
    setState(() {
      _currentState = state;
      if (username != null) _searchUsername = username;
      if (profile != null) _scannedProfile = profile;
    });
  }

  void _onViewHistoryProfile(RedditProfile profile) {
    _navigateTo(AppState.dashboard, profile: profile);
  }

  void _onReScan(String username) {
    _navigateTo(AppState.scanning, username: username);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.05, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentState) {
      case AppState.splash:
        return SplashPage(
          key: const ValueKey('splash'),
          onInitialized: () => _navigateTo(AppState.home),
        );
      case AppState.home:
        return NavigationShell(
          key: const ValueKey('navigation_shell'),
          onSearch: (username) => _navigateTo(AppState.scanning, username: username),
          onViewProfile: _onViewHistoryProfile,
          onReScan: _onReScan,
        );
      case AppState.scanning:
        return ScanningPage(
          key: const ValueKey('scanning'),
          username: _searchUsername ?? 'DeepMind',
          onScanComplete: (profile) => _navigateTo(AppState.dashboard, profile: profile),
        );
      case AppState.dashboard:
        return DashboardPage(
          key: const ValueKey('dashboard'),
          profile: _scannedProfile,
          onReset: () => _navigateTo(AppState.home),
        );
    }
  }
}
