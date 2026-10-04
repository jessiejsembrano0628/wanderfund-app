import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wanderfund_app/core/error/failure.dart';
import 'package:wanderfund_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wanderfund_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:wanderfund_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:wanderfund_app/features/profile/presentation/pages/profile_page.dart';
import 'package:wanderfund_app/shared/entities/user_details_entity.dart';
import 'package:wanderfund_app/shared/entities/user_entity.dart';

void main() {
  testWidgets('shows restored account details once in one panel', (
    tester,
  ) async {
    final authProvider = _createAuthProvider(
      _FakeAuthRepository(
        currentUser: UserEntity(
          id: 'restored-user',
          email: 'user@example.com',
          name: 'Restored User',
          mobileNumber: '555-0100',
          createdAt: DateTime(2025, 1, 2),
        ),
      ),
    );
    addTearDown(authProvider.dispose);
    await authProvider.initialize();

    await _pumpProfile(tester, authProvider);

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Restored User'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('Mobile number'), findsOneWidget);
    expect(find.text('555-0100'), findsOneWidget);
    expect(find.text('Member since'), findsOneWidget);
    expect(find.text('2025-01-02'), findsOneWidget);
  });

  testWidgets('shows unavailable when a restored user has no phone number', (
    tester,
  ) async {
    final authProvider = _createAuthProvider(
      _FakeAuthRepository(
        currentUser: UserEntity(
          id: 'restored-user',
          email: 'user@example.com',
          name: 'Restored User',
          createdAt: DateTime(2025, 1, 2),
        ),
      ),
    );
    addTearDown(authProvider.dispose);
    await authProvider.initialize();

    await _pumpProfile(tester, authProvider);

    expect(find.text('Not available'), findsOneWidget);
  });

  testWidgets('shows login details including the current phone number', (
    tester,
  ) async {
    final authProvider = _createAuthProvider(
      _FakeAuthRepository(
        loginUser: const UserDetailsEntity(
          userId: 'user-1',
          firstName: 'Ada',
          lastName: 'Lovelace',
          email: 'ada@example.com',
          mobileNumber: '555-0100',
        ),
      ),
    );
    addTearDown(authProvider.dispose);
    await authProvider.login(email: 'ada@example.com', password: 'password');

    await _pumpProfile(tester, authProvider);

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.text('555-0100'), findsOneWidget);
    expect(find.text('Member since'), findsNothing);
  });
}

AuthProvider _createAuthProvider(AuthRepository repository) {
  return AuthProvider(
    loginUsecase: LoginUsecase(repository: repository),
    registerUsecase: RegisterUsecase(repository: repository),
    logoutUsecase: LogoutUsecase(repository: repository),
    getCurrentUserUsecase: GetCurrentUserUsecase(repository: repository),
  );
}

Future<void> _pumpProfile(WidgetTester tester, AuthProvider authProvider) {
  return tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const MaterialApp(home: ProfilePage()),
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  final UserEntity? currentUser;
  final UserDetailsEntity? loginUser;

  _FakeAuthRepository({this.currentUser, this.loginUser});

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async =>
      Right(currentUser!);

  @override
  Future<Either<Failure, UserDetailsEntity>> login({
    required String email,
    required String password,
  }) async =>
      Right(loginUser!);

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);
}