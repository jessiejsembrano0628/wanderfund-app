import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../shared/entities/user_entity.dart';
import '../../../../shared/entities/user_details_entity.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, UserDetailsEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginResponse = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await tokenStorage.saveToken(loginResponse.accessToken);
      return Right(
        loginResponse.userDetails.toEntity(userId: loginResponse.userId),
      );
    } on AuthenticationException catch (e) {
      await tokenStorage.deleteToken();
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  }) async {
    try {
      await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        mobileNumber: mobileNumber,
      );
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final token = tokenStorage.getToken();
    try {
      if (token == null || token.isEmpty) {
        await tokenStorage.deleteToken();
        return const Right(null);
      }
      await remoteDataSource.logout(token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    } finally {
      await tokenStorage.deleteToken();
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final token = tokenStorage.getToken();
      if (token == null) {
        return Left(AuthenticationFailure(message: 'No token found'));
      }
      final userModel = await remoteDataSource.getCurrentUser(token);
      return Right(userModel.toEntity());
    } on AuthenticationException catch (e) {
      await tokenStorage.deleteToken();
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
