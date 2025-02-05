import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../create_post_screen/create_post_screen.dart';
import '../../feed_screen/feed_screen.dart';
import '../../login_screen/login_bloc/login_bloc.dart';
import '../../login_screen/login_screen.dart';
import '../../profile_screen/profile_post_screen.dart';
import '../../profile_screen/profile_screen.dart';
import '../../register_screen/register_bloc/register_bloc.dart';
import '../../register_screen/register_screen.dart';
import '../../post_comments_screen/post_comments_screen.dart';
import '../bloc/post_widget_bloc/post_widget_bloc.dart';
import '../models/user.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final isLoggedIn = await LoginBloc.isLoggedIn();
    final isLoginRoute = state.matchedLocation == '/login';
    final isRegisterRoute = state.matchedLocation == '/register';

    if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
      return '/login';
    }
    if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
      return '/feed';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => BlocProvider(
        create: (context) => RegisterBloc(),
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: '/feed',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/create-post',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/post/:postId/comments',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return BlocProvider(
          create: (context) => PostBloc(dio: Dio()),
          child: PostCommentsScreen(postId: postId),
        );
      },
    ),
    GoRoute(
      path: '/profile-post',
      builder: (context, state) {
        final user = state.extra as User;
        return ProfilePostScreen(user: user);
      },
    ),

  ],
);