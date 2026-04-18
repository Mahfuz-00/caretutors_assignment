import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/di/providers.dart';
import '../../../splash/presentation/providers/splash_provider.dart';
import '../../domain/entities/note_entity.dart';
import '../../data/models/note_model.dart';

// --- SEARCH STATE ---

/// Holds the current search string from the TextField
final noteSearchProvider = StateProvider<String>((ref) => "");

final searchResultsProvider = FutureProvider.autoDispose<List<NoteEntity>>((ref) async {
  final query = ref.watch(noteSearchProvider);
  final user = ref.watch(authStateProvider).value;

  if (query.isEmpty || user == null) return [];

  await Future.delayed(const Duration(milliseconds: 500));

  return ref.read(searchNotesUseCaseProvider).execute(user.id, query);
});


// --- PAGINATION STATE ---

class NotesState {
  final List<NoteEntity> notes;
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasMore;
  final DocumentSnapshot? lastDoc;

  NotesState({
    required this.notes,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.hasMore = true,
    this.lastDoc,
  });

  NotesState copyWith({
    List<NoteEntity>? notes,
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDoc: lastDoc ?? this.lastDoc,
    );
  }
}

final paginatedNotesProvider = StateNotifierProvider<NotesListNotifier, NotesState>((ref) {
  return NotesListNotifier(ref);
});

class NotesListNotifier extends StateNotifier<NotesState> {
  final Ref _ref;
  NotesListNotifier(this._ref) : super(NotesState(notes: [], isLoading: true)) {
    _listenToAuthChanges();
    fetchInitial();
  }

  void _listenToAuthChanges() {
    _ref.listen(authStateProvider, (previous, next) {
      if (previous?.value?.id != next?.value?.id) {
        clearAndRefresh();
      }
    });
  }

  Future<void> fetchInitial() async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) {
      state = state.copyWith(notes: [], isLoading: false);
      return;
    }

    try {
      final snapshot = await _ref.read(getNotesPaginatedUseCaseProvider).execute(user.id);
      final notes = snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();

      state = state.copyWith(
        notes: notes,
        isLoading: false,
        lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: notes.length == 10,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearAndRefresh() {
    state = NotesState(notes: [], isLoading: true);
    fetchInitial();
  }

  Future<void> fetchMore() async {
    if (state.isFetchingMore || !state.hasMore) return;
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    state = state.copyWith(isFetchingMore: true);

    try {
      final snapshot = await _ref.read(getNotesPaginatedUseCaseProvider).execute(
          user.id,
          lastDoc: state.lastDoc
      );
      final newNotes = snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();

      state = state.copyWith(
        notes: [...state.notes, ...newNotes],
        isFetchingMore: false,
        lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : state.lastDoc,
        hasMore: newNotes.length == 10,
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false);
    }
  }

  void refresh() => fetchInitial();
}


// --- CRUD ACTIONS CONTROLLER ---

final notesControllerProvider = StateNotifierProvider<NotesController, AsyncValue<void>>((ref) {
  return NotesController(ref);
});

class NotesController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  NotesController(this._ref) : super(const AsyncData(null));

  Future<void> addNote(String title, String description) async {
    final user = _ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newNote = NoteEntity(
        id: '',
        title: title,
        description: description,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        userId: user.id,
      );

      await _ref.read(addNoteUseCaseProvider).execute(newNote);

      _sendLocalNotification(
        title: "Insight Saved!",
        body: "Successfully added: $title",
      );

      _ref.read(paginatedNotesProvider.notifier).refresh();
    });
  }

  void _sendLocalNotification({required String title, required String body}) {
    final notificationService = _ref.read(notificationServiceProvider);
    notificationService.showInstantNotification(
      title: title,
      body: body,
    );
  }

  Future<void> deleteNote(String noteId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _ref.read(deleteNoteUseCaseProvider).execute(noteId);
      _ref.read(paginatedNotesProvider.notifier).refresh();
    });
  }

  Future<void> updateNote(NoteEntity note, String title, String description) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedNote = note.copyWith(title: title, description: description, modifiedAt: DateTime.now());
      await _ref.read(updateNoteUseCaseProvider).execute(updatedNote);

      _sendLocalNotification(
        title: "Insight Updated!",
        body: "Changes to $title have been saved.",
      );

      _ref.read(paginatedNotesProvider.notifier).refresh();
    });
  }
}