import 'package:flutter/material.dart';

class NoteTitleField extends StatelessWidget {
  final TextEditingController controller;
  const NoteTitleField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black54),
      decoration: InputDecoration(
        hintText: "Title",
        hintStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black54),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
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
      style: const TextStyle(fontSize: 18, color: Colors.black54),
      decoration: InputDecoration(
        hintText: "Description",
        hintStyle: const TextStyle(fontSize: 18, color: Colors.black54),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}