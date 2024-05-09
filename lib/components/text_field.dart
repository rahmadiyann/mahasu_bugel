import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final bool enabled;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool number;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      required this.enabled,
      this.number = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: number ? TextInputType.number : null,
      enabled: enabled,
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
