import '../repositories/notes_repository.dart';

class DeleteNoteUseCase {
  final NotesRepository _repository;
  DeleteNoteUseCase(this._repository);

  Future<void> execute(String noteId) {
    return _repository.deleteNote(noteId);
  }
}