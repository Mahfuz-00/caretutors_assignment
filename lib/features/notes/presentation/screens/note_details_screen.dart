import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/service/background_wrapper.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_input_fields.dart';

class NoteDetailsScreen extends ConsumerStatefulWidget {
  final NoteEntity note;

  const NoteDetailsScreen({super.key, required this.note});

  @override
  ConsumerState<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends ConsumerState<NoteDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descController = TextEditingController(text: widget.note.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    await ref.read(notesControllerProvider.notifier).updateNote(
      widget.note,
      _titleController.text.trim(),
      _descController.text.trim(),
    );

    final state = ref.read(notesControllerProvider);
    if (!state.hasError) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final noteState = ref.watch(notesControllerProvider);
    final isLoading = noteState is AsyncLoading;

    return BaseBackground(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomAppBar(context, colorScheme, isLoading),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat('EEEE • MMM dd, yyyy').format(widget.note.createdAt).toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _isEditing
                          ? NoteTitleField(controller: _titleController)
                          : Hero(
                        tag: 'note-title-${widget.note.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              widget.note.title,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _isEditing ? SizedBox(height: 0): SizedBox(height: 28,),

                      _isEditing
                          ? NoteDescriptionField(controller: _descController)
                          : Text(
                        widget.note.description,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onSurface.withOpacity(0.8),
                          height: 1.7,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (isLoading) _buildLoadingOverlay(colorScheme),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, ColorScheme colorScheme, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 12, left: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_circle_rounded : Icons.edit_note_rounded,
              color: _isEditing ? Colors.greenAccent.shade700 : colorScheme.primary,
              size: 28,
            ),
            onPressed: isLoading
                ? null
                : () {
              if (_isEditing) {
                _handleSave();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(ColorScheme colorScheme) {
    return Container(
      color: Colors.black.withOpacity(0.1),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: const CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}