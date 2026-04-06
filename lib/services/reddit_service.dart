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

  @override
  String get mode => "PUBLIC_INTELLIGENCE";

  @override
  Future<RedditProfile> analyzeUser(String username) async {
    try {
      // 1. Fetch Profile Info
      final profileResponse = await _dio.get('/user/$username/about.json');
      final profile = RedditProfile.fromJson(profileResponse.data);

      // 2. Fetch Overview (Posts + Comments combined, initial 20)
      final overviewResponse = await _dio.get('/user/$username/overview.json?limit=20');
      final parsed = parseOverview(overviewResponse.data);

      // 3. Synthesize Intelligence
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
      final overviewResponse = await _dio.get(
        '/user/${currentProfile.username}/overview.json?limit=20&after=${currentProfile.afterToken}'
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
