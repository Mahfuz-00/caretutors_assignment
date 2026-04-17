import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NoteCardPlaceholder extends StatelessWidget {
  const NoteCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 100, height: 20, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 14, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Container(width: 140, height: 14, color: Colors.grey.shade200),
            const Spacer(),
            Container(width: 60, height: 12, color: Colors.grey.shade100),
          ],
        ),
      ),
    );
  }
}