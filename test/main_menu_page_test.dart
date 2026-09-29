import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wanderfund_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wanderfund_app/features/auth/domain/usecases/auth_usecase.dart';
import 'package:wanderfund_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:wanderfund_app/features/main_menu/presentation/pages/main_menu_page.dart';
import 'package:wanderfund_app/features/travel_funds/data/models/travel_fund_model.dart';
import 'package:wanderfund_app/features/travel_funds/domain/repositories/travel_fund_repository.dart';
import 'package:wanderfund_app/features/travel_funds/domain/usecases/travel_fund_usecase.dart';
import 'package:wanderfund_app/features/travel_funds/presentation/providers/travel_fund_provider.dart';
import 'package:wanderfund_app/core/error/failure.dart';
import 'package:wanderfund_app/shared/entities/user_details_entity.dart';
import 'package:wanderfund_app/shared/entities/user_entity.dart';

void main() {
  testWidgets(
    'pulling the empty funds view reloads funds for the restored user',
    (tester) async {
      final authRepository = _FakeAuthRepository();
      final authProvider = AuthProvider(
        loginUsecase: LoginUsecase(repository: authRepository),
        registerUsecase: RegisterUsecase(repository: authRepository),
        logoutUsecase: LogoutUsecase(repository: authRepository),
        getCurrentUserUsecase: GetCurrentUserUsecase(
          repository: authRepository,
        ),
      );
      await authProvider.initialize();

      final travelFundRepository = _FakeTravelFundRepository();
      final travelFundProvider = TravelFundProvider(
        getTravelFundsUsecase: GetTravelFundsUsecase(
          repository: travelFundRepository,
        ),
        getTravelFundInviteCodeUsecase: GetTravelFundInviteCodeUsecase(
          repository: travelFundRepository,
        ),
        createTravelFundUsecase: CreateTravelFundUsecase(
          repository: travelFundRepository,
        ),
        joinTravelFundUsecase: JoinTravelFundUsecase(
          repository: travelFundRepository,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(value: travelFundProvider),
          ],
          child: const MaterialApp(home: MainMenuPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(travelFundRepository.requestedUserIds, ['restored-user']);
      expect(
        find.text('You are not a member of any travel fund yet.'),
        findsOneWidget,
      );

      await tester.drag(find.byType(ListView), const Offset(0, 350));
      await tester.pumpAndSettle();

      expect(travelFundRepository.requestedUserIds, [
        'restored-user',
        'restored-user',
      ]);
    },
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async => Right(
    UserEntity(
      id: 'restored-user',
      email: 'user@example.com',
      name: 'Restored User',
      createdAt: DateTime.utc(2025),
    ),
  );

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

class _FakeTravelFundRepository implements TravelFundRepository {
  final List<String> requestedUserIds = [];

  @override
  Future<Either<Failure, List<TravelFund>>> getTravelFunds({
    required String userId,
  }) async {
    requestedUserIds.add(userId);
    return const Right([]);
  }

  @override
  Future<Either<Failure, String>> createTravelFund({
    required String name,
    required String description,
    required String baseCurrency,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> getTravelFundInviteCode({
    required String publicId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> joinTravelFund({
    required String inviteCode,
  }) async => throw UnimplementedError();
}
