import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/reddit_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class SignalsPage extends StatefulWidget {
  const SignalsPage({super.key});

  @override
  State<SignalsPage> createState() => _SignalsPageState();
}

class _SignalsPageState extends State<SignalsPage> {
  final RedditService _redditService = RedditService.create();
  Map<String, dynamic> _pulse = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPulse();
  }

  Future<void> _loadPulse() async {
    final data = await _redditService.getGlobalPulse();
    if (mounted) {
      setState(() {
        _pulse = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keywords = (_pulse['keywords'] as List? ?? []);
    final subreddits = (_pulse['subreddits'] as List? ?? []);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMMUNITY INSIGHTS', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text('REAL-TIME POPULARITY VECTORS', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.tertiary.withAlpha((0.1 * 255).toInt()), border: Border.all(color: AppTheme.tertiary.withAlpha((0.2 * 255).toInt()))),
                  child: const FaIcon(FontAwesomeIcons.bolt, color: AppTheme.tertiary, size: 16).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            if (_loading) 
              const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            else ...[
              _buildSignalMetric(context, 'ACTIVE SUBREDDITS', subreddits.isNotEmpty ? subreddits.first.toString().toUpperCase() : 'HOT', AppTheme.primary, '+12.4%'),
              const SizedBox(height: 16),
              _buildSignalMetric(context, 'GLOBAL SENTIMENT', _pulse['sentiment'] ?? 'STABLE', AppTheme.secondary, 'NEUTRAL'),
              
              const SizedBox(height: 32),
              Text('TRENDING KEYWORDS', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              ...keywords.map((k) => _buildTrendingRow(context, k.toString(), 'HIGH', AppTheme.primary)),
              const SizedBox(height: 24),
              Text('ACTIVE COMMUNITIES', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              ...subreddits.map((s) => _buildTrendingRow(context, s.toString().toUpperCase(), 'MEDIUM', AppTheme.secondary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalMetric(BuildContext context, String label, String value, Color color, String delta) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).toInt()), borderRadius: BorderRadius.circular(12)),
            child: Text(delta, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingRow(BuildContext context, String label, String density, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 4)])),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2))),
          Text(density, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
