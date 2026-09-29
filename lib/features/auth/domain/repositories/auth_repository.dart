import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../shared/entities/user_details_entity.dart';
import '../../../../shared/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserDetailsEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getCurrentUser();
}
