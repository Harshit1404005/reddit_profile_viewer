import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/reddit_service.dart';
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
  final RedditService _redditService = RedditService.create();
  Map<String, dynamic> _metrics = {};
  Map<String, dynamic> _pulse = {};
  final TextEditingController _controller = TextEditingController();
  bool _loadingPulse = true;
  bool _showMIE = false;

  @override
  void initState() {
    super.initState();
    _loadCache();
    _loadPulse();
  }

  void _loadCache() {
    setState(() {
      _metrics = CacheService.getSystemMetrics();
    });
  }

  Future<void> _loadPulse() async {
    final pulse = await _redditService.getGlobalPulse();
    if (mounted) {
      setState(() {
        _pulse = pulse;
        _loadingPulse = false;
      });
    }
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SUBSONAR',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primary,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Text('REDDIT INTELLIGENCE ENGINE', style: TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant, letterSpacing: 1.5)),
              ],
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
                _buildModeToggle(),
                const SizedBox(height: 32),
                
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _showMIE ? _buildMIEHero(context) : _buildProfileAnalyzer(context),
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

  Widget _buildProfileAnalyzer(BuildContext context) {
    return Column(
      key: const ValueKey('profile'),
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
                  onSubmitted: (v) => widget.onSearch(v.trim()),
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
        
        // Community Pulse Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.bolt, color: AppTheme.tertiary, size: 14),
                const SizedBox(width: 8),
                Text('COMMUNITY PULSE', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            Text('REAL-TIME SIGNAL SYNTHESIS VIA PROXY', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.tertiary)),
            const SizedBox(height: 16),
            _loadingPulse 
              ? const LinearProgressIndicator(backgroundColor: AppTheme.surfaceContainer, color: AppTheme.tertiary)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...(_pulse['keywords'] as List? ?? []).take(5).map((k) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.tertiary.withAlpha(50)),
                      ),
                      child: Text(k.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.tertiary)),
                    )),
                  ],
                ),
          ],
        ).animate().fadeIn(delay: 1.seconds),
        
        const SizedBox(height: 48),
        
        // System Metrics
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _buildMetricCard(context, Icons.person_search, 'Users Analyzed', 
              _metrics['analyzed_count']?.toString() ?? '124', AppTheme.secondary),
            _buildMetricCard(context, Icons.timer, 'Search Speed', 
              _metrics['search_speed']?.toString() ?? '1.2s', AppTheme.tertiary),
            _buildMetricCard(context, Icons.verified, 'Accuracy Rating', 
              _metrics['accuracy_rating']?.toString() ?? '98.4%', AppTheme.primary),
            _buildMetricCard(context, Icons.privacy_tip, 'Priority Insights', 
              _metrics['hidden_count']?.toString() ?? '0', AppTheme.error),
          ],
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest.withAlpha((0.5 * 255).toInt()),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.outlineVariant.withAlpha((0.2 * 255).toInt())),
      ),
      padding: const EdgeInsets.all(4),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          _buildToggleButton('PROFILE ANALYZER', !_showMIE, FontAwesomeIcons.userSecret, () => setState(() => _showMIE = false)),
          _buildToggleButton('MARKET ENGINE', _showMIE, FontAwesomeIcons.satelliteDish, () => setState(() => _showMIE = true)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildToggleButton(String label, bool active, FaIconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryContainer.withAlpha((0.2 * 255).toInt()) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: active ? Border.all(color: AppTheme.primary.withAlpha((0.5 * 255).toInt())) : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 14, color: active ? AppTheme.primary : AppTheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2, color: active ? AppTheme.primary : AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildMIEHero(BuildContext context) {
    return Column(
      key: const ValueKey('mie'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.secondary.withOpacity(0.1), border: Border.all(color: AppTheme.secondary.withOpacity(0.3))),
          child: const FaIcon(FontAwesomeIcons.satelliteDish, color: AppTheme.secondary, size: 48).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds),
        ),
        const SizedBox(height: 32),
        Text('MARKET INTELLIGENCE ENGINE', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.secondary, letterSpacing: 2), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.tertiary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Text('CLOSED BETA WAITLIST', style: TextStyle(color: AppTheme.tertiary, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 32),
        const Text(
          'We are upgrading the Engine to support full semantic keyword and entity tracking.\n\nSoon, you will be able to search for any product, brand, or topic and instantly see which subreddits are discussing it, review the overall sentiment, and detect viral momentum spikes.',
          style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        GlassPanel(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildFeatureRow(context, FontAwesomeIcons.chartColumn, 'Volume Analytics & Spike Detection', AppTheme.primary),
              const SizedBox(height: 16),
              _buildFeatureRow(context, FontAwesomeIcons.masksTheater, 'NLP Topic & Sentiment Clustering', AppTheme.secondary),
              const SizedBox(height: 16),
              _buildFeatureRow(context, FontAwesomeIcons.mapLocationDot, 'Subreddit Dominance Demographics', AppTheme.tertiary),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, FaIconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: FaIcon(icon, color: color, size: 16)
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, color: AppTheme.onSurface))),
      ],
    );
  }
}
