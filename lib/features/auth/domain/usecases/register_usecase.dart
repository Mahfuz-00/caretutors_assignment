import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<UserEntity> execute(String email, String password, String name) {
    return _repository.signUp(email, password, name);
  }
}