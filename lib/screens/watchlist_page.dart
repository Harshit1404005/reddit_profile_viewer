import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/cache_service.dart';
import '../services/reddit_service.dart';
import '../models/reddit_models.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class WatchlistPage extends StatefulWidget {
  final Function(RedditProfile) onViewProfile;
  const WatchlistPage({super.key, required this.onViewProfile});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final RedditService _redditService = RedditService.create();
  List<String> _watchlist = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  void _loadWatchlist() {
    setState(() {
      _watchlist = CacheService.getWatchlist();
    });
  }

  Future<void> _vetUser(String username) async {
    setState(() => _loading = true);
    try {
      final profile = await _redditService.analyzeUser(username);
      if (mounted) {
        widget.onViewProfile(profile);
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vetting failed: $e'), backgroundColor: Colors.redAccent),
        );
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _remove(String username) async {
    await CacheService.removeFromWatchlist(username);
    _loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.background, AppTheme.surface],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              Expanded(
                child: _loading 
                  ? _buildLoadingState()
                  : (_watchlist.isEmpty ? _buildEmptyState() : _buildList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WATCHLIST',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primary,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 4),
        const Text(
          'MONITORING HIGH-VALUE TARGETS & CUSTOMERS',
          style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant, letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_outlined, size: 64, color: AppTheme.onSurfaceVariant.withAlpha(50)),
          const SizedBox(height: 16),
          const Text('WATCHLIST IS EMPTY', style: TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          const Text('Profiles or leads you track will appear here', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _watchlist.length,
      itemBuilder: (context, index) {
        final username = _watchlist[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassPanel(
            padding: const EdgeInsets.all(16),
            borderRadius: 20,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryContainer),
                  child: const Center(child: FaIcon(FontAwesomeIcons.circleUser, color: Colors.white70, size: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('u/$username', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('STATUS: MONITORING', style: TextStyle(fontSize: 9, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.analytics_outlined, color: AppTheme.primary, size: 20),
                  tooltip: 'View Full Report',
                  onPressed: () => _vetUser(username),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _remove(username),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }
}
