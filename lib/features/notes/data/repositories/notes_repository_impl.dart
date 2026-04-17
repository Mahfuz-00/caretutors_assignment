import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';
import '../sources/notes_remote_source.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteSource _remoteSource;

  NotesRepositoryImpl(this._remoteSource);

  @override
  Future<List<NoteEntity>> getNotesPaginated(String userId, {DocumentSnapshot? lastDoc}) async {
    final snapshot = await _remoteSource.getNotesPaginated(userId, lastDoc: lastDoc);
    return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }

  @override
  Future<QuerySnapshot> getRawSnapshots(String userId, {DocumentSnapshot? lastDoc}) {
    return _remoteSource.getNotesPaginated(userId, lastDoc: lastDoc);
  }

  @override
  Future<List<NoteEntity>> searchNotes(String userId, String query) async {
    final snapshot = await _remoteSource.searchNotes(userId, query);
    return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addNote(NoteEntity note) {
    final model = NoteModel(
      id: note.id,
      title: note.title,
      description: note.description,
      createdAt: note.createdAt,
      modifiedAt: note.createdAt,
      userId: note.userId,
    );
    return _remoteSource.addNote(model.toFirestore());
  }

  @override
  Future<void> deleteNote(String noteId) => _remoteSource.deleteNote(noteId);

  @override
  Future<void> updateNote(NoteEntity note) {
    final model = NoteModel(
      id: note.id,
      title: note.title,
      description: note.description,
      createdAt: note.createdAt,
      modifiedAt: note.modifiedAt,
      userId: note.userId,
    );
    return _remoteSource.updateNote(model.toFirestore(), note.id);
  }
}