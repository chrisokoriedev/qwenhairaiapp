import 'package:flutter/material.dart';

class DisplayNameField extends StatelessWidget {
  const DisplayNameField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Display name',
        hintText: 'How should we address you?',
      ),
      textInputAction: TextInputAction.done,
    );
  }
}
