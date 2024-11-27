import 'package:flutter/material.dart';

class TextUserInput extends StatelessWidget {
  const TextUserInput({
    super.key,
    required this.controller,
    required this.elementWidthFactor,
    required this.hintText,
    required this.prefixIcon,
    required this.isPassword,
  });

  final TextEditingController controller;
  final double elementWidthFactor;
  final String hintText;
  final Icon prefixIcon;
  final bool isPassword;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: elementWidthFactor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: TextField(
          controller: controller,
          obscureText: isPassword == true ? true : false,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            border: const OutlineInputBorder(),
            focusColor: Colors.blue,
            hintText: hintText,

          ),
        ),
      ),
    );
  }
}
