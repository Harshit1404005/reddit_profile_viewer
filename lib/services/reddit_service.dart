import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/reddit_models.dart';

/// Abstract base for Reddit intelligence gathering.
/// 
/// This modular architecture allows the app to switch between 
/// Public (No-Auth) and Secure (OAuth) engines.
abstract class RedditService {
  Future<RedditProfile> analyzeUser(String username);
  String get mode;

  /// Factory to pick the appropriate service based on environment configuration.
  factory RedditService.create() {
    final clientId = dotenv.env['REDDIT_CLIENT_ID'];
    final clientSecret = dotenv.env['REDDIT_CLIENT_SECRET'];

    // Check if real credentials exist and aren't placeholders
    bool hasAuth = clientId != null && 
                  clientId.isNotEmpty && 
                  !clientId.contains('your_client_id') &&
                  clientSecret != null &&
                  clientSecret.isNotEmpty;

    return hasAuth ? OAuthRedditService() : PublicRedditService();
  }

  /// Shared intelligence synthesis logic.
  RedditProfile calculateIntelligence(RedditProfile profile, List<RedditPost> posts, List<RedditComment> comments) {
    double toxic = 0.0;
    double controversial = 0.0;
    
    for (var comment in comments) {
      if (comment.isControversial) controversial += 0.2;
      // Sentiment keyword scan
      if (comment.body.contains(RegExp(r'hate|stupid|awful|terrible|idiot|garbage', caseSensitive: false))) {
        toxic += 0.15;
      }
    }

    return profile.copyWith(
      toxicity: toxic.clamp(0.0, 1.0),
      controversialIndex: controversial.clamp(0.0, 1.0),
      recentPosts: posts,
      recentComments: comments,
    );
  }
}

/// IMPLEMENTATION A: Public Intelligence Engine (No-Auth)
/// Uses public .json endpoints which are accessible without a Client ID.
class PublicRedditService extends RedditService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://www.reddit.com',
    headers: {
      'User-Agent': 'android:reddit_scope:v1.0.0 (by /u/Harshit1404005)',
    },
  ));

  @override
  String get mode => "PUBLIC_INTELLIGENCE";

  @override
  Future<RedditProfile> analyzeUser(String username) async {
    try {
      // 1. Fetch Profile Info
      final profileResponse = await _dio.get('/user/$username/about.json');
      final profile = RedditProfile.fromJson(profileResponse.data);

      // 2. Fetch Posts
      final postsResponse = await _dio.get('/user/$username/submitted.json?limit=10');
      final List postChildren = postsResponse.data['data']['children'] ?? [];
      final posts = postChildren.map((p) => RedditPost.fromJson(p)).toList();

      // 3. Fetch Comments
      final commentsResponse = await _dio.get('/user/$username/comments.json?limit=25');
      final List commentChildren = commentsResponse.data['data']['children'] ?? [];
      final comments = commentChildren.map((c) => RedditComment.fromJson(c)).toList();

      // 4. Synthesize Intelligence
      return calculateIntelligence(profile, posts, comments);
    } catch (e) {
      print("Public API Error: $e");
      rethrow;
    }
  }
}

/// IMPLEMENTATION B: Secure Intelligence Engine (OAuth)
/// Uses the official Reddit Data API. Requires approved CLIENT_ID and SECRET.
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

      // OAuth endpoints have slightly different structures or require different paths 
      // but usually the user/about still works.
      final profileResponse = await _dio.get('/user/$username/about');
      final profile = RedditProfile.fromJson(profileResponse.data);

      final postsResponse = await _dio.get('/user/$username/submitted?limit=10');
      final List postChildren = postsResponse.data['data']['children'] ?? [];
      final posts = postChildren.map((p) => RedditPost.fromJson(p)).toList();

      final commentsResponse = await _dio.get('/user/$username/comments?limit=25');
      final List commentChildren = commentsResponse.data['data']['children'] ?? [];
      final comments = commentChildren.map((c) => RedditComment.fromJson(c)).toList();

      return calculateIntelligence(profile, posts, comments);
    } catch (e) {
      print("OAuth API Error: $e");
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
