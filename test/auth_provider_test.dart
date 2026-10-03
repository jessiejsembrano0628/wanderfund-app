import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanderfund_app/core/constants/app_constants.dart';
import 'package:wanderfund_app/core/error/exceptions.dart';
import 'package:wanderfund_app/core/error/failure.dart';
import 'package:wanderfund_app/core/services/token_storage.dart';
import 'package:wanderfund_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wanderfund_app/features/auth/data/models/login_response.dart';
import 'package:wanderfund_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wanderfund_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wanderfund_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:wanderfund_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:wanderfund_app/shared/entities/user_details_entity.dart';
import 'package:wanderfund_app/shared/entities/user_entity.dart';
import 'package:wanderfund_app/shared/models/user_model.dart';

void main() {
  group('AuthProvider.initialize', () {
    test('allows retry after a recoverable failure', () async {
      final repository = _FakeAuthRepository(
        currentUserResult: const Left(NetworkFailure(message: 'Offline')),
      );
      final provider = _createProvider(repository);

      await provider.initialize();

      expect(provider.isInitialized, isTrue);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.canRetryInitialization, isTrue);
      expect(provider.errorMessage, 'Offline');

      repository.currentUserResult = Right(_user);
      await provider.initialize();

      expect(provider.isAuthenticated, isTrue);
      expect(provider.user, _user);
      expect(provider.canRetryInitialization, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('treats a missing token as a signed-out session', () async {
      final repository = _FakeAuthRepository(
        currentUserResult: const Left(
          AuthenticationFailure(message: 'No token found'),
        ),
      );
      final provider = _createProvider(repository);

      await provider.initialize();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.canRetryInitialization, isFalse);
      expect(provider.errorMessage, isNull);
    });

    for (final statusCode in ['404', '504']) {
      test('shows the login state for server $statusCode', () async {
        final repository = _FakeAuthRepository(
          currentUserResult: Left(
            ServerFailure(message: 'Server error', code: statusCode),
          ),
        );
        final provider = _createProvider(repository);

        await provider.initialize();

        expect(provider.isAuthenticated, isFalse);
        expect(provider.canRetryInitialization, isFalse);
        expect(provider.errorMessage, isNull);
      });
    }

    test('allows retry after other server failures', () async {
      final repository = _FakeAuthRepository(
        currentUserResult: const Left(
          ServerFailure(message: 'Internal server error', code: '500'),
        ),
      );
      final provider = _createProvider(repository);

      await provider.initialize();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.canRetryInitialization, isTrue);
      expect(provider.errorMessage, 'Internal server error');
    });
  });

  group('AuthRepositoryImpl.getCurrentUser token handling', () {
    test('retains the token when the API is temporarily unavailable', () async {
      final repository = await _createRepository(
        currentUserException: NetworkException(message: 'Offline'),
      );

      final result = await repository.repository.getCurrentUser();

      expect(result.isLeft(), isTrue);
      expect(repository.tokenStorage.getToken(), 'saved-token');
    });

    test('clears the token when the API rejects it', () async {
      final repository = await _createRepository(
        currentUserException: AuthenticationException(message: 'Unauthorized'),
      );

      final result = await repository.repository.getCurrentUser();

      expect(result.isLeft(), isTrue);
      expect(repository.tokenStorage.getToken(), isNull);
    });

    for (final statusCode in ['404', '504']) {
      test('preserves server status $statusCode without clearing token', () async {
        final repository = await _createRepository(
          currentUserException: ServerException(
            message: 'Server error',
            code: statusCode,
          ),
        );

        final result = await repository.repository.getCurrentUser();
        final failure = result.fold<Failure?>(
          (failure) => failure,
          (_) => null,
        );

        expect(
          failure,
          isA<ServerFailure>().having(
            (failure) => failure.code,
            'code',
            statusCode,
          ),
        );
        expect(repository.tokenStorage.getToken(), 'saved-token');
      });
    }
  });
}

final _user = UserEntity(
  id: 'user-123',
  email: 'user@example.com',
  name: 'Wander User',
  createdAt: DateTime.utc(2025),
);

AuthProvider _createProvider(_FakeAuthRepository repository) {
  return AuthProvider(
    loginUsecase: LoginUsecase(repository: repository),
    registerUsecase: RegisterUsecase(repository: repository),
    logoutUsecase: LogoutUsecase(repository: repository),
    getCurrentUserUsecase: GetCurrentUserUsecase(repository: repository),
  );
}

class _FakeAuthRepository implements AuthRepository {
  Either<Failure, UserEntity> currentUserResult;

  _FakeAuthRepository({required this.currentUserResult});

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async =>
      currentUserResult;

  @override
  Future<Either<Failure, UserDetailsEntity>> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() async => throw UnimplementedError();
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  final Exception currentUserException;

  _FakeAuthRemoteDataSource(this.currentUserException);

  @override
  Future<UserModel> getCurrentUser(String token) async {
    throw currentUserException;
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> logout(String token) async => throw UnimplementedError();

  @override
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  }) async => throw UnimplementedError();
}

Future<({AuthRepositoryImpl repository, TokenStorage tokenStorage})>
_createRepository({required Exception currentUserException}) async {
  SharedPreferences.setMockInitialValues({
    AppConstants.tokenKey: 'saved-token',
  });
  final preferences = await SharedPreferences.getInstance();
  final tokenStorage = TokenStorage(preferences);
  final repository = AuthRepositoryImpl(
    remoteDataSource: _FakeAuthRemoteDataSource(currentUserException),
    tokenStorage: tokenStorage,
  );
  return (repository: repository, tokenStorage: tokenStorage);
}
