import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_curetutors/features/notes/data/models/note_model.dart';

class NotesRemoteSource {
  final FirebaseFirestore _firestore;
  NotesRemoteSource(this._firestore);

  Future<QuerySnapshot> getNotesPaginated(String userId, {DocumentSnapshot? lastDoc, int limit = 10}) async {
    Query query = _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return await query.get();
  }

  Future<QuerySnapshot> searchNotes(String userId, String queryText) async {
    final normalizedQuery = queryText.toLowerCase();

    return await _firestore
        .collection('notes')
        .where('userId', isEqualTo: userId)
        .where('titleLowerCase', isGreaterThanOrEqualTo: normalizedQuery)
        .where('titleLowerCase', isLessThanOrEqualTo: '$normalizedQuery\uf8ff')
        .limit(20)
        .get();
  }

  Future<void> addNote(Map<String, dynamic> noteData) {
    return _firestore.collection('notes').add(noteData);
  }

  Future<void> deleteNote(String noteId) {
    return _firestore.collection('notes').doc(noteId).delete();
  }


  Future<void> updateNote(Map<String, dynamic> noteData, String noteId) {
    return _firestore.collection('notes').doc(noteId).update(noteData);
  }
}