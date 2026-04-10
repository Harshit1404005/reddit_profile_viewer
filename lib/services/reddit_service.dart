import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/reddit_models.dart';
import 'cache_service.dart';

enum DataSource {
  pullpush,
  redditPublic,
  redditOAuth,
}

/// Abstract base for Reddit intelligence gathering.
abstract class RedditService {
  RedditService();

  Future<RedditProfile> analyzeUser(String username);
  Future<RedditProfile> fetchMoreActivity(RedditProfile currentProfile);
  String get mode;

  // ─── Global Toggle ───────────────────────────────────────────────────────────
  // Change this one line to switch the data source everywhere in the app.
  static DataSource currentDataSource = DataSource.pullpush;

  // Convenience functions — call from anywhere before creating the service.
  static void usePullPush()     => currentDataSource = DataSource.pullpush;
  static void useRedditPublic() => currentDataSource = DataSource.redditPublic;
  static void useOAuth()        => currentDataSource = DataSource.redditOAuth;

  /// Factory: returns the correct implementation based on [currentDataSource].
  factory RedditService.create() {
    switch (currentDataSource) {
      case DataSource.pullpush:
        return PullPushRedditService();
      case DataSource.redditPublic:
        return RedditPublicService();
      case DataSource.redditOAuth:
        return OAuthRedditService();
    }
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────────

  /// Parses Reddit's official "listing" JSON (overview / submitted / comments).
  Map<String, dynamic> parseListing(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final children = data['children'] as List? ?? [];
    final posts    = <RedditPost>[];
    final comments = <RedditComment>[];

    for (final child in children) {
      final kind = child['kind'];
      if (kind == 't3') {
        posts.add(RedditPost.fromRedditJson(child, source: 'REDDIT-API'));
      } else if (kind == 't1') {
        comments.add(RedditComment.fromRedditJson(child, source: 'REDDIT-API'));
      }
    }

    return {
      'posts':    posts,
      'comments': comments,
      'after':    data['after'],
    };
  }

  /// Fetches global community pulse (trends).
  Future<Map<String, dynamic>> getGlobalPulse();

  /// Shared intelligence scoring.
  RedditProfile calculateIntelligence(
    RedditProfile profile,
    List<RedditPost> posts,
    List<RedditComment> comments, {
    String? afterToken,
  }) {
    double toxic = 0.0;
    double controversial = 0.0;

    for (final comment in comments) {
      if (comment.isControversial) controversial += 0.2;
      if (comment.body.contains(
          RegExp(r'hate|stupid|awful|terrible|idiot|garbage', caseSensitive: false))) {
        toxic += 0.15;
      }
    }

    return profile.copyWith(
      toxicity:           toxic.clamp(0.0, 1.0),
      controversialIndex: controversial.clamp(0.0, 1.0),
      recentPosts:        posts,
      recentComments:     comments,
      afterToken:         afterToken,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION A — Parallel Public + Archive (maximum hidden profile coverage)
// Fires BOTH reddit.com JSON endpoints AND api.pullpush.io simultaneously,
// then merges+deduplicates by ID — same strategy as RedditGhost.
// ═══════════════════════════════════════════════════════════════════════════════
class PullPushRedditService extends RedditService {
  // ── RedditGhost proxy (PRIMARY) ──────────────────────────────────────────────
  // redditghost.pages.dev/api/reddit/ is a Cloudflare Pages serverless proxy
  // that aggregates Reddit's search API + archive on the server side.
  // It returns full post/comment data even for hidden profiles.
  // changed it to my own cloudflare pages serverless 
  final Dio _ghost = Dio(BaseOptions(
    baseUrl: 'https://my-reddit-intelligence.hg140400.workers.dev/',
    connectTimeout: const Duration(seconds: 25),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      'Accept':     'application/json',
      'Referer':    'https://my-reddit-intelligence.hg140400.workers.dev/',
    },
  ));

  // ── Reddit.com (SECONDARY) ───────────────────────────────────────────────────
  final Dio _reddit = Dio(BaseOptions(
    baseUrl: 'https://www.reddit.com',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 25),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      'Accept':     'application/json',
      'Cookie':     'over18=1; reddit_session=; loid=',
    },
  ));

  // ── Old Reddit (TERTIARY) ────────────────────────────────────────────────────
  final Dio _old = Dio(BaseOptions(
    baseUrl: 'https://old.reddit.com',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 25),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      'Accept':     'application/json',
      'Cookie':     'over18=1',
    },
  ));

  // ── PullPush (ARCHIVE FALLBACK) ──────────────────────────────────────────────
  final Dio _pullPush = Dio(BaseOptions(
    baseUrl: 'https://api.pullpush.io',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 25),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      'Accept':     'application/json',
    },
  ));

  @override
  String get mode => 'DEEP_INTEL (PUBLIC + ARCHIVE)';

  @override
  Future<Map<String, dynamic>> getGlobalPulse() async {
    try {
      // Hit the Cloudflare worker to aggregate trending signals (Strategic Hit)
      final response = await _ghost.get('/api/reddit/all/hot?limit=50').catchError((_) => _reddit.get('/r/all/hot.json?limit=50'));
      final data = response.data;
      final List children = (data is Map) ? (data['data']?['children'] ?? []) : [];
      
      final subreddits = <String, int>{};
      final keywords = <String, int>{};
      
      for (final child in children) {
        final d = child['data'] ?? {};
        final sub = d['subreddit'] ?? 'unknown';
        subreddits[sub] = (subreddits[sub] ?? 0) + 1;
        
        final title = (d['title'] ?? '').toString().toUpperCase();
        final words = title.split(RegExp(r'\W+'));
        for (final w in words) {
          if (w.length > 5) keywords[w] = (keywords[w] ?? 0) + 1;
        }
      }

      final topSubs = subreddits.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
      final topWords = keywords.entries.toList()..sort((a,b) => b.value.compareTo(a.value));

      return {
        'subreddits': topSubs.take(5).map((e) => e.key).toList(),
        'keywords': topWords.take(10).map((e) => e.key).toList(),
        'sentiment': 'ANALYZING',
        'active_count': '1.4M+',
      };
    } catch (e) {
      debugPrint('[RedIntel] Pulse Error: $e');
      return {
        'subreddits': ['TECH', 'AI', 'NEWS'],
        'keywords': ['LLM', 'DART', 'FLUTTER'],
        'sentiment': 'STABLE',
        'active_count': '1.2M',
      };
    }
  }

  @override
  Future<RedditProfile> analyzeUser(String username) async {
    final sw = Stopwatch()..start();

    // 0 ── Check Cache
    if (_cache.containsKey(username)) {
      debugPrint('[RedIntel] Cache Hit: Returning stored data for $username');
      return _cache[username]!;
    }
    // 1 ── Profile info (best-effort — hidden profiles return 404 here)
    RedditProfile profile;
    try {
      final res = await _reddit.get('/user/$username/about.json');
      profile = RedditProfile.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      // Profile is hidden/suspended — continue anyway with archive data
      profile = RedditProfile(
        username:           username,
        totalKarma:         0,
        accountAge:         'Unknown',
        status:             'HIDDEN',
        toxicity:           0.0,
        nsfw:               0.0,
        controversialIndex: 0.0,
        recentPosts:        [],
        recentComments:     [],
      );
    }

    // 2 ── Adaptive Intercept Strategy ──────────────────────────────────────────
    // Determine which "Interceptors" to fire based on visibility.
    final bool isDeepNeeded = profile.status == 'HIDDEN';
    _FetchResult ghostResult   = _FetchResult.empty();
    _FetchResult publicResult  = _FetchResult.empty();
    _FetchResult overviewResult = _FetchResult.empty();
    _FetchResult oldResult     = _FetchResult.empty();
    _FetchResult archiveResult  = _FetchResult.empty();

    if (!isDeepNeeded) {
      debugPrint('[RedIntel] Status VISIBLE: Using Light-Mode Interceptors...');
      final results = await Future.wait([
        _fetchFromRedditPublic(username).catchError((_) => _FetchResult.empty()),
        _fetchFromRedditOverview(username).catchError((_) => _FetchResult.empty()),
        _fetchFromPullPush(username).catchError((_) => _FetchResult.empty()),
      ]);
      publicResult   = results[0];
      overviewResult = results[1];
      archiveResult  = results[2];

      // FALLBACK: If standard signals return 0, trigger Deep Scan (Proxy + Old Reddit)
      if (publicResult.posts.isEmpty && publicResult.comments.isEmpty) {
        debugPrint('[RedIntel] VISIBLE signals empty (Shadowban?): Triggering DEEP_SCAN fallback...');
        final deepResults = await Future.wait([
          _fetchFromGhostProxy(username).catchError((_) => _FetchResult.empty()),
          _fetchFromOldReddit(username).catchError((_) => _FetchResult.empty()),
        ]);
        ghostResult = deepResults[0];
        oldResult   = deepResults[1];
      }
    } else {
      debugPrint('[RedIntel] Status HIDDEN: Triggering FULL_DEEP_INTEL suite...');
      final results = await Future.wait([
        _fetchFromGhostProxy(username).catchError((_) => _FetchResult.empty()),
        _fetchFromRedditPublic(username).catchError((_) => _FetchResult.empty()),
        _fetchFromRedditOverview(username).catchError((_) => _FetchResult.empty()),
        _fetchFromOldReddit(username).catchError((_) => _FetchResult.empty()),
        _fetchFromPullPush(username).catchError((_) => _FetchResult.empty()),
      ]);
      ghostResult    = results[0];
      publicResult   = results[1];
      overviewResult = results[2];
      oldResult      = results[3];
      archiveResult  = results[4];
    }

    final resultsList = [ghostResult, publicResult, overviewResult, oldResult, archiveResult];
    
    List<RedditPost>    mergedPosts    = [];
    List<RedditComment> mergedComments = [];
    
    for (final r in resultsList) {
      mergedPosts    = _mergePosts(mergedPosts, r.posts);
      mergedComments = _mergeComments(mergedComments, r.comments);
    }

    // Token priority logic: official API tokens (string format) are preferred over 
    // archive tokens (timestamp format) for standard real-time pagination consistency.
    String? redditToken = publicResult.afterToken ?? overviewResult.afterToken ?? oldResult.afterToken;
    String? afterToken = redditToken ?? ghostResult.afterToken ?? archiveResult.afterToken;

    final finalProfile = calculateIntelligence(profile, mergedPosts, mergedComments,
        afterToken: afterToken);

    sw.stop();
    _cache[username] = finalProfile; // Save to session cache
    CacheService.saveProfile(finalProfile, duration: sw.elapsed); // Persist to intelligence HUD
    debugPrint('[RedIntel] Intelligence Intercept Complete (${sw.elapsed.inMilliseconds}ms): ${mergedPosts.length}p | ${mergedComments.length}c');

    return finalProfile;
  }

  // Session-based memory cache map
  final Map<String, RedditProfile> _cache = {};

  // ── Source fetchers ──────────────────────────────────────────────────────────

  // Source 0: RedditGhost Cloudflare proxy — aggregates Reddit search + archive
  // Returns flat {data:[...]} with PullPush-style objects (no kind/data wrapper)
  Future<_FetchResult> _fetchFromGhostProxy(String username) async {
    final enc = Uri.encodeComponent(username);
    final responses = await Future.wait([
      _ghost.get('/api/reddit/posts/search?author=$enc&limit=100'),
      _ghost.get('/api/reddit/comments/search?author=$enc&limit=100'),
    ]);
    final postsData    = (responses[0].data['data'] as List?) ?? [];
    final commentsData = (responses[1].data['data'] as List?) ?? [];

    // Ghost proxy returns PullPush-style flat objects
    final posts    = postsData.map((p) => RedditPost.fromPullPushJson(p as Map<String, dynamic>, source: 'GHOST-INTEL')).toList();
    final comments = commentsData.map((c) => RedditComment.fromPullPushJson(c as Map<String, dynamic>, source: 'GHOST-INTEL')).toList();

    String? nextToken;
    if (postsData.isNotEmpty) {
      nextToken = postsData.last['created_utc']?.toString();
    } else if (commentsData.isNotEmpty) {
      nextToken = commentsData.last['created_utc']?.toString();
    }

    return _FetchResult(posts: posts, comments: comments, afterToken: nextToken);
  }

  // Source A: submitted.json + comments.json (with NSFW + over18 cookie)
  Future<_FetchResult> _fetchFromRedditPublic(String username) async {
    final q = 'limit=100&sort=new&raw_json=1&include_over_18=1';
    final responses = await Future.wait([
      _reddit.get('/user/$username/submitted.json?$q'),
      _reddit.get('/user/$username/comments.json?$q'),
    ]);
    final postData = responses[0].data as Map<String, dynamic>;
    final comData  = responses[1].data as Map<String, dynamic>;

    final posts    = ((postData['data']?['children'] as List?) ?? [])
        .map((c) => RedditPost.fromRedditJson(c as Map<String, dynamic>, source: 'PUBLIC-API')).toList();
    final comments = ((comData['data']?['children'] as List?) ?? [])
        .map((c) => RedditComment.fromRedditJson(c as Map<String, dynamic>, source: 'PUBLIC-API')).toList();
    final after    = comData['data']?['after'] as String?
        ?? postData['data']?['after'] as String?;

    return _FetchResult(posts: posts, comments: comments, afterToken: after);
  }

  // Source B: overview.json — mixed posts+comments listing, sometimes returns
  // extra items that submitted/comments misses for hidden profiles
  Future<_FetchResult> _fetchFromRedditOverview(String username) async {
    final res = await _reddit.get(
        '/user/$username/overview.json?limit=100&sort=new&raw_json=1&include_over_18=1');
    final data   = res.data as Map<String, dynamic>;
    final children = (data['data']?['children'] as List?) ?? [];
    final posts    = <RedditPost>[];
    final comments = <RedditComment>[];
    for (final child in children) {
      final kind = (child as Map<String, dynamic>)['kind'];
      if (kind == 't3') {
        posts.add(RedditPost.fromRedditJson(child, source: 'DIRECT-JSON'));
      } else if (kind == 't1') {
        comments.add(RedditComment.fromRedditJson(child, source: 'DIRECT-JSON'));
      }
    }
    final after = data['data']?['after'] as String?;
    return _FetchResult(posts: posts, comments: comments, afterToken: after);
  }

  // Source C: old.reddit.com — separate CDN/path, sometimes bypasses
  // restrictions that www.reddit.com enforces for hidden profiles
  Future<_FetchResult> _fetchFromOldReddit(String username) async {
    final res = await _old.get(
        '/user/$username/overview.json?limit=100&sort=new&raw_json=1&include_over_18=1');
    final data     = res.data as Map<String, dynamic>;
    final children = (data['data']?['children'] as List?) ?? [];
    final posts    = <RedditPost>[];
    final comments = <RedditComment>[];
    for (final child in children) {
      final kind = (child as Map<String, dynamic>)['kind'];
      if (kind == 't3') {
        posts.add(RedditPost.fromRedditJson(child, source: 'OLD-REDDIT'));
      } else if (kind == 't1') {
        comments.add(RedditComment.fromRedditJson(child, source: 'OLD-REDDIT'));
      }
    }
    final after = data['data']?['after'] as String?;
    return _FetchResult(posts: posts, comments: comments, afterToken: after);
  }

  Future<_FetchResult> _fetchFromPullPush(String username) async {
    final responses = await Future.wait([
      _pullPush.get(
          '/reddit/search/submission/?author=$username&size=100&sort=desc&sort_type=created_utc'),
      _pullPush.get(
          '/reddit/search/comment/?author=$username&size=100&sort=desc&sort_type=created_utc'),
    ]);
    final postsData    = (responses[0].data['data'] as List?) ?? [];
    final commentsData = (responses[1].data['data'] as List?) ?? [];

    final posts    = postsData.map((p) => RedditPost.fromPullPushJson(p as Map<String, dynamic>, source: 'ARCHIVE')).toList();
    final comments = commentsData.map((c) => RedditComment.fromPullPushJson(c as Map<String, dynamic>, source: 'ARCHIVE')).toList();

    String? nextToken;
    if (postsData.isNotEmpty) {
      nextToken = postsData.last['created_utc']?.toString();
    } else if (commentsData.isNotEmpty) {
      nextToken = commentsData.last['created_utc']?.toString();
    }

    return _FetchResult(posts: posts, comments: comments, afterToken: nextToken);
  }

  // ── Merge helpers (deduplicate by ID, sort newest first) ─────────────────────

  List<RedditPost> _mergePosts(List<RedditPost> a, List<RedditPost> b) {
    final map = <String, RedditPost>{};
    for (final p in [...a, ...b]) {
      if (p.id.isNotEmpty) map[p.id] = p;
    }
    final list = map.values.toList()
      ..sort((x, y) => y.rawTimestamp.compareTo(x.rawTimestamp));
    return list;
  }

  List<RedditComment> _mergeComments(List<RedditComment> a, List<RedditComment> b) {
    final map = <String, RedditComment>{};
    for (final c in [...a, ...b]) {
      if (c.id.isNotEmpty) map[c.id] = c;
    }
    final list = map.values.toList()
      ..sort((x, y) => y.rawTimestamp.compareTo(x.rawTimestamp));
    return list;
  }

  @override
  Future<RedditProfile> fetchMoreActivity(RedditProfile currentProfile) async {
    if (currentProfile.afterToken == null) return currentProfile;

    final username = currentProfile.username;
    final token    = currentProfile.afterToken!;
    // All-digit token = PullPush unix timestamp; otherwise = Reddit t-prefixed token
    final isPullPushToken = RegExp(r'^\d+$').hasMatch(token);

    _FetchResult newResult;

    if (!isPullPushToken) {
      // Reddit pagination
      newResult = await _fetchFromRedditPublicPaged(username, token)
          .catchError((_) => _FetchResult.empty());
      // Supplement with PullPush if Reddit returned nothing
      if (newResult.posts.isEmpty && newResult.comments.isEmpty) {
        newResult = await _fetchFromPullPush(username).catchError((_) => _FetchResult.empty());
      }
    } else {
      // PullPush timestamp pagination
      newResult = await _fetchFromPullPushBefore(username, token)
          .catchError((_) => _FetchResult.empty());
    }

    final mergedPosts    = _mergePosts(
        List<RedditPost>.from(currentProfile.recentPosts), newResult.posts);
    final mergedComments = _mergeComments(
        List<RedditComment>.from(currentProfile.recentComments), newResult.comments);

    return calculateIntelligence(currentProfile, mergedPosts, mergedComments,
        afterToken: newResult.afterToken);
  }

  Future<_FetchResult> _fetchFromRedditPublicPaged(String username, String after) async {
    final responses = await Future.wait([
      _reddit.get('/user/$username/submitted.json?limit=100&sort=new&raw_json=1&after=$after'),
      _reddit.get('/user/$username/comments.json?limit=100&sort=new&raw_json=1&after=$after'),
    ]);
    final postData = responses[0].data as Map<String, dynamic>;
    final comData  = responses[1].data as Map<String, dynamic>;

    final posts    = ((postData['data']?['children'] as List?) ?? [])
        .map((c) => RedditPost.fromRedditJson(c as Map<String, dynamic>, source: 'PUBLIC-PAGED')).toList();
    final comments = ((comData['data']?['children'] as List?) ?? [])
        .map((c) => RedditComment.fromRedditJson(c as Map<String, dynamic>, source: 'PUBLIC-PAGED')).toList();
    final nextToken = comData['data']?['after'] as String?
        ?? postData['data']?['after'] as String?;

    return _FetchResult(posts: posts, comments: comments, afterToken: nextToken);
  }

  Future<_FetchResult> _fetchFromPullPushBefore(String username, String before) async {
    final responses = await Future.wait([
      _pullPush.get(
          '/reddit/search/submission/?author=$username&size=100&sort=desc&sort_type=created_utc&before=$before'),
      _pullPush.get(
          '/reddit/search/comment/?author=$username&size=100&sort=desc&sort_type=created_utc&before=$before'),
    ]);
    final postsData    = (responses[0].data['data'] as List?) ?? [];
    final commentsData = (responses[1].data['data'] as List?) ?? [];

    final posts    = postsData.map((p) => RedditPost.fromPullPushJson(p as Map<String, dynamic>, source: 'ARCHIVE-PAGED')).toList();
    final comments = commentsData.map((c) => RedditComment.fromPullPushJson(c as Map<String, dynamic>, source: 'ARCHIVE-PAGED')).toList();

    String? nextToken;
    if (postsData.isNotEmpty) {
      nextToken = postsData.last['created_utc']?.toString();
    } else if (commentsData.isNotEmpty) {
      nextToken = commentsData.last['created_utc']?.toString();
    }

    return _FetchResult(posts: posts, comments: comments, afterToken: nextToken);
  }
}

