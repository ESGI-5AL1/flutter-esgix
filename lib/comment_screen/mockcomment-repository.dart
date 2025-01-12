import '../shared/models/post.dart';
import 'comment_repository.dart';

class MockCommentRepository extends CommentRepository {
  MockCommentRepository() : super(baseUrl: '', apiKey: '');

  @override
  Future<List<Post>> fetchComments(String postId) async {
    // Simulez des données factices basées sur le postId
    final fakeComments = [
      const Post(
        id: '2',
        content: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
        imageUrl: '',
        parent: '1',
        likes: 12,
      ),
      const Post(
        id: '3',
        content: 'Another example of dummy text for this post.',
        imageUrl: '',
        parent: '1',
        likes: 8,
      ),
      const Post(
        id: '4',
        content: 'This is another comment for testing purposes.',
        imageUrl: '',
        parent: '1',
        likes: 5,
      ),
    ];

    // Retournez uniquement les commentaires correspondant à l'ID du post parent
    return fakeComments.where((comment) => comment.parent == postId).toList();
  }
}
