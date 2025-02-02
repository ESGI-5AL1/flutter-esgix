
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_event.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/post.dart';


class PostBloc extends Bloc<PostEvent, PostState> {
  final Dio dio;

  PostBloc({required this.dio}) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<FetchComments>(_onFetchComments); // Register the handler for FetchComments
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final String? token = dotenv.env['API_KEY'];

    try {
      final response = await dio.get(
        'https://esgix.tech/posts?page=0&offset=-1',
        options: Options(
          headers: {
            'x-api-key': token,
            'Content-Type': 'application/json',
          },
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

  Future<void> _onFetchComments(FetchComments event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final String? token = dotenv.env['API_KEY'];

    try {
      final response = await dio.get(
        'https://esgix.tech/posts?parent=${event.postId}&page=0&offset=-1',
        options: Options(
          headers: {
            'x-api-key': token,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          final comments = data.map((json) => Post.fromJson(json)).toList();
          final currentState = state;
          if (currentState is PostLoaded) {
            final updatedPosts = List<Post>.from(currentState.posts)..addAll(comments);
            emit(PostLoaded(updatedPosts));
          } else {
            emit(PostLoaded(comments));
          }
        } else {
          emit(PostError('Data field is not a List.'));
        }
      } else {
        emit(PostError('Failed to fetch comments. Status code: ${response.statusCode}'));
      }
    } catch (error) {
      emit(PostError('Failed to fetch comments: $error'));
    }
  }
}