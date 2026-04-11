import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class SignalsPage extends StatelessWidget {
  const SignalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withOpacity(0.1), border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
                child: const FaIcon(FontAwesomeIcons.satelliteDish, color: AppTheme.primary, size: 48).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds),
              ),
              const SizedBox(height: 32),
              
              Text('MARKET INTELLIGENCE ENGINE', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primary, letterSpacing: 2), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text('CLOSED BETA WAITLIST', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
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
                    _buildFeatureRow(context, FontAwesomeIcons.chartColumn, 'Volume Analytics & Spike Detection'),
                    const SizedBox(height: 20),
                    _buildFeatureRow(context, FontAwesomeIcons.masksTheater, 'NLP Topic & Sentiment Clustering'),
                    const SizedBox(height: 20),
                    _buildFeatureRow(context, FontAwesomeIcons.mapLocationDot, 'Subreddit Dominance Demographics'),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.1), shape: BoxShape.circle),
          child: FaIcon(icon, color: AppTheme.secondary, size: 16)
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, color: AppTheme.textPrimary))),
      ],
    );
  }
}

