import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/di/providers.dart';


final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  AuthController(this._ref) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _ref.read(loginUseCaseProvider).execute(email, password);
    });
  }

  Future<void> register(String email, String password, String name) async {
    state = const AsyncLoading();
    try {
      final secondaryApp = await Firebase.initializeApp(
        name: 'secondary',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      await secondaryApp.delete();

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final auth = _ref.read(firebaseAuthProvider);

      final user = auth.currentUser;

      if (user != null) {
        print("✅ ${user.email} logged out");
        print("✅ ${user.displayName} logged out");
      } else {
        print("⚠️ No user was logged in");
      }

      await auth.signOut();
    });
  }
}