import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String username = "";
  late String password = "";

  void _log() {
    setState(() {
      print(username);
      print(password);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {

          double padding = constraints.maxWidth * 0.1;
          double elementWidthFactor = constraints.maxWidth > 600 ? 0.5 : 0.8;

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
                        FractionallySizedBox(
                          widthFactor: elementWidthFactor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextField(
                              onChanged: (value) => username = value,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                ),
                                border: OutlineInputBorder(),
                                focusColor: Colors.blue,
                                hintText: 'username',
                              ),
                            ),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: elementWidthFactor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextField(
                              onChanged: (value) => password = value,
                              obscureText: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.key),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                ),
                                border: OutlineInputBorder(),
                                hintText: 'password',
                              ),
                            ),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: elementWidthFactor,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ElevatedButton(
                              onPressed: _log,
                              child: const Text('Login'),
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
                child: Container(
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
