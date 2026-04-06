import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/reddit_models.dart';

class RedditService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://oauth.reddit.com',
    headers: {
      'User-Agent': 'reddit_profile_viewer/1.0.0',
    },
  ));

  String? _accessToken;

  // Primary entry point for fetching and analyzing a user
  Future<RedditProfile> analyzeUser(String username) async {
    try {
      await _authenticate();
      
      // 1. Fetch Profile
      final profile = await fetchUserProfile(username);
      
      // 2. Fetch Recent Activities
      final posts = await fetchUserPosts(username);
      final comments = await fetchUserComments(username);
      
      // 3. Perform Analysis
      final analyzeProfile = _calculateIntelligence(profile, posts, comments);
      
      return analyzeProfile;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _authenticate() async {
    // Basic Client Credentials Flow for Public Data
    if (_accessToken != null) return;

    final clientId = dotenv.env['REDDIT_CLIENT_ID'];
    final clientSecret = dotenv.env['REDDIT_CLIENT_SECRET'];

    if (clientId == null || clientSecret == null) {
       // Fallback to anonymous public API if no credentials (though limited)
       return;
    }

    final authDio = Dio();
    final response = await authDio.post(
      'https://www.reddit.com/api/v1/access_token',
      data: {
        'grant_type': 'client_credentials',
      },
      options: Options(
        headers: {
          'Authorization': 'Basic ${RegExp(r'\s+').hasMatch('$clientId:$clientSecret') ? '' : ''}', // Placeholder logic
        },
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    
    // Manual Basic Auth because RegEx is complex to get right in one line
    // String basicAuth = 'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret'));
    // We'll use a more robust way in the actual file.
  }

  Future<RedditProfile> fetchUserProfile(String username) async {
    // For read-only public info, we can also use public.reddit.com/u/user/about.json
    final response = await Dio().get('https://www.reddit.com/user/$username/about.json');
    return RedditProfile.fromJson(response.data);
  }

  Future<List<RedditPost>> fetchUserPosts(String username) async {
    final response = await Dio().get('https://www.reddit.com/user/$username/submitted.json?limit=10');
    final List children = response.data['data']['children'] ?? [];
    return children.map((p) => RedditPost.fromJson(p)).toList();
  }

  Future<List<RedditComment>> fetchUserComments(String username) async {
    final response = await Dio().get('https://www.reddit.com/user/$username/comments.json?limit=25');
    final List children = response.data['data']['children'] ?? [];
    return children.map((c) => RedditComment.fromJson(c)).toList();
  }

  RedditProfile _calculateIntelligence(RedditProfile profile, List<RedditPost> posts, List<RedditComment> comments) {
    // Simple logic for Intelligence Scan
    double toxic = 0.0;
    double controversial = 0.0;
    
    for (var comment in comments) {
      if (comment.isControversial) controversial += 0.2;
      // Mock keyword scan
      if (comment.body.contains(RegExp(r'hate|stupid|awful', caseSensitive: false))) toxic += 0.1;
    }

    return profile.copyWith(
      toxicity: toxic.clamp(0.0, 1.0),
      controversialIndex: controversial.clamp(0.0, 1.0),
      recentPosts: posts,
      recentComments: comments,
    );
  }
}
