import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wanderfund_app/core/error/failure.dart';
import 'package:wanderfund_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wanderfund_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:wanderfund_app/features/auth/presentation/pages/login_page.dart';
import 'package:wanderfund_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:wanderfund_app/features/landing/presentation/pages/landing_page.dart';
import 'package:wanderfund_app/shared/entities/user_details_entity.dart';
import 'package:wanderfund_app/shared/entities/user_entity.dart';

void main() {
  testWidgets('shows brochure copy and the three product screenshots', (
    tester,
  ) async {
    final authProvider = _createAuthProvider();
    addTearDown(authProvider.dispose);
    await authProvider.initialize();

    await _pumpLanding(tester, authProvider);

    expect(
      find.text('Group Travel Expenses, Made Calm & Transparent'),
      findsOneWidget,
    );
    expect(
      find.text('Everything Your Group Needs to Stay Aligned'),
      findsOneWidget,
    );
    expect(find.text('How It Works'), findsOneWidget);
    expect(find.byKey(const Key('dashboard-preview')), findsOneWidget);
    expect(find.byKey(const Key('ledger-preview')), findsOneWidget);
    expect(find.byKey(const Key('join-preview')), findsOneWidget);
    expect(find.text('Frictionless Joining'), findsOneWidget);
    expect(find.text('Shared Ledgers & Real-Time Balances'), findsOneWidget);
  });

  testWidgets('drawer links scroll to the matching section', (tester) async {
    final authProvider = _createAuthProvider();
    addTearDown(authProvider.dispose);
    await authProvider.initialize();

    await _pumpLanding(tester, authProvider);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nav-how-it-works')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-how-it-works')));
    await tester.pumpAndSettle();

    expect(find.text('Keep the ledger moving'), findsOneWidget);
  });

  testWidgets('signed-out footer CTA opens LoginPage', (tester) async {
    final authProvider = _createAuthProvider();
    addTearDown(authProvider.dispose);
    await authProvider.initialize();

    await _pumpLanding(tester, authProvider);
    await tester.ensureVisible(find.byKey(const Key('footer-launch')));
    await tester.tap(find.byKey(const Key('footer-launch')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('signed-in footer CTA opens the trip dashboard', (tester) async {
    final authProvider = _createAuthProvider(authenticated: true);
    addTearDown(authProvider.dispose);
    await authProvider.initialize();

    await _pumpLanding(tester, authProvider);
    await tester.ensureVisible(find.byKey(const Key('footer-launch')));
    await tester.tap(find.byKey(const Key('footer-launch')));
    await tester.pumpAndSettle();

    expect(find.text('Trip Dashboard'), findsOneWidget);
  });
}

Future<void> _pumpLanding(WidgetTester tester, AuthProvider authProvider) {
  return tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: MaterialApp(
        home: const LandingPage(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/menu': (_) => const Scaffold(body: Text('Trip Dashboard')),
        },
      ),
    ),
  );
}

AuthProvider _createAuthProvider({bool authenticated = false}) {
  final repository = _FakeAuthRepository(authenticated: authenticated);
  return AuthProvider(
    loginUsecase: LoginUsecase(repository: repository),
    registerUsecase: RegisterUsecase(repository: repository),
    logoutUsecase: LogoutUsecase(repository: repository),
    getCurrentUserUsecase: GetCurrentUserUsecase(repository: repository),
  );
}

class _FakeAuthRepository implements AuthRepository {
  final bool authenticated;

  _FakeAuthRepository({required this.authenticated});

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    if (authenticated) return Right(_testUser);
    return const Left(AuthenticationFailure(message: 'Signed out'));
  }

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
  Future<Either<Failure, void>> logout() async => Right(null);
}

final _testUser = UserEntity(
  id: 'traveler-1',
  email: 'traveler@example.com',
  name: 'Wander Traveler',
  createdAt: DateTime.utc(2026),
);