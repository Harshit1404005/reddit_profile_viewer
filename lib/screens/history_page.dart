import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INTEL CACHE', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('ARCHIVED SCAN RESULTS AND SESSION LOGS', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 32),
            
            _buildHistoryItem(context, 'u/InsightfulRedditor', '4Y 2M', 'TECH, SCIENCE', AppTheme.primary),
            const SizedBox(height: 16),
            _buildHistoryItem(context, 'u/GlobalAdmin', '8Y 6M', 'ADMIN, MODERATION', AppTheme.secondary),
            const SizedBox(height: 16),
            _buildHistoryItem(context, 'u/DeepCoder', '2Y 1M', 'PYTHON, AI, EDGE', AppTheme.tertiary),
            const SizedBox(height: 16),
            _buildHistoryItem(context, 'u/CryptoWizard', '3Y 11M', 'FINANCE, BLOCKCHAIN', AppTheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String user, String age, String sectors, Color color) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                child: const Text('RE-SCAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
