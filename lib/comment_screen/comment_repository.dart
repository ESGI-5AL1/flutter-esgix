import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/models/post.dart';

class CommentRepository {
  final String baseUrl;
  final String apiKey;

  CommentRepository({required this.baseUrl, required this.apiKey}); // Utilisation de paramètres nommés

  Future<List<Post>> fetchComments(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?parent=$postId'),
      headers: {
        'x-api-key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> addComment(String postId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      },
      body: json.encode({
        'parent': postId,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add comment');
    }
  }

}