/// Internal DTO for parallel fetch results.
class _FetchResult {
  final List<RedditPost>    posts;
  final List<RedditComment> comments;
  final String?             afterToken;

  const _FetchResult({
    required this.posts,
    required this.comments,
    required this.afterToken,
  });

  factory _FetchResult.empty() =>
      const _FetchResult(posts: [], comments: [], afterToken: null);
}

// ═══════════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION B — Pure Reddit Public API (no auth / no fallback)
// ═══════════════════════════════════════════════════════════════════════════════
class RedditPublicService extends RedditService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://www.reddit.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'User-Agent': 'RedIntelApp/1.0 (by /u/Harshit1404005)',
      'Accept':     'application/json',
    },
  ));

  @override
  String get mode => 'PUBLIC (REDDIT API)';

  @override
  Future<Map<String, dynamic>> getGlobalPulse() async => {
    'subreddits': ['ALL', 'HOT', 'TRENDING'],
    'keywords': ['REDDIT', 'PUBLIC', 'API'],
    'sentiment': 'STABLE',
    'active_count': '1.0M',
  };

  @override
  Future<RedditProfile> analyzeUser(String username) async {
    RedditProfile profile;
    try {
      final res = await _dio.get('/user/$username/about.json');
      profile = RedditProfile.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      profile = RedditProfile(
        username:           username,
        totalKarma:         0,
        accountAge:         'Unknown',
        status:             'ERROR',
        toxicity:           0.0,
        nsfw:               0.0,
        controversialIndex: 0.0,
        recentPosts:        [],
        recentComments:     [],
      );
    }

    final postRes = await _dio.get('/user/$username/submitted.json?limit=100&sort=new&raw_json=1');
    final comRes  = await _dio.get('/user/$username/comments.json?limit=100&sort=new&raw_json=1');

    final postData = postRes.data as Map<String, dynamic>;
    final comData  = comRes.data  as Map<String, dynamic>;

    final postChildren = (postData['data']?['children'] as List?) ?? [];
    final comChildren  = (comData ['data']?['children'] as List?) ?? [];

    final posts    = postChildren.map((c) => RedditPost.fromRedditJson(c)).toList();
    final comments = comChildren .map((c) => RedditComment.fromRedditJson(c)).toList();

    final after = comData['data']?['after'] as String?
        ?? postData['data']?['after'] as String?;

    return calculateIntelligence(profile, posts, comments, afterToken: after);
  }

  @override
  Future<RedditProfile> fetchMoreActivity(RedditProfile currentProfile) async {
    if (currentProfile.afterToken == null) return currentProfile;

    final token    = currentProfile.afterToken!;
    final username = currentProfile.username;

    final postRes = await _dio.get(
        '/user/$username/submitted.json?limit=100&sort=new&raw_json=1&after=$token');
    final comRes  = await _dio.get(
        '/user/$username/comments.json?limit=100&sort=new&raw_json=1&after=$token');

    final postData = postRes.data as Map<String, dynamic>;
    final comData  = comRes.data  as Map<String, dynamic>;

    final newPosts    = ((postData['data']?['children'] as List?) ?? [])
        .map((c) => RedditPost.fromRedditJson(c)).toList();
    final newComments = ((comData ['data']?['children'] as List?) ?? [])
        .map((c) => RedditComment.fromRedditJson(c)).toList();

    final combinedPosts    = List<RedditPost>.from(currentProfile.recentPosts)   ..addAll(newPosts);
    final combinedComments = List<RedditComment>.from(currentProfile.recentComments)..addAll(newComments);

    final after = comData['data']?['after'] as String?
        ?? postData['data']?['after'] as String?;

    return calculateIntelligence(currentProfile, combinedPosts, combinedComments, afterToken: after);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// IMPLEMENTATION C — OAuth (authenticated, higher rate limits)
// ═══════════════════════════════════════════════════════════════════════════════
class OAuthRedditService extends RedditService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://oauth.reddit.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'User-Agent': 'RedIntelApp/1.0 (by /u/Harshit1404005)',
    },
  ));

  String? _accessToken;

  @override
  String get mode => 'OAUTH_SECURE';

  @override
  Future<Map<String, dynamic>> getGlobalPulse() async => {
    'subreddits': ['PRIVATE', 'SECURE', 'PULSE'],
    'keywords': ['OAUTH', 'TOKEN', 'VERIFIED'],
    'sentiment': 'SECURE',
    'active_count': '500K+',
  };

  @override
  Future<RedditProfile> analyzeUser(String username) async {
    await _authenticate();
    _dio.options.headers['Authorization'] = 'Bearer $_accessToken';

    final profileResponse = await _dio.get('/user/$username/about');
    final profile = RedditProfile.fromJson(profileResponse.data as Map<String, dynamic>);

    final postRes = await _dio.get('/user/$username/submitted?limit=100&sort=new&raw_json=1');
    final comRes  = await _dio.get('/user/$username/comments?limit=100&sort=new&raw_json=1');

    final postData = postRes.data as Map<String, dynamic>;
    final comData  = comRes.data  as Map<String, dynamic>;

    final posts    = ((postData['data']?['children'] as List?) ?? [])
        .map((c) => RedditPost.fromRedditJson(c)).toList();
    final comments = ((comData ['data']?['children'] as List?) ?? [])
        .map((c) => RedditComment.fromRedditJson(c)).toList();

    final after = comData['data']?['after'] as String?
        ?? postData['data']?['after'] as String?;

    return calculateIntelligence(profile, posts, comments, afterToken: after);
  }

  @override
  Future<RedditProfile> fetchMoreActivity(RedditProfile currentProfile) async {
    if (currentProfile.afterToken == null) return currentProfile;

    await _authenticate();
    _dio.options.headers['Authorization'] = 'Bearer $_accessToken';

    final token    = currentProfile.afterToken!;
    final username = currentProfile.username;

    final postRes = await _dio.get('/user/$username/submitted?limit=100&sort=new&raw_json=1&after=$token');
    final comRes  = await _dio.get('/user/$username/comments?limit=100&sort=new&raw_json=1&after=$token');

    final postData = postRes.data as Map<String, dynamic>;
    final comData  = comRes.data  as Map<String, dynamic>;

    final newPosts    = ((postData['data']?['children'] as List?) ?? [])
        .map((c) => RedditPost.fromRedditJson(c)).toList();
    final newComments = ((comData ['data']?['children'] as List?) ?? [])
        .map((c) => RedditComment.fromRedditJson(c)).toList();

    final combinedPosts    = List<RedditPost>.from(currentProfile.recentPosts)   ..addAll(newPosts);
    final combinedComments = List<RedditComment>.from(currentProfile.recentComments)..addAll(newComments);

    final after = comData['data']?['after'] as String?
        ?? postData['data']?['after'] as String?;

    return calculateIntelligence(currentProfile, combinedPosts, combinedComments, afterToken: after);
  }

  Future<void> _authenticate() async {
    if (_accessToken != null) return;
    final clientId     = dotenv.env['REDDIT_CLIENT_ID'];
    final clientSecret = dotenv.env['REDDIT_CLIENT_SECRET'];
    final authString   = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await Dio().post(
      'https://www.reddit.com/api/v1/access_token',
      data: {'grant_type': 'client_credentials'},
      options: Options(
        headers: {'Authorization': 'Basic $authString'},
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    _accessToken = response.data['access_token'] as String?;
  }
}
