import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_event.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../login_screen/login_bloc/login_bloc.dart';
import '../../models/post.dart';
import '../../repositories/posts_repository/posts_repository.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repository;

  PostBloc({required this.repository}) : super(PostInitial()) {
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
    on<CreateComment>(_onCreateComment);
    on<LoadProfileData>(_onLoadProfileData);
    on<SyncLikeStatus>(_onSyncLikeStatus);
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final posts = await repository.getPosts();
      final userId = await LoginBloc.getUserId();
      if (userId != null) {
        final userLikes = await repository.getUserLikes(userId);
        final likedPostIds = userLikes.map((post) => post.id).toSet();

        final updatedPosts = posts.map((post) {
          return post.copyWith(
            likedByUser: likedPostIds.contains(post.id),
          );
        }).toList();

        emit(PostLoaded(updatedPosts));
      } else {
        emit(PostLoaded(posts));
      }
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> _onFetchUserPosts(FetchUserPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final posts = await repository.getUserPosts(event.userId);
      emit(PostLoaded(posts));
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> _onSyncLikeStatus(SyncLikeStatus event, Emitter<PostState> emit) async {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(likedByUser: event.isLiked);
        }
        return post;
      }).toList();
      emit(PostLoaded(updatedPosts));
    }
  }

  Future<void> _onFetchUserLikes(FetchUserLikes event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final posts = await repository.getUserLikes(event.userId);
      final updatedPosts = posts.map((post) => post.copyWith(likedByUser: true)).toList();
      emit(PostLoaded(updatedPosts));
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostState> emit) async {
    try {
      await repository.createPost(event.content, event.imageUrl);
      add(FetchPosts());
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    try {
      final updatedPost = await repository.updatePost(
        event.postId,
        event.content,
        event.imageUrl,
      );

      if (updatedPost == null) {
        return;
      }

      if (state is PostLoaded) {
        final currentState = state as PostLoaded;
        final updatedPosts = currentState.posts.map((post) {
          return post.id == event.postId ? updatedPost : post;
        }).toList();

        emit(PostLoaded(updatedPosts));
      }
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }


  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    try {
      await repository.deletePost(event.postId);

      if (state is PostLoaded) {
        final currentState = state as PostLoaded;
        final updatedPosts = currentState.posts
            .where((post) => post.id != event.postId)
            .toList();
        emit(PostLoaded(updatedPosts));
      }

      add(FetchPosts());
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> _onLikePost(LikePost event, Emitter<PostState> emit) async {
    if (state is! PostLoaded) return;
    final currentState = state as PostLoaded;

    try {
      await repository.likePost(event.postId);

      // Mettre à jour tous les posts qui ont le même ID
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

      // Émettre un événement pour mettre à jour les autres vues
      add(SyncLikeStatus(event.postId, !currentState.posts.firstWhere((p) => p.id == event.postId).likedByUser));
    } catch (error) {
      emit(PostError(error.toString()));
      emit(currentState);
    }
  }

  void _onAddNewPost(AddNewPost event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      emit(PostLoaded([event.post, ...currentState.posts]));
    }
  }

  Future<void> _onFetchComments(FetchComments event, Emitter<PostState> emit) async {
    try {
      final comments = await repository.getComments(event.postId);
      if (state is PostLoaded) {
        final currentState = state as PostLoaded;
        final updatedPosts = List<Post>.from(currentState.posts)..addAll(comments);
        emit(PostLoaded(updatedPosts));
      } else {
        emit(PostLoaded(comments));
      }
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> _onFetchPostById(FetchPostById event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final post = await repository.getPostById(event.postId);
      emit(PostLoaded([post]));
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> _onSearchPosts(SearchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final posts = await repository.searchPosts(event.query);
      emit(PostLoaded(posts));
    } catch (error) {
      emit(PostError(error.toString()));
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

  Future<void> _onCreateComment(CreateComment event, Emitter<PostState> emit) async {
    try {
      final comment = await repository.createPost(
          event.content,
          null,
          parent: event.parentId
      );

      if (comment != null && state is PostLoaded) {
        final currentState = state as PostLoaded;
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.parentId) {
            return post.copyWith(
              commentsCount: post.commentsCount + 1,
            );
          }
          return post;
        }).toList();

        if (currentState.posts.any((post) => post.parent == event.parentId)) {
          updatedPosts.add(comment);
        }

        emit(PostLoaded(updatedPosts));
      }
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> _onLoadProfileData(LoadProfileData event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final posts = event.loadLikes
          ? await repository.getUserLikes(event.userId)
          : await repository.getUserPosts(event.userId);
      emit(PostLoaded(posts));
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

}



