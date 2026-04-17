import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/data/sources/auth_remote_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';

import '../../features/notes/data/sources/notes_remote_source.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/domain/usecases/delete_note_usecase.dart';
import '../../features/notes/domain/usecases/get_notes_usecase.dart';
import '../../features/notes/domain/usecases/add_note_usecase.dart';
import '../../features/notes/domain/usecases/search_notes_usecase.dart';
import '../../features/notes/domain/usecases/update_note_usecase.dart';
import '../service/notification_service.dart';


// 1. External Sources
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instanceFor(
  app: Firebase.app(), // Uses the default Firebase app
  databaseId: 'note-curetutors', // Explicitly points to your Enterprise DB
));

// 2. Data Layer - Sources & Repositories
final authRemoteSourceProvider = Provider((ref) =>
    AuthRemoteSource(ref.watch(firebaseAuthProvider))
);

final authRepositoryProvider = Provider<AuthRepository>((ref) =>
    AuthRepositoryImpl(ref.watch(authRemoteSourceProvider))
);

// 3. Domain Layer - Use Cases
final loginUseCaseProvider = Provider((ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider))
);

final registerUseCaseProvider = Provider((ref) =>
    RegisterUseCase(ref.watch(authRepositoryProvider))
);


final notesRemoteSourceProvider = Provider((ref) =>
    NotesRemoteSource(ref.watch(firestoreProvider))
);

final notesRepositoryProvider = Provider<NotesRepository>((ref) =>
    NotesRepositoryImpl(ref.watch(notesRemoteSourceProvider))
);

final getNotesPaginatedUseCaseProvider = Provider((ref) =>
    GetNotesPaginatedUseCase(ref.watch(notesRepositoryProvider))
);

final searchNotesUseCaseProvider = Provider((ref) =>
    SearchNotesUseCase(ref.watch(notesRepositoryProvider))
);

final addNoteUseCaseProvider = Provider((ref) =>
    AddNoteUseCase(ref.watch(notesRepositoryProvider))
);

final deleteNoteUseCaseProvider = Provider((ref) =>
    DeleteNoteUseCase(ref.watch(notesRepositoryProvider))
);

final updateNoteUseCaseProvider = Provider((ref) =>
    UpdateNoteUseCase(ref.watch(notesRepositoryProvider))
);

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);