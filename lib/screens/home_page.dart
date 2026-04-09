import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../services/cache_service.dart';
import '../models/reddit_models.dart';

class HomePage extends StatefulWidget {
  final Function(String) onSearch;

  const HomePage({super.key, required this.onSearch});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<RedditProfile> _history = [];
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadCache();
  }

  void _loadCache() {
    setState(() {
      _history = CacheService.getHistory();
      _metrics = CacheService.getSystemMetrics();
    });
  }

  Future<void> _clearHistory() async {
    await CacheService.clearHistory();
    _loadCache();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.surface.withAlpha((0.8 * 255).toInt()),
                AppTheme.surface.withAlpha(0),
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: null,
            title: Text(
              'REDINTEL INSIGHTS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.circleUser, size: 18, color: AppTheme.primary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Dynamic Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    AppTheme.primary.withAlpha((0.05 * 255).toInt()),
                    AppTheme.surface,
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
            child: Column(
              children: [
                // Hero Section
                Text(
                  'REDDIT PROFILE ANALYZER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 32 : 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.primary,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                const Text(
                  'Instantly analyze public and hidden profiles. Transform any user footprint into a clean, actionable activity summary.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Search Input
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        borderRadius: 20,
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Reddit username...',
                            hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withAlpha((0.3 * 255).toInt())),
                            icon: FaIcon(FontAwesomeIcons.at, color: AppTheme.primary, size: 18),
                          ),
                        ),
                      ).animate().scale(delay: 600.ms),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => widget.onSearch(_controller.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryContainer],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'ANALYZE PROFILE',
                                  style: TextStyle(
                                    color: AppTheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FaIcon(
                                  FontAwesomeIcons.chartBar,
                                  size: 20,
                                  color: AppTheme.surface,
                                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 800.ms).shimmer(duration: 2.seconds),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Intelligence Logs Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RECENT INSIGHTS', style: Theme.of(context).textTheme.headlineMedium),
                        Text('SAVED ANALYSIS LOGS', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
                      ],
                    ),
                    TextButton(
                      onPressed: _clearHistory,
                      child: const Text('Clear History', style: TextStyle(color: AppTheme.secondary)),
                    ),
                  ],
                ).animate().fadeIn(delay: 1.seconds),
                
                const SizedBox(height: 16),
                
                // Bento Grid
                _history.isEmpty 
                  ? _buildActionCard(context, 'Monitor New User', 'Real-time signal tracking')
                  : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: (_history.length >= 2 ? 3 : _history.length + 1),
                    itemBuilder: (context, index) {
                      if (index < _history.length && index < 2) {
                        final p = _history[index];
                        final sectors = p.recentComments.isNotEmpty 
                          ? p.recentComments.take(2).map((c) => c.subreddit.replaceAll('r/', '')).join(', ')
                          : 'General Activity';
                        return _buildLogCard(
                          context,
                          'u/${p.username}',
                          sectors,
                          p.status,
                          p.accountAge,
                          p.status == 'HIDDEN' ? AppTheme.error : AppTheme.primary,
                          AppTheme.secondary,
                        );
                      }
                      return _buildActionCard(context, 'Monitor New User', 'Real-time signal tracking');
                    },
                  ).animate().fadeIn(delay: 1.2.seconds).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 48),
                
                // System Metrics
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMetricCard(context, Icons.person_search, 'Users Analyzed', 
                      _metrics['analyzed_count']?.toString() ?? '124.8k', AppTheme.secondary),
                    _buildMetricCard(context, Icons.timer, 'Search Speed', 
                      _metrics['search_speed']?.toString() ?? '1.2s', AppTheme.tertiary),
                    _buildMetricCard(context, Icons.verified, 'Accuracy Rating', 
                      _metrics['accuracy_rating']?.toString() ?? '98.4%', AppTheme.primary),
                    _buildMetricCard(context, Icons.warning, 'Flagged Accounts', '0', AppTheme.error),
                  ],
                ),
              ],
            ),
          ),
          
          // Bottom Navigation
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, String user, String focus, String tag1, String tag2, Color color1, Color color2) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(FontAwesomeIcons.chartLine, color: AppTheme.primary, size: 16),
              ),
              Text('2M AGO', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const Spacer(),
          Text(user, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Focus: $focus', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
          const Spacer(),
          Row(
            children: [
              _buildTag(tag1, color1),
              const SizedBox(width: 8),
              _buildTag(tag2, color2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withAlpha((0.5 * 255).toInt()),
        border: Border.all(color: AppTheme.outlineVariant.withAlpha((0.2 * 255).toInt()), width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withAlpha((0.05 * 255).toInt()),
            ),
            child: FaIcon(FontAwesomeIcons.plus, color: AppTheme.primary),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withAlpha((0.4 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withAlpha((0.7 * 255).toInt()), size: 16),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 9, letterSpacing: 1.0)),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ],
      ),
    );
  }
}
