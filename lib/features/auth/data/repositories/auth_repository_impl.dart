import '../models/user_model.dart';
import '../sources/auth_remote_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _remoteSource;
  AuthRepositoryImpl(this._remoteSource);

  @override
  Stream<UserEntity?> get authStateChanges => _remoteSource.authStateChanges.map(
        (user) => user != null ? UserModel.fromFirebase(user) : null,
  );

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final credential = await _remoteSource.signIn(email, password);
    return UserModel.fromFirebase(credential.user!);
  }

  @override
  Future<UserEntity> signUp(String email, String password, String name) async {
    final credential = await _remoteSource.signUp(email, password);
    await _remoteSource.updateDisplayName(name);
    return UserModel.fromFirebase(credential.user!);
  }

  @override
  Future<void> signOut() => _remoteSource.signOut();
}