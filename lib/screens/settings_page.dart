import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _offlineMode = false;
  bool _liveUpdates = true;
  bool _saveHistory = true;
  bool _blurEffects = true;
  bool _uiAnimations = true;
  bool _hapticFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _offlineMode = CacheService.getSetting('offline_mode', false);
      _liveUpdates = CacheService.getSetting('live_updates', true);
      _saveHistory = CacheService.getSetting('save_history', true);
      _blurEffects = CacheService.getSetting('blur_effects', true);
      _uiAnimations = CacheService.getSetting('ui_animations', true);
      _hapticFeedback = CacheService.getSetting('haptic_feedback', false);
    });
  }

  Future<void> _updateSetting(String key, bool value, Function(bool) updateState) async {
    await CacheService.setSetting(key, value);
    setState(() => updateState(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('APP SETTINGS', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('PREFERENCES AND VISUAL SETTINGS', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 32),
            
            _buildSettingsSection(context, 'SEARCH PREFERENCES', [
              _buildToggle('OFFLINE MODE', _offlineMode, (v) => _updateSetting('offline_mode', v, (val) => _offlineMode = val)),
              _buildToggle('LIVE UPDATES', _liveUpdates, (v) => _updateSetting('live_updates', v, (val) => _liveUpdates = val)),
              _buildToggle('SAVE SEARCH HISTORY', _saveHistory, (v) => _updateSetting('save_history', v, (val) => _saveHistory = val)),
            ]),
            const SizedBox(height: 32),
            _buildSettingsSection(context, 'VISUALS', [
              _buildToggle('BLUR EFFECTS', _blurEffects, (v) => _updateSetting('blur_effects', v, (val) => _blurEffects = val)),
              _buildToggle('UI ANIMATIONS', _uiAnimations, (v) => _updateSetting('ui_animations', v, (val) => _uiAnimations = val)),
              _buildToggle('HAPTIC FEEDBACK', _hapticFeedback, (v) => _updateSetting('haptic_feedback', v, (val) => _hapticFeedback = val)),
            ]),
            const SizedBox(height: 32),
            Text('ABOUT', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('REDINTEL v1.0.4', style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppTheme.onSurfaceVariant)),
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

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary.withAlpha((0.2 * 255).toInt()),
          ),
        ],
      ),
    );
  }
}
