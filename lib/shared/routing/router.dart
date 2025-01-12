import 'package:esgix/login_screen/login_screen.dart';
import 'package:esgix/register_screen/register_bloc/register_bloc.dart';
import 'package:esgix/register_screen/register_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


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
  ],
);