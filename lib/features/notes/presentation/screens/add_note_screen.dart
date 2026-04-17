import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/service/background_wrapper.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_input_fields.dart';

class AddNoteScreen extends HookConsumerWidget {
  const AddNoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final descController = useTextEditingController();
    final state = ref.watch(notesControllerProvider);

    ref.listen<AsyncValue>(notesControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          if (prev is AsyncLoading) {
            context.pop();
          }
        },
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: $err"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: BaseBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFFF8F9FE),
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.black87),
                onPressed: () => context.pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: titleController,
                    builder: (context, value, _) {
                      final bool isLoading = state.isLoading;

                      return TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          ref.read(notesControllerProvider.notifier).addNote(
                            titleController.text.trim(),
                            descController.text.trim(),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isLoading
                              ? Colors.grey.shade300
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isLoading
                              ? const SizedBox(
                            key: ValueKey('loading'),
                            height: 18, width: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text(
                            "Save",
                            key: ValueKey('text'),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    NoteTitleField(controller: titleController),
                    NoteDescriptionField(controller: descController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}