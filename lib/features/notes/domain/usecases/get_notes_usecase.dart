import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/notes_repository.dart';

class GetNotesPaginatedUseCase {
  final NotesRepository _repository;
  GetNotesPaginatedUseCase(this._repository);

  Future<QuerySnapshot> execute(String userId, {DocumentSnapshot? lastDoc}) {
    return _repository.getRawSnapshots(userId, lastDoc: lastDoc);
  }
}