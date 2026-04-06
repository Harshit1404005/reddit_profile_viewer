import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../models/reddit_models.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback onReset;
  final RedditProfile? profile;

  const DashboardPage({super.key, required this.onReset, this.profile});

  @override
  Widget build(BuildContext context) {
    final bool hasData = profile != null;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: GlassPanel(
          borderRadius: 0,
          blur: 16,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: AppTheme.primaryContainer, 
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 2),
                  ),
                  child: const Center(child: FaIcon(FontAwesomeIcons.robot, size: 20, color: Colors.white)),
                ),
              ],
            ),
            title: Text(
              'RedditScope',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary, letterSpacing: 2),
            ),
            actions: [
              _buildNavAction('Home'),
              _buildNavAction('History'),
              _buildNavAction('Settings'),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Export', style: TextStyle(color: AppTheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Identity Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(hasData ? 'u/${profile!.username}' : 'u/NoSession', style: Theme.of(context).textTheme.headlineLarge),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer.withAlpha(20), 
                                borderRadius: BorderRadius.circular(20), 
                                border: Border.all(color: AppTheme.primary.withAlpha(50)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8, 
                                    height: 8, 
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle, 
                                      color: AppTheme.primary, 
                                      boxShadow: [BoxShadow(color: AppTheme.primary, blurRadius: 4)],
                                    ),
                                  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
                                  const SizedBox(width: 8),
                                  Text(
                                    'STATUS: ${hasData ? profile!.status : "OFFLINE"}', 
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSimpleMetric(context, 'TOTAL KARMA', hasData ? _formatNumber(profile!.totalKarma) : '0'),
                            Container(width: 1, height: 40, color: AppTheme.outlineVariant.withAlpha(50), margin: const EdgeInsets.symmetric(horizontal: 24)),
                            _buildSimpleMetric(context, 'ACCOUNT AGE', hasData ? profile!.accountAge : 'Unknown'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 320,
                      child: GlassPanel(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        borderRadius: 16,
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search user keywords...',
                            hintStyle: TextStyle(fontSize: 12),
                            icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16, color: AppTheme.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 48),
                
                // Bento Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 900;
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: isMobile ? 1 : 8,
                              child: Column(
                                children: [
                                  // Stats Row
                                  Row(
                                    children: [
                                      Expanded(child: _buildBentoStat(context, 'TOTAL POSTS', hasData ? profile!.recentPosts.length.toString() : '0', AppTheme.primary)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildBentoStat(context, 'TOTAL COMMENTS', hasData ? profile!.recentComments.length.toString() : '0', AppTheme.secondary)),
                                      const SizedBox(width: 16),
                                      Expanded(child: _buildBentoStat(context, 'TOP SUBREDDIT', hasData && profile!.recentComments.isNotEmpty ? profile!.recentComments.first.subreddit : 'None', AppTheme.tertiary, subValue: true)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Activity Graph Card
                                  _buildActivityGraph(context),
                                ],
                              ),
                            ),
                            if (!isMobile) const SizedBox(width: 16),
                            if (!isMobile) Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  _buildIntelligenceSummary(context),
                                  const SizedBox(height: 16),
                                  _buildSectorEngagement(context),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isMobile) ...[
                          const SizedBox(height: 16),
                          _buildIntelligenceSummary(context),
                          const SizedBox(height: 16),
                          _buildSectorEngagement(context),
                        ],
                      ],
                    );
                  },
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 16),
                
                // Risk Profile
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer.withAlpha(20), 
                    borderRadius: BorderRadius.circular(24), 
                    border: Border.all(color: AppTheme.outlineVariant.withAlpha(30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.shieldHalved, color: AppTheme.tertiary),
                          const SizedBox(width: 16),
                          Text('RISK ASSESSMENT PROFILE', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: [
                          _buildRiskTag('TOXIC', hasData && profile!.toxicity > 0.5 ? 'MODERATE' : 'NONE', AppTheme.tertiary),
                          const SizedBox(width: 24),
                          _buildRiskTag('NSFW', hasData && profile!.nsfw > 0.5 ? 'DETECTED' : 'NONE', AppTheme.tertiary),
                          const SizedBox(width: 24),
                          _buildRiskTag('CONTROVERSIAL', hasData && profile!.controversialIndex > 0.3 ? 'MEDIUM' : 'LOW', AppTheme.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Content Timeline
                Text('CONTENT TIMELINE', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                if (hasData && profile!.recentPosts.isNotEmpty)
                  ...profile!.recentPosts.take(2).map((post) => _buildTimelinePost(context, post.subreddit, post.time, post.title, post.ups, post.numComments, AppTheme.primary)).toList()
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('NO RECENT CONTENT DETECTED', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, letterSpacing: 2))),
                  ),
              ],
            ),
          ),
          
          // FAB
          Positioned(
            bottom: 32,
            right: 32,
            child: FloatingActionButton.extended(
              onPressed: onReset,
              backgroundColor: AppTheme.primaryContainer,
              label: Text('SCAN AGAIN', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, color: AppTheme.onPrimaryContainer)),
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, color: AppTheme.onPrimaryContainer),
            ).animate().shimmer(duration: 2.seconds),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  Widget _buildNavAction(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.onSurfaceVariant)),
    );
  }

  Widget _buildSimpleMetric(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }

  Widget _buildBentoStat(BuildContext context, String label, String value, Color color, {bool subValue = false}) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: subValue ? 14 : 32), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildActivityGraph(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surfaceContainer.withAlpha(40), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activity Distribution', style: Theme.of(context).textTheme.titleLarge),
              Text('STOCHASTIC MAPPING', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              12,
              (index) => Container(
                width: 32,
                height: (20 + (index * 15) % 100).toDouble(),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [AppTheme.primaryContainer.withAlpha(50), AppTheme.primary]),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ).animate().scaleY(delay: (400 + index * 50).ms, begin: 0, end: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligenceSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryContainer.withOpacity(0.1), AppTheme.secondaryContainer.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.microchip, color: AppTheme.primary, size: 16),
              const SizedBox(width: 8),
              Text('INTELLIGENCE SUMMARY', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile != null && profile!.totalKarma > 10000 
              ? '"A high-level analytical contributor focused on systemic trends. Communication style is objective and information-dense."'
              : '"An emerging digital footprint with selective engagement patterns. Synthesis suggests a latent information-gathering persona."',
            style: const TextStyle(fontStyle: FontStyle.italic, height: 1.5),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSummaryTag(profile != null && profile!.totalKarma > 1000 ? 'HIGHLY TECHNICAL' : 'EMERGING PROFILE'),
              _buildSummaryTag('ANALYTIC TONE'),
              _buildSummaryTag(profile != null && profile!.nsfw > 0.5 ? 'WARNING: SENSITIVE' : 'STABLE SIGNALS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
    );
  }

  Widget _buildSectorEngagement(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surfaceContainer.withAlpha(40), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sector Mapping', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: 0.68, 
                    strokeWidth: 12, 
                    backgroundColor: AppTheme.secondary, 
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryContainer),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('CORE ENG', style: Theme.of(context).textTheme.labelSmall),
                    Text('68%', style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildEngagementRow(profile != null && profile!.recentComments.isNotEmpty ? profile!.recentComments.first.subreddit : 'Sector Alpha', '68%', AppTheme.primaryContainer),
          _buildEngagementRow('Sector Beta', '22%', AppTheme.secondary),
          _buildEngagementRow('Other Nodes', '10%', Colors.white),
        ],
      ),
    );
  }

  Widget _buildEngagementRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildRiskTag(String label, String value, Color color) {
    return Row(
      children: [
        Text('$label:', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(10), 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: color.withAlpha(50)),
          ),
          child: Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  Widget _buildTimelinePost(BuildContext context, String sub, String time, String title, int up, int comm, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surfaceContainer.withAlpha(40), borderRadius: BorderRadius.circular(24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: FaIcon(FontAwesomeIcons.newspaper, color: AppTheme.primary, size: 20)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sub.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
                    Text(time, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.thumbsUp, size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('$up', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(width: 24),
                    FaIcon(FontAwesomeIcons.commentDots, size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('$comm', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
