import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/comment.dart';

class CommentService {
  final http.Client _client;

  CommentService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Comment>> getCommentsByPostId(int postId) async {
    final uri = Uri.parse('$host/comments/post/$postId');
    try {
      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List commentsJson = data['comments'] ?? [];
        return commentsJson.map((c) => Comment.fromJson(c)).toList();
      } else {
        // Fallback: try querying comments by postId parameter
        final fallbackUri = Uri.parse('$host/comments');
        final fallbackResp = await _client
            .get(fallbackUri)
            .timeout(const Duration(seconds: 8));
        if (fallbackResp.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(fallbackResp.body);
          final List commentsJson = data['comments'] ?? [];
          final filtered = commentsJson
              .where((c) => c['postId'] == postId)
              .map((c) => Comment.fromJson(c))
              .toList();
          return filtered;
        }
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Comment>> getAllComments({int limit = 30, int skip = 0}) async {
    final uri = Uri.parse('$host/comments?limit=$limit&skip=$skip');
    try {
      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List commentsJson = data['comments'] ?? [];
        return commentsJson.map((c) => Comment.fromJson(c)).toList();
      } else {
        throw Exception('Failed to load all comments: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Comment> addComment({
    required String body,
    required int postId,
    required int userId,
  }) async {
    final uri = Uri.parse('$host/comments/add');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'body': body,
            'postId': postId,
            'userId': userId,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Comment.fromJson(data);
    } else {
      throw Exception('Failed to add comment: ${response.statusCode}');
    }
  }
}
