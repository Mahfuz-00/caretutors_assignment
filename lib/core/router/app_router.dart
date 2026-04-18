import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/notes/domain/entities/note_entity.dart';
import '../../features/notes/presentation/screens/home_screen.dart';
import '../../features/notes/presentation/screens/add_note_screen.dart';
import '../../features/notes/presentation/screens/note_details_screen.dart';
import '../../features/splash/presentation/providers/splash_provider.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../di/providers.dart';

final splashFinishedProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isSplashFinished = ref.watch(splashFinishedProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      if (!isSplashFinished) {
        return '/splash';
      }

      final user = authState.valueOrNull;
      final bool isLoggedIn = user != null;

      final bool isAuthPath = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final bool isSplashing = state.matchedLocation == '/splash';

      if (isLoggedIn) {
        if (isAuthPath || isSplashing) return '/';
      } else {
        if (!isAuthPath) return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'add-note',
            builder: (context, state) => const AddNoteScreen(),
          ),

          GoRoute(
            path: '/note-details',
            builder: (context, state) {
              final note = state.extra as NoteEntity;
              return NoteDetailsScreen(note: note);
            },
          ),
        ],
      ),
    ],
  );
});