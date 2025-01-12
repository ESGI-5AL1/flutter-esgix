import '../shared/models/PostResult.dart';
import '../shared/models/post.dart';
import 'comment_repository.dart';

class MockCommentRepository extends CommentRepository {
  MockCommentRepository() : super(baseUrl: '', apiKey: '');

  @override
  Future<List<PostResult>> fetchComments(String postId) async {

    final fakeComments = [
      const PostResult(
        id: '2',
        content: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
        imageUrl: '',
        parent: '1',
        likes: 12,
        commentsCount: 0,
        authorUsername: 'User1',
        authorAvatar: 'https://picsum.photos/200',
      ),
      const PostResult(
        id: '3',
        content: 'Another example of dummy text for this post.',
        imageUrl: '',
        parent: '1',
        likes: 8,
        commentsCount: 0,
        authorUsername: 'User2',
        authorAvatar: 'https://picsum.photos/200',
      ),
      const PostResult(
        id: '4',
        content: 'This is another comment for testing purposes.',
        imageUrl: '',
        parent: '1',
        likes: 5,
        commentsCount: 0,
        authorUsername: 'User3',
        authorAvatar: '',
      ),
      const PostResult(
        id: '5',
        content: 'Another comment for a different parent.',
        imageUrl: '',
        parent: '2',
        likes: 2,
        commentsCount: 0,
        authorUsername: 'User4',
        authorAvatar: 'https://picsum.photos/200',
      ),
    ];


    return fakeComments.where((comment) => comment.parent == postId).toList();
  }

}
