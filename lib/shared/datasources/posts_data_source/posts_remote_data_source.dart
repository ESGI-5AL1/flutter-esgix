import 'package:dio/dio.dart';
import 'package:esgix/shared/datasources/posts_data_source/posts_data_source.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/author.dart';
import '../../models/post.dart';

class PostRemoteDataSource implements PostDataSource {
  final Dio dio;
  static const String baseUrl = 'https://esgix.tech';
  static const String _tokenKey = 'auth_token';

  PostRemoteDataSource({required this.dio});

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Options> _getRequestOptions() async {
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await _getAuthToken();

    return Options(
      headers: {
        'x-api-key': apiKey,
        'Authorization': authToken != null ? 'Bearer $authToken' : null,
        'Content-Type': 'application/json',
      },
    );
  }

  @override
  Future<List<Post>> getPosts() async {
    try {
      final response = await dio.get(
        '$baseUrl/posts?page=0&offset=-1',
        options: await _getRequestOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch posts');
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final response = await dio.get(
        '$baseUrl/user/$userId/posts?page=0&offset=-1',
        options: await _getRequestOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch user posts');
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<List<Post>> getUserLikes(String userId) async {
    try {
      final response = await dio.get(
        '$baseUrl/user/$userId/likes?page=0&offset=10',
        options: await _getRequestOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) {
          final post = Post.fromJson(json);
          return post.copyWith(likedByUser: true);
        }).toList();
      }
      throw Exception('Failed to fetch user likes');
    } catch (e) {
      throw Exception('Failed to fetch user likes: $e');
    }
  }

  @override
  Future<Post?> createPost(String content, String? imageUrl) async {
    try {
      final Map<String, dynamic> requestBody = {
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      final response = await dio.post(
        '$baseUrl/posts',
        data: requestBody,
        options: await _getRequestOptions(),
      );



      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is String) {
          return null;
        }
        return Post.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error creating post: $e');
    }

    return null;
  }

  @override
  Future<Post?> updatePost(
      String postId, String content, String? imageUrl) async {
    try {
      final Map<String, dynamic> requestBody = {
        'content': content,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      final response = await dio.put(
        '$baseUrl/posts/$postId',
        data: requestBody,
        options: await _getRequestOptions(),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is String) {
          return null;
        }

        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return Post.fromJson(responseData['data'] as Map<String, dynamic>);
        }

        print('Unexpected response format');
      }
    } catch (e) {
      print('Error updating post: $e');
    }

    return null;
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final response = await dio.delete(
        '$baseUrl/posts/$postId',
        options: await _getRequestOptions(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      final response = await dio.post(
        '$baseUrl/likes/$postId',
        options: await _getRequestOptions(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  @override
  Future<List<Post>> getComments(String postId) async {
    try {
      final response = await dio.get(
        '$baseUrl/posts?parent=$postId&page=0&offset=-1',
        options: await _getRequestOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch comments');
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  @override
  Future<Post> getPostById(String postId) async {
    try {
      final response = await dio.get(
        '$baseUrl/posts/$postId',
        options: await _getRequestOptions(),
      );

      if (response.statusCode == 200) {
        return Post.fromJson(response.data['data']);
      }
      throw Exception('Failed to fetch post');
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  @override
  Future<List<Post>> searchPosts(String query) async {
    try {
      final response = await dio.get(
        '$baseUrl/search',
        queryParameters: {'query': query},
        options: await _getRequestOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      throw Exception('Failed to search posts');
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }
}
