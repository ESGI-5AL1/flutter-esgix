import 'package:esgix/shared/widgets/text_user_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'register_bloc/register_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RegisterBloc, RegisterState>(
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
                        'Register',
                        style: TextStyle(fontSize: 52, color: Colors.blue),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
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
                              prefixIcon: const Icon(Icons.email),
                              isPassword: false,
                            ),
                            TextUserInput(
                              controller: _passwordController,
                              elementWidthFactor: elementWidthFactor,
                              hintText: 'password',
                              prefixIcon: const Icon(Icons.key),
                              isPassword: true,
                            ),
                            TextUserInput(
                              controller: _usernameController,
                              elementWidthFactor: elementWidthFactor,
                              hintText: 'username',
                              prefixIcon: const Icon(Icons.person),
                              isPassword: false,
                            ),
                            TextUserInput(
                              controller: _avatarController,
                              elementWidthFactor: elementWidthFactor,
                              hintText: 'avatar URI',
                              prefixIcon: const Icon(Icons.image),
                              isPassword: false,
                            ),
                            FractionallySizedBox(
                              widthFactor: elementWidthFactor,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<RegisterBloc>().add(
                                          ExecuteRegister(
                                            _emailController.text,
                                            _passwordController.text,
                                            _usernameController.text,
                                            _avatarController.text,
                                          ),
                                        );
                                  },
                                  child: const Text(
                                    'Register',
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
                                    context.go('/login');
                                  },
                                  child: const Text(
                                    'Already have an account? Login',
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
