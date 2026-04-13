import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../models/reddit_models.dart';
import '../services/reddit_service.dart';
import '../services/report_service.dart';
import 'package:printing/printing.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onReset;
  final RedditProfile? profile;

  const DashboardPage({super.key, required this.onReset, this.profile});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late RedditProfile? _currentProfile;
  bool _isLoadingMore = false;
  final RedditService _service = RedditService.create();
  int _timelineTabIndex = 0;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
  }

  List<RedditPost> get _filteredPosts {
    if (_currentProfile == null) return [];
    if (_searchQuery.isEmpty) return _currentProfile!.recentPosts;
    return _currentProfile!.recentPosts.where((p) => 
      p.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      p.subreddit.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<RedditComment> get _filteredComments {
    if (_currentProfile == null) return [];
    if (_searchQuery.isEmpty) return _currentProfile!.recentComments;
    return _currentProfile!.recentComments.where((c) => 
      c.body.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      c.subreddit.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Map<String, double> _calculateSectors() {
    if (_currentProfile == null) return {};
    final subs = <String, int>{};
    for (var p in _currentProfile!.recentPosts) subs[p.subreddit] = (subs[p.subreddit] ?? 0) + 1;
    for (var c in _currentProfile!.recentComments) subs[c.subreddit] = (subs[c.subreddit] ?? 0) + 1;
    
    if (subs.isEmpty) return {};
    final total = subs.values.fold(0, (a, b) => a + b);
    final sorted = subs.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
    
    return { for (var e in sorted.take(3)) e.key : e.value / total };
  }

  List<double> _getActivityData() {
    if (_currentProfile == null) return List.filled(18, 0.0);
    final bars = List.filled(18, 0.0);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    for (var p in _currentProfile!.recentPosts) {
      final diff = (now - p.rawTimestamp).abs();
      final index = (diff ~/ (86400 * 2)).clamp(0, 17);
      bars[17 - index]++;
    }
    for (var c in _currentProfile!.recentComments) {
      final diff = (now - c.rawTimestamp).abs();
      final index = (diff ~/ (86400 * 2)).clamp(0, 17);
      bars[17 - index]++;
    }
    
    final max = bars.reduce((a, b) => a > b ? a : b);
    if (max == 0) return bars;
    return bars.map((v) => (30 + (v / max * 120)).toDouble()).toList();
  }

  Future<void> _loadMore() async {
    if (_currentProfile == null || _currentProfile!.afterToken == null || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final updatedProfile = await _service.fetchMoreActivity(_currentProfile!);
      setState(() {
        _currentProfile = updatedProfile;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportReport() async {
    if (_currentProfile == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating Summary Report...'),
        backgroundColor: AppTheme.primary,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final pdfBytes = await ReportService.generateReport(_currentProfile!);
      if (pdfBytes.isNotEmpty) {
        await Printing.sharePdf(
          bytes: pdfBytes,
          name: 'Report_${_currentProfile!.username}.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = _currentProfile != null;
    
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: AppTheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            leading: MediaQuery.of(context).size.width < 600
                ? IconButton(
                    icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 18, color: AppTheme.primary),
                    onPressed: () => widget.onReset(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          color: AppTheme.primaryContainer, 
                          border: Border.all(color: AppTheme.primary.withAlpha(50), width: 2),
                        ),
                        child: Center(child: FaIcon(FontAwesomeIcons.robot, size: 20, color: Colors.white)),
                      ),
                    ],
                  ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUBSONAR',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary, letterSpacing: 2),
                ),
                const Text('REDDIT INTELLIGENCE ENGINE', style: TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant, letterSpacing: 1.5)),
              ],
            ),
            actions: [
              if (MediaQuery.of(context).size.width < 600)
                IconButton(
                  icon: const Icon(Icons.file_download_outlined),
                  tooltip: 'Export Lead Report',
                  onPressed: _exportReport,
                )
              else ...[
                _buildNavAction('Home'),
                _buildNavAction('History'),
                _buildNavAction('Settings'),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _exportReport,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('GENERATE REPORT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              hasData ? 'u/${_currentProfile!.username}' : 'RETRIEVING DATA...', 
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: (hasData && _currentProfile!.status == 'HIDDEN') ? AppTheme.danger : AppTheme.primary,
                              ),
                            ).animate(
                              target: (hasData && _currentProfile!.status == 'HIDDEN') ? 1 : 0,
                            ).shimmer(duration: 1.seconds, color: Colors.white24).shake(hz: 4, rotation: 0.01),
                            const SizedBox(width: 16),
                            if (hasData && _currentProfile!.status == 'HIDDEN')
                              _buildAlertBadge('PRIVATE PROFILE', AppTheme.danger).animate().fadeIn().scale(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer.withAlpha(50), 
                            borderRadius: BorderRadius.circular(12), 
                            border: Border.all(color: AppTheme.outlineVariant.withAlpha(50)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10, 
                                height: 10, 
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle, 
                                  color: (hasData && _currentProfile!.status == 'HIDDEN') ? AppTheme.danger : AppTheme.success, 
                                  boxShadow: [(hasData && _currentProfile!.status == 'HIDDEN') 
                                    ? BoxShadow(color: AppTheme.danger.withAlpha(150), blurRadius: 12)
                                    : BoxShadow(color: AppTheme.success.withAlpha(100), blurRadius: 8)],
                                ),
                              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: (hasData && _currentProfile!.status == 'HIDDEN') ? 400.ms : 2.seconds),
                              const SizedBox(width: 12),
                              Text(
                                'VISIBILITY: ${hasData ? _currentProfile!.status : "ANALYZING..."}', 
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: (hasData && _currentProfile!.status == 'HIDDEN') ? AppTheme.danger : AppTheme.success,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Flexible(child: _buildSimpleMetric(context, 'TOTAL KARMA', hasData ? _formatNumber(_currentProfile!.totalKarma) : '0')),
                            Container(width: 1, height: 32, color: AppTheme.outlineVariant.withAlpha(50), margin: const EdgeInsets.symmetric(horizontal: 16)),
                            Flexible(child: _buildSimpleMetric(context, 'ACCOUNT AGE', hasData ? _currentProfile!.accountAge : 'Unknown')),
                          ],
                        ),
                      ],
                    ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        width: MediaQuery.of(context).size.width < 600 ? double.infinity : 320,
                        child: GlassPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          borderRadius: 16,
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: const InputDecoration(
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
                
                const SizedBox(height: 24),
                
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
                                  isMobile
                                    ? Column(
                                        children: [
                                          SizedBox(width: double.infinity, child: _buildBentoStat(context, 'POST COUNT', hasData ? _currentProfile!.recentPosts.length.toString() : '0', AppTheme.primary, icon: FontAwesomeIcons.fileLines)),
                                          const SizedBox(height: 16),
                                          SizedBox(width: double.infinity, child: _buildBentoStat(context, 'COMMENT COUNT', hasData ? _currentProfile!.recentComments.length.toString() : '0', AppTheme.secondary, icon: FontAwesomeIcons.message)),
                                          const SizedBox(height: 16),
                                          SizedBox(width: double.infinity, child: _buildBentoStat(context, 'PRIMARY SECTOR', hasData && _currentProfile!.recentComments.isNotEmpty ? _currentProfile!.recentComments.first.subreddit : 'None', AppTheme.tertiary, subValue: true, icon: FontAwesomeIcons.layerGroup)),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(child: _buildBentoStat(context, 'POST COUNT', hasData ? _currentProfile!.recentPosts.length.toString() : '0', AppTheme.primary, icon: FontAwesomeIcons.fileLines)),
                                          const SizedBox(width: 16),
                                          Expanded(child: _buildBentoStat(context, 'COMMENT COUNT', hasData ? _currentProfile!.recentComments.length.toString() : '0', AppTheme.secondary, icon: FontAwesomeIcons.message)),
                                          const SizedBox(width: 16),
                                          Expanded(child: _buildBentoStat(context, 'PRIMARY SECTOR', hasData && _currentProfile!.recentComments.isNotEmpty ? _currentProfile!.recentComments.first.subreddit : 'None', AppTheme.tertiary, subValue: true, icon: FontAwesomeIcons.layerGroup)),
                                        ],
                                      ),
                                    const SizedBox(height: 16),
                                    _buildActivityGraph(context, _getActivityData()),
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
                                  _buildSectorEngagement(context, _calculateSectors()),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isMobile) ...[
                          const SizedBox(height: 16),
                          _buildIntelligenceSummary(context),
                          const SizedBox(height: 16),
                          _buildSectorEngagement(context, _calculateSectors()),
                        ],
                      ],
                    );
                  },
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 16),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer.withAlpha(20), 
                    borderRadius: BorderRadius.circular(16), 
                    border: Border.all(color: AppTheme.outlineVariant.withAlpha(30)),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(FontAwesomeIcons.circleExclamation, color: AppTheme.tertiary, size: 16),
                          const SizedBox(width: 16),
                          Text('INTERACTION TONE SUMMARY', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14)),
                        ],
                      ),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          _buildRiskTag('TONE', hasData && _currentProfile!.toxicity > 0.5 ? 'INTENSE' : 'NEUTRAL', AppTheme.tertiary),
                          _buildRiskTag('SENSITIVE', hasData && _currentProfile!.nsfw > 0.5 ? 'DETECTED' : 'NONE', AppTheme.tertiary),
                          _buildRiskTag('DIVISIVE', hasData && _currentProfile!.controversialIndex > 0.3 ? 'MEDIUM' : 'LOW', AppTheme.secondary),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                Text('CONTENT TIMELINE', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                
                if (hasData)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _timelineTabIndex = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: _timelineTabIndex == 0 ? AppTheme.primary : AppTheme.outlineVariant, width: 2)),
                                ),
                                child: Center(child: Text('POSTS (${_filteredPosts.length})', style: TextStyle(color: _timelineTabIndex == 0 ? AppTheme.primary : AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold))),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _timelineTabIndex = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: _timelineTabIndex == 1 ? AppTheme.secondary : AppTheme.outlineVariant, width: 2)),
                                ),
                                child: Center(child: Text('COMMENTS (${_filteredComments.length})', style: TextStyle(color: _timelineTabIndex == 1 ? AppTheme.secondary : AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      if (_timelineTabIndex == 0)
                        ..._filteredPosts.map((post) => _buildTimelinePost(context, post, AppTheme.primary)),
                      if (_timelineTabIndex == 1)
                        ..._filteredComments.map((comment) => _buildTimelineComment(context, comment)),
                          
                      if (_timelineTabIndex == 0 && _filteredPosts.isEmpty)
                        const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: Text('NO SEARCH MATCHES FOUND', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, letterSpacing: 2)))),
                      if (_timelineTabIndex == 1 && _filteredComments.isEmpty)
                        const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: Text('NO SEARCH MATCHES FOUND', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, letterSpacing: 2)))),
                        
                      if (_currentProfile!.afterToken != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: OutlinedButton.icon(
                              onPressed: _isLoadingMore ? null : _loadMore,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                side: BorderSide(color: AppTheme.primary.withAlpha(50)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: _isLoadingMore 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const FaIcon(FontAwesomeIcons.plus, size: 14),
                              label: Text(_isLoadingMore ? 'ANALYZING...' : 'LOAD MORE DATA', style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: Text('SEARCHING...', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, letterSpacing: 2))),
                  ),
              ],
            ),
          ),
          
          Positioned(
            bottom: 32,
            right: 32,
            child: FloatingActionButton.extended(
              onPressed: widget.onReset,
              backgroundColor: AppTheme.primaryContainer,
              label: Text('NEW ANALYSIS', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, color: AppTheme.onPrimaryContainer)),
              icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, color: AppTheme.onPrimaryContainer),
            ).animate().shimmer(duration: 2.seconds),
          ),
        ],
      ),
    );
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

  Widget _buildBentoStat(BuildContext context, String label, String value, Color color, {bool subValue = false, required dynamic icon}) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
              FaIcon(icon as dynamic, size: 14, color: color.withAlpha(128)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value, 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: subValue ? 14 : 28,
              color: AppTheme.onSurface,
            ), 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis
          ),
          if (!subValue) ...[
            const SizedBox(height: 12),
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 4)],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityGraph(BuildContext context, List<double> data) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withAlpha(40), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity Intensity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('HISTORICAL DATA POINTS', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryContainer.withAlpha(76), borderRadius: BorderRadius.circular(8)),
                child: Text('LIVE', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 160,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double spacing = 6.0;
                final barCount = 18;
                final barWidth = (constraints.maxWidth - ((barCount - 1) * spacing)) / barCount;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    barCount,
                    (index) {
                      final h = data[index];
                      final isEven = index % 2 == 0;
                      return Container(
                        width: barWidth > 0 ? barWidth : 8,
                        height: h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter, 
                            end: Alignment.topCenter, 
                            colors: [
                              (isEven ? AppTheme.primaryContainer : AppTheme.secondaryContainer).withAlpha(80), 
                              (isEven ? AppTheme.primary : AppTheme.secondary),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: (isEven ? AppTheme.primary : AppTheme.secondary).withAlpha(40), 
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                      ).animate().scaleY(
                        delay: (200 + index * 40).ms, 
                        begin: 0, 
                        end: 1, 
                        curve: Curves.easeOutBack,
                        duration: 600.ms,
                      );
                    },
                  ),
                );
              }
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00 UTC', style: TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant.withAlpha(128))),
              Text('LAST 24H', style: TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant.withAlpha(128), fontWeight: FontWeight.bold)),
              Text('NOW', style: TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariant.withAlpha(128))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligenceSummary(BuildContext context) {
    final hasData = _currentProfile != null;
    final String summary = hasData && _currentProfile!.totalKarma > 10000 
      ? "RESEARCH SUMMARY: High-frequency platform contributor. Engagement patterns suggest selective participation in niche communities. Likely professional or technical demographic."
      : "RESEARCH SUMMARY: Emerging profile identified. Activity indicates focused interaction across key topic nodes. Interaction tone is currently stabilizing.";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryContainer.withAlpha(38), 
            AppTheme.surfaceContainer.withAlpha(12)
          ]
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withAlpha(38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.brain, color: AppTheme.primary, size: 16),
              const SizedBox(width: 12),
              Text('AI RESEARCH SUMMARY', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            summary,
            style: TextStyle(
              fontStyle: FontStyle.italic, 
              height: 1.6, 
              color: AppTheme.onSurface.withAlpha(230),
              fontSize: 13,
            ),
          ).animate().fadeIn(duration: 800.ms).shimmer(duration: 1.5.seconds, color: AppTheme.primary.withAlpha(50)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSummaryTag(hasData && _currentProfile!.totalKarma > 5000 ? 'SYSTEMIC' : 'SELECTIVE', AppTheme.primary),
              _buildSummaryTag('OBJECTIVE', AppTheme.secondary),
              if (hasData && _currentProfile!.status == 'HIDDEN')
                _buildSummaryTag('RESTRICTED', AppTheme.danger),
              if (hasData && _currentProfile!.nsfw > 0.3)
                _buildSummaryTag('SENSITIVE', AppTheme.archiveIntel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25), 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        label, 
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 1)
      ),
    );
  }

  Widget _buildSectorEngagement(BuildContext context, Map<String, double> sectors) {
    final hasData = _currentProfile != null;
    final topSub = hasData && _currentProfile!.recentComments.isNotEmpty ? _currentProfile!.recentComments.first.subreddit : 'N/A';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withAlpha(40), 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Core Ecosystem', style: Theme.of(context).textTheme.titleLarge),
              FaIcon(FontAwesomeIcons.diagramProject, size: 14, color: AppTheme.onSurfaceVariant.withAlpha(128)),
            ],
          ),
          const SizedBox(height: 16),
          if (sectors.isEmpty)
            _buildEngagementInterfacedRow('No Data', 0.0, AppTheme.onSurfaceVariant)
          else
            ...sectors.entries.map((e) => _buildEngagementInterfacedRow(e.key, e.value, AppTheme.primary)),
          const SizedBox(height: 16),
          Divider(color: AppTheme.outlineVariant.withAlpha(30)),
          const SizedBox(height: 8),
          Text(
            'DISTRIBUTION IDENTIFIED ACROSS 5 DATA ENGINES',
            style: TextStyle(fontSize: 8, color: AppTheme.onSurfaceVariant.withAlpha(100), letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementInterfacedRow(String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurface.withAlpha(178))),
              Text('${(percent * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(2)),
              ),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: color, 
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [BoxShadow(color: color.withAlpha(100), blurRadius: 4)],
                  ),
                ).animate().scaleX(begin: 0, end: 1, duration: 1.seconds, curve: Curves.easeOutExpo),
              ),
            ],
          ),
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
            color: color.withAlpha(25), 
            borderRadius: BorderRadius.circular(20), 
            border: Border.all(color: color.withAlpha(128)),
          ),
          child: Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  Widget _buildTimelinePost(BuildContext context, RedditPost post, Color color) {
    Color sourceColor = AppTheme.primary;
    if (post.source.contains('GHOST'))  sourceColor = AppTheme.ghostIntel;
    if (post.source.contains('ARCHIVE')) sourceColor = AppTheme.archiveIntel;
    
    final bool isNsfw = post.isNsfw;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withAlpha(isNsfw ? 20 : 40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNsfw ? AppTheme.danger.withAlpha(30) : color.withAlpha(52)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isNsfw ? AppTheme.danger : color).withAlpha(25), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (isNsfw ? AppTheme.danger : color).withAlpha(51)),
            ),
            child: Center(child: FaIcon(isNsfw ? FontAwesomeIcons.bolt : FontAwesomeIcons.paperclip, color: isNsfw ? AppTheme.danger : color, size: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(post.subreddit.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        _buildSourceBadge(post.source, sourceColor),
                      ],
                    ),
                    Text(post.time, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: isNsfw ? AppTheme.onSurface.withAlpha(204) : AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMiniStat(FontAwesomeIcons.solidHeart, '${post.ups}', AppTheme.onSurfaceVariant),
                    const SizedBox(width: 20),
                    _buildMiniStat(FontAwesomeIcons.solidComment, '${post.numComments}', AppTheme.onSurfaceVariant),
                    if (isNsfw) ...[
                      const Spacer(),
                      _buildAlertBadge('SENSITIVE CONTENT', AppTheme.danger),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0, duration: 400.ms);
  }

  Widget _buildTimelineComment(BuildContext context, RedditComment comment) {
    Color sourceColor = AppTheme.secondary;
    if (comment.source.contains('GHOST'))  sourceColor = AppTheme.ghostIntel;
    if (comment.source.contains('ARCHIVE')) sourceColor = AppTheme.archiveIntel;
    
    final bool isNsfw = comment.isNsfw;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withAlpha(isNsfw ? 20 : 10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNsfw ? AppTheme.danger.withAlpha(30) : AppTheme.secondary.withAlpha(38)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isNsfw ? AppTheme.danger : AppTheme.secondary).withAlpha(25), 
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (isNsfw ? AppTheme.danger : AppTheme.secondary).withAlpha(51)),
            ),
            child: Center(child: FaIcon(isNsfw ? FontAwesomeIcons.shieldHalved : FontAwesomeIcons.commentDots, color: isNsfw ? AppTheme.danger : AppTheme.secondary, size: 20)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(comment.subreddit.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        _buildSourceBadge(comment.source, sourceColor),
                      ],
                    ),
                    Text(comment.time, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                if (comment.linkTitle != null && comment.linkTitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'RE: ${comment.linkTitle}',
                    style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant.withAlpha(178), fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  comment.body, 
                  style: TextStyle(
                    fontSize: 14, 
                    height: 1.6, 
                    color: isNsfw ? AppTheme.onSurface.withAlpha(153) : AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMiniStat(FontAwesomeIcons.solidHeart, '${comment.ups}', AppTheme.onSurfaceVariant),
                    if (comment.isControversial) ...[
                      const SizedBox(width: 20),
                      _buildAlertBadge('CONTROVERSIAL', AppTheme.archiveIntel),
                    ],
                    if (isNsfw) ...[
                      const Spacer(),
                      _buildAlertBadge('SENSITIVE CONTENT', AppTheme.danger),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0, duration: 400.ms);
  }

  Widget _buildSourceBadge(String source, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Text(
        source, 
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildMiniStat(dynamic icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon as dynamic, size: 10, color: color.withAlpha(178)),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildAlertBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.5.seconds),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 1)),
        ],
      ),
    );
  }
}
