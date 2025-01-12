import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/models/PostResult.dart';


class CommentRepository {
  final String baseUrl;
  final String apiKey;

  CommentRepository({required this.baseUrl, required this.apiKey});

  Future<List<PostResult>> fetchComments(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?parent=$postId'),
      headers: {
        'x-api-key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((json) => PostResult.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> addComment(String parentId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: json.encode({
        'parent': parentId,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add comment');
    }
  }

  Future<void> toggleLike(String postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/like'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle like');
    }
  }
}
