import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/reddit_models.dart';

/// Abstract base for Reddit intelligence gathering.
abstract class RedditService {
  RedditService();

  Future<RedditProfile> analyzeUser(String username);
  Future<RedditProfile> fetchMoreActivity(RedditProfile currentProfile);
  String get mode;

  /// Factory to pick the appropriate service based on environment configuration.
  factory RedditService.create() {
    final clientId = dotenv.env['REDDIT_CLIENT_ID'];
    final clientSecret = dotenv.env['REDDIT_CLIENT_SECRET'];

    bool hasAuth = clientId != null && 
                  clientId.isNotEmpty && 
                  !clientId.contains('your_client_id') &&
                  clientSecret != null &&
                  clientSecret.isNotEmpty;

    return hasAuth ? OAuthRedditService() : PublicRedditService();
  }

  /// Parses the combined overview stream into posts and comments.
  Map<String, dynamic> parseOverview(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final children = data['children'] as List? ?? [];
    final posts = <RedditPost>[];
    final comments = <RedditComment>[];
    
    for (var child in children) {
      final kind = child['kind'];
      if (kind == 't3') {
        posts.add(RedditPost.fromJson(child));
      } else if (kind == 't1') {
        comments.add(RedditComment.fromJson(child));
      }
    }
    
    return {
      'posts': posts,
      'comments': comments,
      'after': data['after'],
    };
  }

  /// Shared intelligence synthesis logic.
  RedditProfile calculateIntelligence(RedditProfile profile, List<RedditPost> posts, List<RedditComment> comments, {String? afterToken}) {
    double toxic = 0.0;
    double controversial = 0.0;
    
    for (var comment in comments) {
      if (comment.isControversial) controversial += 0.2;
      if (comment.body.contains(RegExp(r'hate|stupid|awful|terrible|idiot|garbage', caseSensitive: false))) {
        toxic += 0.15;
      }
    }

    return profile.copyWith(
      toxicity: toxic.clamp(0.0, 1.0),
      controversialIndex: controversial.clamp(0.0, 1.0),
      recentPosts: posts,
      recentComments: comments,
      afterToken: afterToken,
    );
  }
}

