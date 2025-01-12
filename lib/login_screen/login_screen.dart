import 'package:esgix/shared/widgets/text_user_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'login_bloc/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              double padding = constraints.maxWidth * 0.1;
              double elementWidthFactor =
                  constraints.maxWidth > 600 ? 0.5 : 0.8;
              return Column(
                children: [
                  const Flexible(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'ESGIX',
                        style: TextStyle(fontSize: 52, color: Colors.blue),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(padding),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextUserInput(
                              controller: _emailController,
                              elementWidthFactor: elementWidthFactor,
                              hintText: 'email',
                              prefixIcon: const Icon(Icons.person),
                              isPassword: false,
                            ),
                            TextUserInput(
                              controller: _passwordController,
                              elementWidthFactor: elementWidthFactor,
                              hintText: 'password',
                              prefixIcon: const Icon(Icons.key),
                              isPassword: true,
                            ),
                            FractionallySizedBox(
                              widthFactor: elementWidthFactor,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    final email = _emailController.text;
                                    final password = _passwordController.text;

                                    context
                                        .read<LoginBloc>()
                                        .add(ExecuteLogin(email, password));
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: elementWidthFactor,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: TextButton(
                                  onPressed: () {
                                    context.go('/register');
                                  },
                                  child: const Text(
                                    'Register',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
