import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_event.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../login_screen/login_bloc/login_bloc.dart';
import '../../models/post.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final Dio dio;
  static const String _tokenKey = 'auth_token';

  PostBloc({required this.dio}) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<AddNewPost>(_onAddNewPost);
    on<CreatePost>(_onCreatePost);
    on<DeletePost>(_onDeletePost);
    on<LikePost>(_onLikePost);
    on<UpdateLikeStatus>(_onUpdateLikeStatus);
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await _getAuthToken();

    try {
      final response = await dio.get(
        'https://esgix.tech/posts?page=0&offset=20',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': authToken != null ? 'Bearer $authToken' : null,
            'Content-Type': 'application/json',
          }
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          final posts = data.map((json) => Post.fromJson(json)).toList();
          emit(PostLoaded(posts));
        } else {
          emit(PostError('Data field is not a List.'));
        }
      } else {
        emit(PostError('Failed to fetch posts. Status code: ${response.statusCode}'));
      }
    } catch (error) {
      emit(PostError('Failed to fetch posts: $error'));
    }
  }

  void _onAddNewPost(AddNewPost event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      emit(PostLoaded([event.post, ...currentState.posts]));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostState> emit) async {
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await _getAuthToken();

    if (authToken == null) {
      emit(PostError('Authentication required'));
      return;
    }

    try {
      final response = await dio.post(
        'https://esgix.tech/posts',
        data: {
          'content': event.content,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final newPost = Post.fromJson(response.data);
        add(AddNewPost(newPost));
      } else {
        emit(PostError('Failed to create post. Status code: ${response.statusCode}'));
      }
    } catch (error) {
      emit(PostError('Failed to create new post'));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await LoginBloc.getToken();

    if (authToken == null) {
      emit(PostError('Authentication required'));
      return;
    }

    try {
      final response = await dio.delete(
        'https://esgix.tech/posts/${event.postId}',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (state is PostLoaded) {
          final currentState = state as PostLoaded;
          final updatedPosts = currentState.posts
              .where((post) => post.id != event.postId)
              .toList();
          emit(PostLoaded(updatedPosts));
        }
      } else {
        emit(PostError('Failed to delete post'));
      }
    } catch (error) {
      emit(PostError('Failed to delete post'));
    }
  }

  Future<void> _onLikePost(LikePost event, Emitter<PostState> emit) async {
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await LoginBloc.getToken();

    if (state is! PostLoaded) return;
    final currentState = state as PostLoaded;

    try {
      final response = await dio.post(
        'https://esgix.tech/likes/${event.postId}',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update the post's like status in the state
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              likedByUser: !post.likedByUser,
              likesCount: post.likedByUser ? post.likesCount - 1 : post.likesCount + 1,
            );
          }
          return post;
        }).toList();

        emit(PostLoaded(updatedPosts));
      }
    } catch (error) {
      // If the like request fails, we might want to revert the optimistic update
      emit(PostError('Failed to like post'));
      emit(currentState); // Revert to previous state
    }
  }

  void _onUpdateLikeStatus(UpdateLikeStatus event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(
            likedByUser: event.isLiked,
            likesCount: event.likesCount,
          );
        }
        return post;
      }).toList();
      emit(PostLoaded(updatedPosts));
    }
  }
}