import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../services/cache_service.dart';

class HistoryPage extends StatelessWidget {
  final Function(RedditProfile) onViewProfile;
  final Function(String) onReScan;

  const HistoryPage({
    super.key, 
    required this.onViewProfile, 
    required this.onReScan
  });

  @override
  Widget build(BuildContext context) {
    final history = CacheService.getHistory();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SAVED INSIGHTS', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('ARCHIVED ANALYSIS LOGS AND PROFILE DATA', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 32),
            
            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Column(
                    children: [
                      FaIcon(FontAwesomeIcons.folderOpen, color: AppTheme.onSurfaceVariant.withAlpha(50), size: 48),
                      const SizedBox(height: 16),
                      const Text('NO ARCHIVED LOGS FOUND', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 10, letterSpacing: 2)),
                    ],
                  ),
                ),
              )
            else
              ...history.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => onViewProfile(p),
                  borderRadius: BorderRadius.circular(24),
                  child: _buildHistoryItem(
                    context, 
                    'u/${p.username}', 
                    p.accountAge, 
                    p.recentComments.isNotEmpty 
                        ? p.recentComments.take(2).map((c) => c.subreddit.replaceAll('r/', '')).join(', ')
                        : 'GENERAL', 
                    p.status == 'HIDDEN' ? AppTheme.error : AppTheme.primary,
                    () => onReScan(p.username),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String user, String age, String sectors, Color color, VoidCallback onReScan) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).toInt()), borderRadius: BorderRadius.circular(12)),
            child: Center(child: FaIcon(FontAwesomeIcons.user, color: color, size: 20)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Sectors: $sectors', style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(age, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onReScan,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                  child: const Text('RE-SCAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
