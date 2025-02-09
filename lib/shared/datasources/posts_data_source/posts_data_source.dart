import '../../models/post.dart';

abstract class PostDataSource {
  Future<List<Post>> getPosts();

  Future<List<Post>> getUserPosts(String userId);

  Future<List<Post>> getUserLikes(String userId);

  Future<Post?> createPost(String content, String? imageUrl, {String? parent});

  Future<Post?> updatePost(String postId, String content, String? imageUrl);

  Future<void> deletePost(String postId);

  Future<void> likePost(String postId);

  Future<List<Post>> getComments(String postId);

  Future<Post> getPostById(String postId);

  Future<List<Post>> searchPosts(String query);
}
