import 'package:dio/dio.dart';
import 'package:esgix/login_screen/login_screen.dart';
import 'package:esgix/register_screen/register_bloc/register_bloc.dart';
import 'package:esgix/register_screen/register_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../feed_screen/feed_screen.dart';
import '../bloc/post_widget_bloc/post_widget_bloc.dart';

final router = GoRouter(
  initialLocation: '/login',
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
      builder: (context, state) => BlocProvider(
        create: (context) => PostBloc(dio: Dio()),
        child: const FeedScreen(),
      ),
    ),
  ],
);