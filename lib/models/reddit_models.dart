import 'package:hive/hive.dart';

part 'reddit_models.g.dart';

@HiveType(typeId: 0)
class RedditProfile {
  @HiveField(0)
  final String username;
  @HiveField(1)
  final int totalKarma;
  @HiveField(2)
  final String accountAge;
  @HiveField(3)
  final String status;
  @HiveField(4)
  final double toxicity;
  @HiveField(5)
  final double nsfw;
  @HiveField(6)
  final double controversialIndex;
  @HiveField(7)
  final List<RedditPost> recentPosts;
  @HiveField(8)
  final List<RedditComment> recentComments;
  @HiveField(9)
  final String? afterToken;

  RedditProfile({
    required this.username,
    required this.totalKarma,
    required this.accountAge,
    required this.status,
    required this.toxicity,
    required this.nsfw,
    required this.controversialIndex,
    required this.recentPosts,
    required this.recentComments,
    this.afterToken,
  });

  factory RedditProfile.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    return RedditProfile(
      username:           data['name']?.toString() ?? 'Unknown',
      totalKarma:         (data['total_karma'] as num?)?.toInt() ?? 0,
      accountAge:         _calculateAge(data['created_utc'] as num?),
      status:             (data['hide_from_robots'] == true) ? 'HIDDEN' : 'VISIBLE',
      toxicity:           0.0,
      nsfw:               (data['over_18'] == true) ? 1.0 : 0.0,
      controversialIndex: 0.0,
      recentPosts:        [],
      recentComments:     [],
    );
  }

  static String _calculateAge(num? createdUtc) {
    if (createdUtc == null) return 'Unknown';
    final created = DateTime.fromMillisecondsSinceEpoch(createdUtc.toInt() * 1000);
    final diff    = DateTime.now().difference(created);
    final years   = (diff.inDays / 365).floor();
    final months  = ((diff.inDays % 365) / 30).floor();
    return '${years}Y ${months}M';
  }

  RedditProfile copyWith({
    double? toxicity,
    double? controversialIndex,
    List<RedditPost>? recentPosts,
    List<RedditComment>? recentComments,
    String? afterToken,
    bool clearAfterToken = false,
  }) {
    return RedditProfile(
      username:           username,
      totalKarma:         totalKarma,
      accountAge:         accountAge,
      status:             status,
      toxicity:           toxicity           ?? this.toxicity,
      nsfw:               nsfw,
      controversialIndex: controversialIndex ?? this.controversialIndex,
      recentPosts:        recentPosts        ?? this.recentPosts,
      recentComments:     recentComments     ?? this.recentComments,
      afterToken:         clearAfterToken ? null : (afterToken ?? this.afterToken),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

@HiveType(typeId: 1)
class RedditPost {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String subreddit;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String? url;
  @HiveField(4)
  final String? permalink;
  @HiveField(5)
  final int ups;
  @HiveField(6)
  final int numComments;
  @HiveField(7)
  final String time;
  @HiveField(8)
  final int rawTimestamp;
  @HiveField(9)
  final bool isNsfw;
  @HiveField(10)
  final String source;

  RedditPost({
    required this.id,
    required this.subreddit,
    required this.title,
    this.url,
    this.permalink,
    required this.ups,
    required this.numComments,
    required this.time,
    required this.rawTimestamp,
    this.isNsfw = false,
    this.source = 'UNKNOWN',
  });

  /// From Reddit's own API — child object has kind + data wrapper.
  factory RedditPost.fromRedditJson(Map<String, dynamic> child, {String source = 'PUBLIC'}) {
    final d = (child['data'] ?? child) as Map<String, dynamic>;
    final ts = (d['created_utc'] as num?)?.toInt() ?? 0;
    return RedditPost(
      id:           d['id']?.toString() ?? '',
      subreddit:    'r/${d['subreddit'] ?? ''}',
      title:        d['title']?.toString() ?? 'No Title',
      url:          d['url']?.toString(),
      permalink:    d['permalink']?.toString(),
      ups:          (d['ups']   as num?)?.toInt() ?? (d['score'] as num?)?.toInt() ?? 0,
      numComments:  (d['num_comments'] as num?)?.toInt() ?? 0,
      time:         _formatTime(d['created_utc'] as num?),
      rawTimestamp: ts,
      isNsfw:       d['over_18'] == true,
      source:       source,
    );
  }

  /// From PullPush — objects are flat (no kind/data wrapper).
  factory RedditPost.fromPullPushJson(Map<String, dynamic> d, {String source = 'ARCHIVE'}) {
    final ts = (d['created_utc'] as num?)?.toInt() ?? 0;
    return RedditPost(
      id:           d['id']?.toString() ?? '',
      subreddit:    'r/${d['subreddit'] ?? ''}',
      title:        d['title']?.toString() ?? 'No Title',
      url:          d['url']?.toString(),
      permalink:    d['permalink']?.toString(),
      ups:          (d['score'] as num?)?.toInt() ?? (d['ups'] as num?)?.toInt() ?? 0,
      numComments:  (d['num_comments'] as num?)?.toInt() ?? 0,
      time:         _formatTime(d['created_utc'] as num?),
      rawTimestamp: ts,
      isNsfw:       d['over_18'] == true,
      source:       source,
    );
  }

  /// Legacy — auto-detects wrapper vs flat.
  factory RedditPost.fromJson(Map<String, dynamic> json) {
    final hasWrapper = json.containsKey('data') && json['data'] is Map;
    return hasWrapper
        ? RedditPost.fromRedditJson(json)
        : RedditPost.fromPullPushJson(json);
  }

  String get redditUrl {
    if (permalink != null) return 'https://www.reddit.com$permalink';
    if (url != null)       return url!;
    return 'https://www.reddit.com';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

@HiveType(typeId: 2)
class RedditComment {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String subreddit;
  @HiveField(2)
  final String body;
  @HiveField(3)
  final String? linkTitle;
  @HiveField(4)
  final String? permalink;
  @HiveField(5)
  final int ups;
  @HiveField(6)
  final int rawTimestamp;
  @HiveField(7)
  final String time;
  @HiveField(8)
  final bool isControversial;
  @HiveField(9)
  final bool isNsfw;
  @HiveField(10)
  final String source;

  RedditComment({
    required this.id,
    required this.subreddit,
    required this.body,
    this.linkTitle,
    this.permalink,
    required this.ups,
    required this.rawTimestamp,
    required this.time,
    required this.isControversial,
    this.isNsfw = false,
    this.source = 'UNKNOWN',
  });

  /// From Reddit's own API — child object has kind + data wrapper.
  factory RedditComment.fromRedditJson(Map<String, dynamic> child, {String source = 'PUBLIC'}) {
    final d = (child['data'] ?? child) as Map<String, dynamic>;
    final ts = (d['created_utc'] as num?)?.toInt() ?? 0;
    return RedditComment(
      id:              d['id']?.toString() ?? '',
      subreddit:       'r/${d['subreddit'] ?? ''}',
      body:            d['body']?.toString() ?? '',
      linkTitle:       d['link_title']?.toString(),
      permalink:       d['permalink']?.toString(),
      ups:             (d['ups'] as num?)?.toInt() ?? (d['score'] as num?)?.toInt() ?? 0,
      isControversial: ((d['controversiality'] as num?)?.toInt() ?? 0) > 0,
      isNsfw:          d['over_18'] == true,
      rawTimestamp:    ts,
      time:            _formatTime(d['created_utc'] as num?),
      source:          source,
    );
  }

  /// From PullPush — flat object.
  factory RedditComment.fromPullPushJson(Map<String, dynamic> d, {String source = 'ARCHIVE'}) {
    final ts = (d['created_utc'] as num?)?.toInt() ?? 0;
    return RedditComment(
      id:              d['id']?.toString() ?? '',
      subreddit:       'r/${d['subreddit'] ?? ''}',
      body:            d['body']?.toString() ?? '',
      linkTitle:       d['link_title']?.toString(),
      permalink:       d['permalink']?.toString(),
      ups:             (d['score'] as num?)?.toInt() ?? (d['ups'] as num?)?.toInt() ?? 0,
      isControversial: ((d['controversiality'] as num?)?.toInt() ?? 0) > 0,
      isNsfw:          d['over_18'] == true,
      rawTimestamp:    ts,
      time:            _formatTime(d['created_utc'] as num?),
      source:          source,
    );
  }

  /// Legacy — auto-detects wrapper vs flat.
  factory RedditComment.fromJson(Map<String, dynamic> json) {
    final hasWrapper = json.containsKey('data') && json['data'] is Map;
    return hasWrapper
        ? RedditComment.fromRedditJson(json)
        : RedditComment.fromPullPushJson(json);
  }

  String get redditUrl {
    if (permalink != null) return 'https://www.reddit.com$permalink';
    return 'https://www.reddit.com';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

String _formatTime(num? createdUtc) {
  if (createdUtc == null) return 'Just now';
  final created = DateTime.fromMillisecondsSinceEpoch(createdUtc.toInt() * 1000);
  final diff    = DateTime.now().difference(created);
  if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24)  return '${diff.inHours}h ago';
  if (diff.inDays    < 365) return '${diff.inDays}d ago';
  final years = (diff.inDays / 365).floor();
  return '${years}y ago';
}
