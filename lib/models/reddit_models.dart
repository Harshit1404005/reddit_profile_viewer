class RedditProfile {
  final String username;
  final int totalKarma;
  final String accountAge;
  final String status;
  final double toxicity;
  final double nsfw;
  final double controversialIndex;
  final List<RedditPost> recentPosts;
  final List<RedditComment> recentComments;
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
    // Basic mapping from Reddit API structure
    final data = json['data'] ?? {};
    return RedditProfile(
      username: data['name'] ?? 'Unknown',
      totalKarma: (data['total_karma'] ?? 0),
      accountAge: _calculateAge(data['created_utc']),
      status: (data['hide_from_robots'] ?? false) ? 'HIDDEN' : 'VISIBLE',
      toxicity: 0.0, // Calculated later
      nsfw: (data['over_18'] ?? false) ? 1.0 : 0.0,
      controversialIndex: 0.0, // Calculated later
      recentPosts: [],
      recentComments: [],
    );
  }

  static String _calculateAge(num? createdUtc) {
    if (createdUtc == null) return 'Unknown';
    final created = DateTime.fromMillisecondsSinceEpoch(createdUtc.toInt() * 1000);
    final now = DateTime.now();
    final diff = now.difference(created);
    final years = (diff.inDays / 365).floor();
    final months = ((diff.inDays % 365) / 30).floor();
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
      username: username,
      totalKarma: totalKarma,
      accountAge: accountAge,
      status: status,
      toxicity: toxicity ?? this.toxicity,
      nsfw: nsfw,
      controversialIndex: controversialIndex ?? this.controversialIndex,
      recentPosts: recentPosts ?? this.recentPosts,
      recentComments: recentComments ?? this.recentComments,
      afterToken: clearAfterToken ? null : (afterToken ?? this.afterToken),
    );
  }
}

class RedditPost {
  final String id;
  final String subreddit;
  final String title;
  final int ups;
  final int numComments;
  final String time;

  RedditPost({
    required this.id,
    required this.subreddit,
    required this.title,
    required this.ups,
    required this.numComments,
    required this.time,
  });

  factory RedditPost.fromJson(Map<String, dynamic> json) {
    // Official Reddit wraps the post in "data". PullPush serves it flat.
    final data = json.containsKey('data') && json['data'] is Map ? json['data'] : json;
    
    return RedditPost(
      id: data['id']?.toString() ?? '',
      subreddit: 'r/${data['subreddit'] ?? ''}',
      title: data['title'] ?? 'No Title',
      ups: data['ups'] ?? data['score'] ?? 0,
      numComments: data['num_comments'] ?? 0,
      time: _formatTime(data['created_utc']),
    );
  }
}

class RedditComment {
  final String id;
  final String subreddit;
  final String body;
  final int ups;
  final String time;
  final bool isControversial;

  RedditComment({
    required this.id,
    required this.subreddit,
    required this.body,
    required this.ups,
    required this.time,
    required this.isControversial,
  });

  factory RedditComment.fromJson(Map<String, dynamic> json) {
    // Official Reddit wraps the comment in "data". PullPush serves it flat.
    final data = json.containsKey('data') && json['data'] is Map ? json['data'] : json;

    return RedditComment(
      id: data['id']?.toString() ?? '',
      subreddit: 'r/${data['subreddit'] ?? ''}',
      body: data['body'] ?? '',
      ups: data['ups'] ?? data['score'] ?? 0,
      isControversial: (data['controversiality'] ?? 0) > 0,
      time: _formatTime(data['created_utc']),
    );
  }
}

String _formatTime(num? createdUtc) {
  if (createdUtc == null) return 'Just now';
  final created = DateTime.fromMillisecondsSinceEpoch(createdUtc.toInt() * 1000);
  final now = DateTime.now();
  final diff = now.difference(created);
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
