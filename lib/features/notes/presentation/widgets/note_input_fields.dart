import 'package:flutter/material.dart';

class NoteTitleField extends StatelessWidget {
  final TextEditingController controller;
  const NoteTitleField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        hintText: "Title",
        border: InputBorder.none,
      ),
    );
  }
}

class NoteDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const NoteDescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: const TextStyle(fontSize: 18),
      decoration: const InputDecoration(
        hintText: "Description",
        border: InputBorder.none,
      ),
    );
  }
}