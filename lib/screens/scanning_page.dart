import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';

import '../services/reddit_service.dart';
import '../models/reddit_models.dart';

class ScanningPage extends StatefulWidget {
  final String username;
  final Function(RedditProfile) onScanComplete;

  const ScanningPage({
    super.key,
    required this.username,
    required this.onScanComplete,
  });

  @override
  State<ScanningPage> createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage> {
  final RedditService _redditService = RedditService.create();
  String _currentStep = 'Initializing Engine';
  double _progress = 0.1;
  bool _profileComplete = false;
  bool _activityComplete = false;
  bool _analysisComplete = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    try {
      // 1. Fetch Profile
      setState(() {
        _currentStep = 'Fetching Profile: u/${widget.username}';
        _progress = 0.3;
      });
      await Future.delayed(const Duration(seconds: 1)); // Visual delay for HUD feel
      
      // 2. Fetch Comprehensive Activity
      setState(() {
        _profileComplete = true;
        _currentStep = 'Mapping Total Activity Stream';
        _progress = 0.6;
      });
      
      // Perform the actual overview analysis
      final profile = await _redditService.analyzeUser(widget.username);
      
      setState(() {
        _activityComplete = true;
        _currentStep = 'Synthesizing Neural Map';
        _progress = 0.9;
      });
      
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _analysisComplete = true;
        _progress = 1.0;
      });
      
      widget.onScanComplete(profile);
    } catch (e) {
      debugPrint('Scan Error: $e');
      // Fallback or error UI would go here
      widget.onScanComplete(RedditProfile(
        username: widget.username,
        totalKarma: 0,
        accountAge: 'Unknown',
        status: 'OFFLINE',
        toxicity: 0.0,
        nsfw: 0.0,
        controversialIndex: 0.0,
        recentPosts: [],
        recentComments: [],
        afterToken: null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Intelligence Texture (Glows)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryContainer.withAlpha(50)),
            ).animate().blur(begin: const Offset(120, 120), end: const Offset(120, 120)),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.secondary.withAlpha(30)),
            ).animate().blur(begin: const Offset(150, 150), end: const Offset(150, 150)),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassPanel(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 24 : 48),
                    borderRadius: 40,
                    child: Column(
                      children: [
                        // Progress Ring
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width < 600 ? 100 : 140,
                              height: MediaQuery.of(context).size.width < 600 ? 100 : 140,
                              child: CircularProgressIndicator(
                                value: _progress,
                                strokeWidth: MediaQuery.of(context).size.width < 600 ? 6 : 10,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                backgroundColor: AppTheme.primary.withOpacity(0.1),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(FontAwesomeIcons.robot, color: AppTheme.primary, size: MediaQuery.of(context).size.width < 600 ? 24 : 32),
                                Text(
                                  '${(_progress * 100).toInt()}%',
                                  style: MediaQuery.of(context).size.width < 600 
                                    ? Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)
                                    : Theme.of(context).textTheme.headlineLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Status Section
                        Text(
                          'Connecting to Reddit...',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2, color: AppTheme.primary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Target: u/${widget.username}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 64),
                        
                        // Animated Progress Steps
                        _buildProgressStep(context, 'Analyzing profile data...', 0.2),
                        _buildProgressStep(context, 'Gathering history...', 0.5),
                        _buildProgressStep(context, 'Finalizing results...', 0.8),
                        
                        const SizedBox(height: 48),
                        
                        // Step List
                        _buildStatusStep(
                          context, 
                          'Identity Resolution', 
                          _profileComplete ? 'Complete' : (_progress < 0.6 ? 'Active' : 'Complete'), 
                          AppTheme.tertiary, 
                          _profileComplete, 
                          0
                        ),
                        const SizedBox(height: 12),
                        _buildStatusStep(
                          context, 
                          'Behavioral Mapping', 
                          _activityComplete ? 'Complete' : (_progress >= 0.6 && _progress < 0.9 ? 'Active' : 'Queued'), 
                          AppTheme.primary, 
                          _activityComplete, 
                          1
                        ),
                        const SizedBox(height: 12),
                        _buildStatusStep(
                          context, 
                          'Neural Synthesis', 
                          _analysisComplete ? 'Complete' : (_progress >= 0.9 ? 'Active' : 'Queued'), 
                          AppTheme.secondary, 
                          _analysisComplete, 
                          2
                        ),
                      ],
                    ),
                  ).animate().scale(delay: 400.ms).fadeIn(),
                  
                  const SizedBox(height: 48),
                  
                  // Metadata Footer
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.tertiary)),
                          const SizedBox(width: 8),
                          Text('SYSTEM ONLINE: ${_redditService.mode}', style: Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scanning u/${widget.username}. All Reddit data encrypted during synthesis.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1.seconds),
                ],
              ),
            ),
          ),
          
          // Scanning Line Animation
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryContainer.withAlpha(50),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ).animate(onPlay: (c) => c.repeat())
                    .moveY(begin: -100, end: 800, duration: 3.seconds, curve: Curves.easeInOut),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(BuildContext context, String label, String status, Color color, bool completed, int index) {
    bool isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? AppTheme.surfaceContainerHigh.withOpacity(0.4) : (isActive ? AppTheme.primaryContainer.withOpacity(0.1) : AppTheme.surfaceContainer.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? AppTheme.primary.withAlpha(50) : AppTheme.outlineVariant.withAlpha(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
                  child: FaIcon(
                    completed ? FontAwesomeIcons.circleCheck : (isActive ? FontAwesomeIcons.microchip : FontAwesomeIcons.user),
                    color: color,
                    size: 16,
                  ).animate(onPlay: (c) => isActive ? c.repeat() : null).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds).then().scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1)),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    label, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? AppTheme.primary : AppTheme.onSurface)
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(status.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    ).animate().fadeIn(delay: (600 + (index * 200)).ms).slideX(begin: 0.1, end: 0);
  }
}
