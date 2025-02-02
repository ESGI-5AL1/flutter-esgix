import 'package:dio/dio.dart';
import 'package:esgix/shared/bloc/post_widget_bloc/post_widget_bloc.dart';
import 'package:esgix/shared/bloc/user_bloc/user_bloc.dart';
import 'package:esgix/shared/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'login_screen/login_bloc/login_bloc.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => LoginBloc(userBloc: context.read<UserBloc>())),
        BlocProvider(create: (context) => PostBloc(dio: dio)),
      ],
      child: MaterialApp.router(
        title: 'ESGIX',
        routerConfig: router,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}