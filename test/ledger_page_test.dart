import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wanderfund_app/core/error/failure.dart';
import 'package:wanderfund_app/features/ledger/data/models/ledger_model.dart';
import 'package:wanderfund_app/features/ledger/domain/repositories/ledger_repository.dart';
import 'package:wanderfund_app/features/ledger/domain/usecases/ledger_usecase.dart';
import 'package:wanderfund_app/features/ledger/presentation/pages/ledger_page.dart';
import 'package:wanderfund_app/features/ledger/presentation/providers/ledger_provider.dart';
import 'package:wanderfund_app/features/travel_funds/data/models/travel_fund_model.dart';
import 'package:wanderfund_app/features/travel_funds/domain/repositories/travel_fund_repository.dart';
import 'package:wanderfund_app/features/travel_funds/domain/usecases/travel_fund_usecase.dart';
import 'package:wanderfund_app/features/travel_funds/presentation/providers/travel_fund_provider.dart';

void main() {
  testWidgets('shows signs for running balance and transaction history', (
    tester,
  ) async {
    final repository = _FakeLedgerRepository(
      const Ledger(
        publicId: 'fund-123',
        runningBalance: -1234.5,
        transactions: [
          TransactionEntry(
            id: 'outgoing',
            travelFundId: 'fund-123',
            referenceId: '',
            description: 'Cash out',
            amount: -250,
            status: 'APPROVED',
          ),
          TransactionEntry(
            id: 'incoming',
            travelFundId: 'fund-123',
            referenceId: '',
            description: 'Cash in',
            amount: 500,
            status: 'APPROVED',
          ),
        ],
      ),
    );
    final ledgerProvider = _ledgerProvider(repository);
    final travelFundProvider = _travelFundProvider(repository);
    addTearDown(ledgerProvider.dispose);
    addTearDown(travelFundProvider.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ledgerProvider),
          ChangeNotifierProvider.value(value: travelFundProvider),
        ],
        child: const MaterialApp(home: LedgerPage(publicId: 'fund-123')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('-PHP 1,234.50'), findsOneWidget);
    expect(find.text('-PHP 250.00'), findsOneWidget);
    expect(find.text('+PHP 500.00'), findsOneWidget);
  });

  testWidgets('does not duplicate the minus in transaction details', (
    tester,
  ) async {
    const request = TransactionEntry(
      id: 'transaction-123',
      travelFundId: 'fund-123',
      referenceId: '',
      description: 'Cash out',
      amount: -250,
      status: 'REQUESTED',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionRequestDetailsPage(
          publicId: 'fund-123',
          request: request,
          canManageRequests: true,
        ),
      ),
    );

    expect(find.text('-PHP 250.00'), findsNWidgets(2));
    expect(find.text('--PHP 250.00'), findsNothing);
    expect(find.text('Travel fund ID'), findsNothing);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('filters approval requests by status and shows reject reason', (
    tester,
  ) async {
    const rejectedRequest = TransactionEntry(
      id: 'transaction-456',
      travelFundId: 'fund-123',
      referenceId: '',
      description: 'Missing receipt expense',
      amount: -75,
      status: 'REJECTED',
      rejectReason: 'Missing receipt',
    );
    final repository = _FakeLedgerRepository(
      const Ledger(publicId: 'fund-123', runningBalance: 0, transactions: []),
      approvalRequests: const [rejectedRequest],
    );
    final ledgerProvider = _ledgerProvider(repository);
    addTearDown(ledgerProvider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: ledgerProvider,
        child: const MaterialApp(
          home: TransactionApprovalPage(publicId: 'fund-123'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedApprovalStatuses, ['REQUESTED']);
    expect(find.text('No transaction requests to review.'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('APPROVED').last);
    await tester.pumpAndSettle();
    expect(repository.requestedApprovalStatuses, ['REQUESTED', 'APPROVED']);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('REJECTED').last);
    await tester.pumpAndSettle();

    expect(repository.requestedApprovalStatuses, [
      'REQUESTED',
      'APPROVED',
      'REJECTED',
    ]);
    expect(find.text('Reject reason: Missing receipt'), findsOneWidget);
  });

  testWidgets('non-main members can view requests but cannot decide them', (
    tester,
  ) async {
    const requestedRequest = TransactionEntry(
      id: 'transaction-789',
      travelFundId: 'fund-123',
      referenceId: '',
      description: 'Shared expense',
      amount: -45,
      status: 'REQUESTED',
    );
    final repository = _FakeLedgerRepository(
      const Ledger(publicId: 'fund-123', runningBalance: 0, transactions: []),
      approvalRequests: const [requestedRequest],
    );
    final ledgerProvider = _ledgerProvider(repository);
    final travelFundProvider = _travelFundProvider(repository);
    addTearDown(ledgerProvider.dispose);
    addTearDown(travelFundProvider.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: ledgerProvider),
          ChangeNotifierProvider.value(value: travelFundProvider),
        ],
        child: const MaterialApp(home: LedgerPage(publicId: 'fund-123')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Transaction approvals'), findsOneWidget);
    expect(find.byTooltip('Join requests'), findsNothing);
    await tester.tap(find.byTooltip('Transaction approvals'));
    await tester.pumpAndSettle();

    expect(find.text('Shared expense'), findsOneWidget);
    await tester.tap(find.text('View details'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });
}

LedgerProvider _ledgerProvider(_FakeLedgerRepository repository) {
  return LedgerProvider(
    getLedgerUsecase: GetLedgerUsecase(repository: repository),
    getLedgerMembersUsecase: GetLedgerMembersUsecase(repository: repository),
    getJoinRequestsUsecase: GetJoinRequestsUsecase(repository: repository),
    updateJoinRequestUsecase: UpdateJoinRequestUsecase(repository: repository),
    createTransactionUsecase: CreateTransactionUsecase(repository: repository),
    getTransactionApprovalRequestsUsecase:
        GetTransactionApprovalRequestsUsecase(repository: repository),
    updateTransactionApprovalUsecase: UpdateTransactionApprovalUsecase(
      repository: repository,
    ),
  );
}

TravelFundProvider _travelFundProvider(_FakeLedgerRepository repository) {
  return TravelFundProvider(
    getTravelFundsUsecase: GetTravelFundsUsecase(repository: repository),
    getTravelFundInviteCodeUsecase: GetTravelFundInviteCodeUsecase(
      repository: repository,
    ),
    createTravelFundUsecase: CreateTravelFundUsecase(repository: repository),
    joinTravelFundUsecase: JoinTravelFundUsecase(repository: repository),
  );
}

class _FakeLedgerRepository implements LedgerRepository, TravelFundRepository {
  final Ledger ledger;
  final List<TransactionEntry> approvalRequests;
  final List<String> requestedApprovalStatuses = [];

  _FakeLedgerRepository(this.ledger, {this.approvalRequests = const []});

  @override
  Future<Either<Failure, Ledger>> getLedger({required String publicId}) async {
    return Right(ledger);
  }

  @override
  Future<Either<Failure, List<LedgerMember>>> getMembers({
    required String publicId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, List<JoinRequest>>> getJoinRequests({
    required String publicId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateJoinRequest({
    required String publicId,
    required String requestId,
    required String status,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> createTransaction({
    required String publicId,
    required String action,
    required double amount,
    required String currency,
    required String description,
    required String referenceId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, List<TransactionEntry>>>
  getTransactionApprovalRequests({
    required String publicId,
    required String status,
  }) async {
    requestedApprovalStatuses.add(status);
    return Right(
      approvalRequests
          .where((request) => request.status.toUpperCase() == status)
          .toList(),
    );
  }

  @override
  Future<Either<Failure, String>> updateTransactionApproval({
    required String publicId,
    required String transactionId,
    required String status,
    required String reason,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, List<TravelFund>>> getTravelFunds({
    required String userId,
  }) async => const Right([]);

  @override
  Future<Either<Failure, String>> getTravelFundInviteCode({
    required String publicId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> createTravelFund({
    required String name,
    required String description,
    required String baseCurrency,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> joinTravelFund({
    required String inviteCode,
  }) async => throw UnimplementedError();
}
