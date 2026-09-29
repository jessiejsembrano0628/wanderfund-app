import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wanderfund_app/core/error/failure.dart';
import 'package:wanderfund_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wanderfund_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:wanderfund_app/features/auth/presentation/pages/register_page.dart';
import 'package:wanderfund_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:wanderfund_app/shared/entities/user_details_entity.dart';
import 'package:wanderfund_app/shared/entities/user_entity.dart';

void main() {
  testWidgets('submits a Philippine mobile number with the +63 prefix', (
    tester,
  ) async {
    final repository = await _pumpRegisterPage(tester);
    await _enterPersonalDetails(tester, '9123456789');

    final mobileDecoration = tester.widget<InputDecorator>(
      find.descendant(
        of: find.byType(TextFormField).at(2),
        matching: find.byType(InputDecorator),
      ),
    );
    expect(mobileDecoration.decoration.prefixText, '+63');
    expect(mobileDecoration.decoration.prefixIcon, isNull);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await _completeLoginDetails(tester, 'person@example.com');

    expect(repository.registerCalls, 1);
    expect(repository.registeredMobileNumber, '+639123456789');
  });

  for (final email in ['person@', 'person+trip@example.com']) {
    testWidgets('rejects invalid signup email: $email', (tester) async {
      final repository = await _pumpRegisterPage(tester);
      await _completePersonalDetails(tester, '9123456789');
      await _enterLoginDetails(tester, email);

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(repository.registerCalls, 0);
      expect(find.text('Enter a valid email'), findsOneWidget);
    });
  }

  for (final mobileNumber in ['912345678', '8123456789']) {
    testWidgets('rejects invalid Philippine mobile number: $mobileNumber', (
      tester,
    ) async {
      final repository = await _pumpRegisterPage(tester);
      await _enterPersonalDetails(tester, mobileNumber);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(repository.registerCalls, 0);
    });
  }

  testWidgets('limits Philippine mobile input to 10 digits', (tester) async {
    await _pumpRegisterPage(tester);
    final mobileField = find.byType(TextFormField).at(2);

    await tester.enterText(mobileField, '91234567890');

    expect(
      tester.widget<TextFormField>(mobileField).controller!.text,
      '9123456789',
    );
  });

  testWidgets('shows and clears mobile errors while editing', (tester) async {
    await _pumpRegisterPage(tester);
    final mobileField = find.byType(TextFormField).at(2);
    const errorText = 'Enter a valid Philippine mobile number';

    expect(find.text(errorText), findsNothing);

    await tester.enterText(mobileField, '9123');
    await tester.pump();

    expect(find.text(errorText), findsOneWidget);

    await tester.enterText(mobileField, '9123456789');
    await tester.pump();

    expect(find.text(errorText), findsNothing);
  });

  testWidgets('shows and clears email errors while editing', (tester) async {
    await _pumpRegisterPage(tester);
    await _completePersonalDetails(tester, '9123456789');
    final emailField = find.byType(TextFormField).at(0);

    expect(find.text('Enter a valid email'), findsNothing);

    await tester.enterText(emailField, 'person+trip@example.com');
    await tester.pump();

    expect(find.text('Enter a valid email'), findsOneWidget);

    await tester.enterText(emailField, 'person@example.com');
    await tester.pumpAndSettle();

    final emailWidget = tester.widget<TextFormField>(emailField);
    expect(emailWidget.controller!.text, 'person@example.com');
    expect(emailWidget.validator!(emailWidget.controller!.text), isNull);
    expect(find.text('Enter a valid email'), findsNothing);
  });
}

Future<_FakeAuthRepository> _pumpRegisterPage(WidgetTester tester) async {
  final repository = _FakeAuthRepository();
  final authProvider = AuthProvider(
    loginUsecase: LoginUsecase(repository: repository),
    registerUsecase: RegisterUsecase(repository: repository),
    logoutUsecase: LogoutUsecase(repository: repository),
    getCurrentUserUsecase: GetCurrentUserUsecase(repository: repository),
  );

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const MaterialApp(home: RegisterPage()),
    ),
  );

  return repository;
}

Future<void> _completePersonalDetails(
  WidgetTester tester,
  String mobileNumber,
) async {
  await _enterPersonalDetails(tester, mobileNumber);
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

Future<void> _enterPersonalDetails(
  WidgetTester tester,
  String mobileNumber,
) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'Taylor');
  await tester.enterText(find.byType(TextFormField).at(1), 'Wander');
  await tester.enterText(find.byType(TextFormField).at(2), mobileNumber);
}

Future<void> _completeLoginDetails(WidgetTester tester, String email) async {
  await _enterLoginDetails(tester, email);
  await tester.tap(find.text('Register'));
  await tester.pumpAndSettle();
}

Future<void> _enterLoginDetails(WidgetTester tester, String email) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), 'securePass123');
  await tester.enterText(find.byType(TextFormField).at(2), 'securePass123');
}

class _FakeAuthRepository implements AuthRepository {
  int registerCalls = 0;
  String? registeredMobileNumber;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async =>
      throw UnimplementedError();

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
  }) async {
    registerCalls++;
    registeredMobileNumber = mobileNumber;
    return const Left(ServerFailure());
  }

  @override
  Future<Either<Failure, void>> logout() async => throw UnimplementedError();
}
