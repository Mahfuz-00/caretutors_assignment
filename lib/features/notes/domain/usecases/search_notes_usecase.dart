import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

class SearchNotesUseCase {
  final NotesRepository _repository;
  SearchNotesUseCase(this._repository);

  Future<List<NoteEntity>> execute(String userId, String query) {
    return _repository.searchNotes(userId, query);
  }
}