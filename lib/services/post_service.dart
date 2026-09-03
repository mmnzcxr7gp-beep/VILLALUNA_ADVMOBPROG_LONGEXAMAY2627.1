import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/post.dart';

class PostService {
  final http.Client _client;

  PostService({http.Client? client}) : _client = client ?? http.Client();

  static List<Post>? _cachedPosts;

  Future<List<Post>> getPosts({int limit = 30, int skip = 0, bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPosts != null && _cachedPosts!.isNotEmpty && skip == 0) {
      return _cachedPosts!;
    }

    final uri = Uri.parse('$host/posts?limit=$limit&skip=$skip');
    try {
      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List postsJson = data['posts'] ?? [];
        final list = postsJson.map((p) => Post.fromJson(p)).toList();
        if (skip == 0) {
          _cachedPosts = list;
        }
        return list;
      } else {
        if (_cachedPosts != null && _cachedPosts!.isNotEmpty) return _cachedPosts!;
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      if (_cachedPosts != null && _cachedPosts!.isNotEmpty) return _cachedPosts!;
      rethrow;
    }
  }

  Future<List<Post>> getPostsByUserId(int userId) async {
    final uri = Uri.parse('$host/posts/user/$userId');
    try {
      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List postsJson = data['posts'] ?? [];
        return postsJson.map((p) => Post.fromJson(p)).toList();
      } else {
        throw Exception('Failed to load user posts: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Post> getPostById(int id) async {
    final uri = Uri.parse('$host/posts/$id');
    final response = await _client
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Post.fromJson(data);
    } else {
      throw Exception('Failed to load post: ${response.statusCode}');
    }
  }

  Future<Post> addPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    final uri = Uri.parse('$host/posts/add');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'title': title,
            'body': body,
            'userId': userId,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Post.fromJson(data);
    } else {
      throw Exception('Failed to add post: ${response.statusCode}');
    }
  }
}
