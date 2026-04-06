import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SYSTEM CONFIG', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('ENGINE PARAMETERS AND INTERFACE SETTINGS', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 32),
            
            _buildSettingsSection(context, 'ENGINE', [
              _buildToggle(context, 'MOCK DATA MODE', true),
              _buildToggle(context, 'REAL-TIME UPDATES', false),
              _buildToggle(context, 'LOGGING LEVEL: VERBOSE', true),
            ]),
            const SizedBox(height: 32),
            _buildSettingsSection(context, 'INTERFACE', [
              _buildToggle(context, 'GLASSMORPHISM BLUR', true),
              _buildToggle(context, 'BENTO ANIMATIONS', true),
              _buildToggle(context, 'SYSTEM FEEDBACK', false),
            ]),
            const SizedBox(height: 32),
            Text('ABOUT', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('REDDIT_SCOPE INTELLIGENCE v1.0.4', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5, color: AppTheme.primary)),
        const SizedBox(height: 16),
        GlassPanel(
          padding: const EdgeInsets.all(16),
          borderRadius: 24,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildToggle(BuildContext context, String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
