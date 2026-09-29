import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/entities/user_details_entity.dart';
import '../../../../shared/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase({required this.repository});

  Future<Either<Failure, UserDetailsEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase({required this.repository});

  Future<Either<Failure, void>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  }) {
    return repository.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
    );
  }
}

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase({required this.repository});

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase({required this.repository});

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
