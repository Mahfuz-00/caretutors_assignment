import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/note_entity.dart';

abstract class NotesRepository {
  Future<List<NoteEntity>> getNotesPaginated(String userId, {DocumentSnapshot? lastDoc});
  Future<QuerySnapshot> getRawSnapshots(String userId, {DocumentSnapshot? lastDoc});
  Future<List<NoteEntity>> searchNotes(String userId, String query);
  Future<void> addNote(NoteEntity note);
  Future<void> deleteNote(String noteId);
  Future<void> updateNote(NoteEntity note);
}