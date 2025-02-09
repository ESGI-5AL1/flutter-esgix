import '../../datasources/posts_data_source/posts_data_source.dart';
import '../../models/post.dart';

class PostRepository {
  final PostDataSource remoteDataSource;

  PostRepository({required this.remoteDataSource});

  Future<List<Post>> getPosts() async {
    try {
      return await remoteDataSource.getPosts();
    } catch (e) {
      throw Exception('Repository: Failed to fetch posts: $e');
    }
  }

  Future<List<Post>> getUserPosts(String userId) async {
    try {
      return await remoteDataSource.getUserPosts(userId);
    } catch (e) {
      throw Exception('Repository: Failed to fetch user posts: $e');
    }
  }

  Future<List<Post>> getUserLikes(String userId) async {
    try {
      return await remoteDataSource.getUserLikes(userId);
    } catch (e) {
      throw Exception('Repository: Failed to fetch user likes: $e');
    }
  }

  Future<Post?> createPost(String content, String? imageUrl, {String? parent}) async {
    try {
      return await remoteDataSource.createPost(content, imageUrl, parent: parent);
    } catch (e) {
      throw Exception('Repository: Failed to create post: $e');
    }
  }

  Future<Post?> updatePost(
      String postId, String content, String? imageUrl) async {
    try {
      return await remoteDataSource.updatePost(postId, content, imageUrl);
    } catch (e) {
      throw Exception('Repository: Failed to update post: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
    } catch (e) {
      throw Exception('Repository: Failed to delete post: $e');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await remoteDataSource.likePost(postId);
    } catch (e) {
      throw Exception('Repository: Failed to like post: $e');
    }
  }

  Future<List<Post>> getComments(String postId) async {
    try {
      return await remoteDataSource.getComments(postId);
    } catch (e) {
      throw Exception('Repository: Failed to fetch comments: $e');
    }
  }

  Future<Post> getPostById(String postId) async {
    try {
      return await remoteDataSource.getPostById(postId);
    } catch (e) {
      throw Exception('Repository: Failed to fetch post: $e');
    }
  }

  Future<List<Post>> searchPosts(String query) async {
    try {
      return await remoteDataSource.searchPosts(query);
    } catch (e) {
      throw Exception('Repository: Failed to search posts: $e');
    }
  }

  // Dans posts_repository.dart
  Future<Post?> createComment(String content, String parentId) async {
    try {
      return await remoteDataSource.createPost(content, null, parent: parentId);
    } catch (e) {
      throw Exception('Repository: Failed to create comment: $e');
    }
  }
}
