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
    on<UpdateLikeStatus>(_onUpdateLikeStatus);
    on<FetchComments>(_onFetchComments);
    on<FetchPostById>(_onFetchPostById);
    on<SearchPosts>(_onSearchPosts);
    on<UpdatePost>(_onUpdatePost);
    on<FetchUserPosts>(_onFetchUserPosts);
    on<FetchUserLikes>(_onFetchUserLikes);
    on<LikePost>(_onLikePost);
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
        'https://esgix.tech/posts?page=0&offset=-1',
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

  Future<void> _onLikePost(LikePost event, Emitter<PostState> emit) async {
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await _getAuthToken();

    if (state is! PostLoaded) return;
    final currentState = state as PostLoaded;

    try {
      final response = await dio.post(
        'https://esgix.tech/likes/${event.postId}',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mise à jour optimiste du state
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
      } else {
        emit(PostError('Failed to like post'));
        emit(currentState); // Retour à l'état précédent en cas d'erreur
      }
    } catch (error) {
      emit(PostError('Failed to like post: $error'));
      emit(currentState); // Retour à l'état précédent en cas d'erreur
    }
  }

  Future<void> _onFetchUserPosts(FetchUserPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await _getAuthToken();

    var request = 'https://esgix.tech/user/${event.userId}/posts?page=0&offset=-1';

    print("REQUEST + " + request);

    try {
      final response = await dio.get(
    request,
        options: Options(
            headers: {
              'x-api-key': apiKey,
              'Authorization': authToken != null ? 'Bearer $authToken' : null,
              'Content-Type': 'application/json',
            }
        ),
      );

      print(response);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          final posts = data.map((json) => Post.fromJson(json)).toList();
          emit(PostLoaded(posts));
        } else {
          emit(PostError('Data field is not a List.'));
        }
      } else {
        emit(PostError('Failed to fetch user posts. Status code: ${response.statusCode}'));
      }
    } catch (error) {
      emit(PostError('Failed to fetch user posts: $error'));
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
      final Map<String, dynamic> requestBody = {
        'content': event.content,
      };

      if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
        requestBody['imageUrl'] = event.imageUrl;
      }

      final response = await dio.post(
        'https://esgix.tech/posts',
        data: requestBody,
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Rafraîchir la liste des posts après la création
        add(FetchPosts());
      } else {
        emit(PostError('Failed to create post. Status code: ${response.statusCode}'));
      }
    } catch (error) {
      print('Create post error: $error');
      // Continuer même si on a une erreur de type puisque le post est créé
      add(FetchPosts());
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await LoginBloc.getToken();

    if (authToken == null) {
      emit(PostError('Authentication required'));
      return;
    }

    try {
      final response = await dio.put(
        'https://esgix.tech/posts/${event.postId}',
        data: {
          'content': event.content,
          if (event.imageUrl != null) 'imageUrl': event.imageUrl,
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
        if (state is PostLoaded) {
          final currentState = state as PostLoaded;
          final updatedPosts = currentState.posts.map((post) {
            if (post.id == event.postId) {
              return post.copyWith(
                content: event.content,
                imageUrl: event.imageUrl ?? post.imageUrl,
              );
            }
            return post;
          }).toList();
          emit(PostLoaded(updatedPosts));
        }
      } else {
        emit(PostError('Failed to update post'));
      }
    } catch (error) {
      emit(PostError('Failed to update post: $error'));
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

  Future<void> _onFetchUserLikes(FetchUserLikes event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await _getAuthToken();

    var request = 'https://esgix.tech/user/${event.userId}/likes?page=0&offset=10';
    print("REQUEST LIKE " + request);
    try {
      print('Fetching likes for user: ${event.userId}');

      final response = await dio.get(
        request,
        options: Options(
            headers: {
              'x-api-key': apiKey,
              'Authorization': authToken != null ? 'Bearer $authToken' : null,
              'Content-Type': 'application/json',
            }
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          final posts = data.map((json) {
            // On crée le post avec likedByUser forcé à true puisque c'est un post liké
            final post = Post.fromJson(json);
            return post.copyWith(likedByUser: true);
          }).toList();
          print('Parsed posts count: ${posts.length}');
          emit(PostLoaded(posts));
        } else {
          print('Data is not a List: $data');
          emit(PostError('Data field is not a List.'));
        }
      } else {
        emit(PostError('Failed to fetch liked posts. Status code: ${response.statusCode}'));
      }
    } catch (error) {
      print('Error fetching likes: $error');
      emit(PostError('Failed to fetch liked posts: $error'));
    }
  }


  Future<void> _onFetchComments(FetchComments event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await _getAuthToken();

    try {
      final response = await dio.get(
        'https://esgix.tech/posts?parent=${event.postId}&page=0&offset=-1',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': authToken != null ? 'Bearer $authToken' : null,
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

  Future<void> _onFetchPostById(FetchPostById event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final String? apiKey = dotenv.env['API_KEY'];
    final String? authToken = await _getAuthToken();

    try {
      final response = await dio.get(
        'https://esgix.tech/posts/${event.postId}',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Authorization': authToken != null ? 'Bearer $authToken' : null,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          final post = Post.fromJson(data);
          emit(PostLoaded([post]));
        } else {
          emit(PostError('Data field is null.'));
        }
      } else {
        emit(PostError('Failed to fetch post. Status code: ${response.statusCode}'));
      }
    } catch (error) {
      emit(PostError('Failed to fetch post: $error'));
    }
  }
  Future<void> _onSearchPosts(SearchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    final String? apiKey = dotenv.env['API_KEY'];

    try {
      final response = await dio.get(
        'https://esgix.tech/search',
        queryParameters: {
          'query': event.query,
        },
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> searchResults = response.data['data'];
        final posts = searchResults.map((json) {
          return Post.fromJson(json as Map<String, dynamic>);
        }).toList();

        emit(PostLoaded(posts));
      } else {
        emit(PostError('Failed to search posts. Status code: ${response.statusCode}'));
      }
    } catch (error) {

      emit(PostError('Failed to search posts: $error'));
    }
  }

}



