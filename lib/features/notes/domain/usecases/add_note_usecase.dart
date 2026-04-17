import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class AddNoteUseCase {
  final NotesRepository _repository;
  AddNoteUseCase(this._repository);

  Future<void> execute(NoteEntity note) {
    return _repository.addNote(note);
  }
}