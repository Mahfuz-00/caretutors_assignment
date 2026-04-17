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
      await _ref.read(registerUseCaseProvider).execute(email, password, name);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}