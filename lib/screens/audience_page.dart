import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/reddit_service.dart';
import '../models/reddit_models.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class AudiencePage extends StatefulWidget {
  final Function(RedditProfile) onViewProfile;
  const AudiencePage({super.key, required this.onViewProfile});

  @override
  State<AudiencePage> createState() => _AudiencePageState();
}

class _AudiencePageState extends State<AudiencePage> {
  final RedditService _redditService = RedditService.create();
  final TextEditingController _controller = TextEditingController();
  SubredditIntelligence? _intelligence;
  bool _loading = false;
  bool _deepScan = false;

  Future<void> _analyze() async {
    final sub = _controller.text.trim();
    if (sub.isEmpty) return;

    setState(() {
      _loading = true;
      _intelligence = null;
    });

    try {
      final intel = await _redditService.analyzeSubreddit(sub, deepScan: _deepScan);
      if (mounted) {
        setState(() {
          _intelligence = intel;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e'), backgroundColor: Colors.redAccent),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              _buildSearchSection(),
              const SizedBox(height: 32),
              Expanded(
                child: _loading 
                  ? _buildLoadingState()
                  : (_intelligence == null ? _buildEmptyState() : _buildResults()),
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
          'AUDIENCE VETTING',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primary,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 4),
        const Text(
          'DISCOVER HIGH-INTENT LEADS IN COMMUNITIES',
          style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant, letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Column(
        children: [
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Enter Subreddit (e.g. SaaS)',
              hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withAlpha(150)),
              prefixIcon: const Icon(Icons.groups_outlined, color: AppTheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onSubmitted: (_) => _analyze(),
          ),
          const Divider(color: AppTheme.secondary, height: 1),
          Row(
            children: [
              const Text('PRO DEEP SCAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const Spacer(),
              Switch(
                value: _deepScan, 
                onChanged: (v) => setState(() => _deepScan = v),
                activeColor: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('SCAN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 24),
          const Text('SIFTING THROUGH DATA...', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_deepScan ? 'FETCHING THOUSANDS OF SIGNALS' : 'SNAPPING RECENT ACTIVITY', 
            style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant)),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar_outlined, size: 64, color: AppTheme.onSurfaceVariant.withAlpha(50)),
          const SizedBox(height: 16),
          const Text('NO ACTIVE SCAN', style: TextStyle(color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          const Text('Enter a subreddit to identify potential leads', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildMetricSummary(),
        const SizedBox(height: 32),
        _buildKeywords(),
        const SizedBox(height: 32),
        const Text('TOP QUALIFIED LEADS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
        const SizedBox(height: 16),
        ..._intelligence!.qualifiedLeads.map((profile) => _buildLeadCard(profile)),
        const SizedBox(height: 100), // Bottom nav spacer
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMetricSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleStat('SENTIMENT', _intelligence!.sentiment, _getSentimentColor(_intelligence!.sentiment)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSimpleStat('ACTIVE USERS', _intelligence!.activeUsersCount.toString(), AppTheme.secondary),
        ),
      ],
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildKeywords() {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MARKET PAIN POINTS / KEYWORDS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _intelligence!.topKeywords.map((k) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withAlpha(50)),
              ),
              child: Text(k, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(RedditProfile profile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: InkWell(
          onTap: () => widget.onViewProfile(profile),
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
                    Text('u/${profile.username}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('HIGH ACTIVITY • POTENTIAL LEAD', style: TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSentimentColor(String s) {
    if (s == 'BULLISH') return Colors.greenAccent;
    if (s == 'FRUSTRATED') return Colors.redAccent;
    return AppTheme.secondary;
  }
}
