import 'package:esgix/shared/datasources/user_data_source/user_remote_data_source.dart';
import 'package:esgix/shared/repositories/posts_repository/posts_repository.dart';
import 'package:esgix/shared/repositories/user_repository/user_repository.dart';
import 'package:esgix/shared/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import 'login_screen/login_bloc/login_bloc.dart';
import 'shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import 'shared/bloc/user_bloc/user_bloc.dart';
import 'shared/datasources/posts_data_source/posts_remote_data_source.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final postDataSource = PostRemoteDataSource(dio: dio);
    final postRepository = PostRepository(remoteDataSource: postDataSource);
    final userDataSource = UserRemoteDataSource(dio: dio);
    final userRepository = UserRepository(remoteDataSource: userDataSource);

    return MultiProvider(
      providers: [
        Provider<PostRepository>(
          create: (context) => postRepository,
        ),
        Provider<UserRepository>(
          create: (context) => userRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoginBloc(),
          ),
          BlocProvider(
            create: (context) => PostBloc(
              repository: context.read<PostRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => UserBloc(
              repository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'ESGIX',
          routerConfig: router,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        ),
      ),
    );
  }
}