/// IMPLEMENTATION A: Public Intelligence Engine (No-Auth)
class PublicRedditService extends RedditService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://www.reddit.com',
    headers: {
      'User-Agent': 'android:reddit_scope:v1.0.0 (by /u/Harshit1404005)',
    },
  ));

  final Dio _pullPush = Dio(BaseOptions(
    baseUrl: 'https://api.pullpush.io',
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    },
  ));

  @override
  String get mode => "DEEP_ARCHIVE (PULLPUSH)";

  @override
  Future<RedditProfile> analyzeUser(String username) async {
    try {
      // 1. Fetch Profile Info (Graceful fallback)
      RedditProfile profile;
      try {
        final profileResponse = await _dio.get('/user/$username/about.json');
        profile = RedditProfile.fromJson(profileResponse.data);
      } catch (e) {
        profile = RedditProfile(
          username: username,
          totalKarma: 0,
          accountAge: 'Unknown (Private)',
          status: 'HIDDEN (ARCHIVE BYPASS)',
          toxicity: 0.0,
          nsfw: 0.0,
          controversialIndex: 0.0,
          recentPosts: [],
          recentComments: [],
        );
      }

      // 2. Fetch parallel archives (size 50 each)
      final postRes = await _pullPush.get('/reddit/search/submission/?author=$username&size=50');
      final postsData = postRes.data['data'] as List? ?? [];
      final posts = postsData.map((p) => RedditPost.fromJson(p)).toList();

      final comRes = await _pullPush.get('/reddit/search/comment/?author=$username&size=50');
      final comData = comRes.data['data'] as List? ?? [];
      final comments = comData.map((c) => RedditComment.fromJson(c)).toList();

      // Determine an artificial after token via timestamp
      String? nextToken;
      if (posts.isNotEmpty) {
        // Find smallest created_utc to paginate backwards
        final lastObj = postsData.last;
        if (lastObj['created_utc'] != null) {
          nextToken = lastObj['created_utc'].toString();
        }
      } else if (comments.isNotEmpty) {
        final lastObj = comData.last;
        if (lastObj['created_utc'] != null) {
          nextToken = lastObj['created_utc'].toString();
        }
      }

      return calculateIntelligence(profile, posts, comments, afterToken: nextToken);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RedditProfile> fetchMoreActivity(RedditProfile currentProfile) async {
    if (currentProfile.afterToken == null) return currentProfile;

    try {
      final beforeTime = currentProfile.afterToken!;
      final username = currentProfile.username;

      final postRes = await _pullPush.get('/reddit/search/submission/?author=$username&size=50&before=$beforeTime');
      final postsData = postRes.data['data'] as List? ?? [];
      final newPosts = postsData.map((p) => RedditPost.fromJson(p)).toList();

      final comRes = await _pullPush.get('/reddit/search/comment/?author=$username&size=50&before=$beforeTime');
      final comData = comRes.data['data'] as List? ?? [];
      final newComments = comData.map((c) => RedditComment.fromJson(c)).toList();

      final combinedPosts = List<RedditPost>.from(currentProfile.recentPosts)..addAll(newPosts);
      final combinedComments = List<RedditComment>.from(currentProfile.recentComments)..addAll(newComments);

      String? nextToken;
      if (postsData.isNotEmpty) {
        nextToken = postsData.last['created_utc']?.toString();
      } else if (comData.isNotEmpty) {
        nextToken = comData.last['created_utc']?.toString();
      }

      return calculateIntelligence(
        currentProfile, 
        combinedPosts, 
        combinedComments, 
        afterToken: nextToken
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// IMPLEMENTATION B: Secure Intelligence Engine (OAuth)
class OAuthRedditService extends RedditService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://oauth.reddit.com',
    headers: {
      'User-Agent': 'android:reddit_scope:v1.0.0 (by /u/Harshit1404005)',
    },
  ));

  String? _accessToken;

  @override
  String get mode => "OAUTH_SECURE";

  @override
  Future<RedditProfile> analyzeUser(String username) async {
    try {
      await _authenticate();
      _dio.options.headers['Authorization'] = 'Bearer $_accessToken';

      final profileResponse = await _dio.get('/user/$username/about');
      final profile = RedditProfile.fromJson(profileResponse.data);

      final overviewResponse = await _dio.get('/user/$username/overview?limit=20');
      final parsed = parseOverview(overviewResponse.data);

      return calculateIntelligence(
        profile, 
        parsed['posts'], 
        parsed['comments'], 
        afterToken: parsed['after']
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RedditProfile> fetchMoreActivity(RedditProfile currentProfile) async {
    if (currentProfile.afterToken == null) return currentProfile;

    try {
      await _authenticate();
      _dio.options.headers['Authorization'] = 'Bearer $_accessToken';

      final overviewResponse = await _dio.get(
        '/user/${currentProfile.username}/overview?limit=20&after=${currentProfile.afterToken}'
      );
      final parsed = parseOverview(overviewResponse.data);

      final List<RedditPost> newPosts = List.from(currentProfile.recentPosts)..addAll(parsed['posts']);
      final List<RedditComment> newComments = List.from(currentProfile.recentComments)..addAll(parsed['comments']);

      return calculateIntelligence(
        currentProfile, 
        newPosts, 
        newComments, 
        afterToken: parsed['after']
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _authenticate() async {
    if (_accessToken != null) return;
    final clientId = dotenv.env['REDDIT_CLIENT_ID'];
    final clientSecret = dotenv.env['REDDIT_CLIENT_SECRET'];
    final authString = base64Encode(utf8.encode('$clientId:$clientSecret'));
    
    final response = await Dio().post(
      'https://www.reddit.com/api/v1/access_token',
      data: {'grant_type': 'client_credentials'},
      options: Options(
        headers: {'Authorization': 'Basic $authString'},
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    _accessToken = response.data['access_token'];
  }
}
