import 'package:flutter/foundation.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/ledger_model.dart';
import '../../domain/usecases/ledger_usecase.dart';

class LedgerProvider extends ChangeNotifier {
  final GetLedgerUsecase getLedgerUsecase;
  final GetLedgerMembersUsecase getLedgerMembersUsecase;
  final GetJoinRequestsUsecase getJoinRequestsUsecase;
  final UpdateJoinRequestUsecase updateJoinRequestUsecase;
  final CreateTransactionUsecase createTransactionUsecase;
  final GetTransactionApprovalRequestsUsecase getTransactionApprovalRequestsUsecase;
  final UpdateTransactionApprovalUsecase updateTransactionApprovalUsecase;

  LedgerProvider({
    required this.getLedgerUsecase,
    required this.getLedgerMembersUsecase,
    required this.getJoinRequestsUsecase,
    required this.updateJoinRequestUsecase,
    required this.createTransactionUsecase,
    required this.getTransactionApprovalRequestsUsecase,
    required this.updateTransactionApprovalUsecase,
  });

  Ledger? _ledger;
  List<LedgerMember> _members = const [];
  List<JoinRequest> _joinRequests = const [];
  List<TransactionEntry> _transactionApprovalRequests = const [];
  bool _isLoading = false;
  bool _isAuthenticationError = false;
  String? _errorMessage;

  Ledger? get ledger => _ledger;
  List<LedgerMember> get members => _members;
  List<JoinRequest> get joinRequests => _joinRequests;
  List<TransactionEntry> get transactionApprovalRequests =>
      _transactionApprovalRequests;
  bool get isLoading => _isLoading;
  bool get isAuthenticationError => _isAuthenticationError;
  String? get errorMessage => _errorMessage;

  Future<void> loadLedger({required String publicId}) async {
    _isLoading = true;
    _isAuthenticationError = false;
    _ledger = null;
    _errorMessage = null;
    notifyListeners();

    final result = await getLedgerUsecase(publicId: publicId);
    result.fold((failure) {
      _isAuthenticationError = failure is AuthenticationFailure;
      _errorMessage = failure.message;
    }, (ledger) => _ledger = ledger);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMembers({required String publicId}) async {
    final result = await getLedgerMembersUsecase(publicId: publicId);
    result.fold((_) => _members = const [], (members) => _members = members);
    notifyListeners();
  }

  Future<void> loadJoinRequests({required String publicId}) async {
    final result = await getJoinRequestsUsecase(publicId: publicId);
    result.fold(
      (_) => _joinRequests = const [],
      (requests) => _joinRequests = requests,
    );
    notifyListeners();
  }

  Future<bool> updateJoinRequest({
    required String publicId,
    required String requestId,
    required String status,
  }) async {
    final result = await updateJoinRequestUsecase(
      publicId: publicId,
      requestId: requestId,
      status: status,
    );
    if (result.isLeft()) return false;
    _joinRequests = _joinRequests
        .map(
          (request) =>
              request.id == requestId ? request.withStatus(status) : request,
        )
        .toList();
    notifyListeners();
    return true;
  }

  Future<String?> createTransaction({
    required String publicId,
    required String action,
    required double amount,
    required String currency,
    required String description,
    required String referenceId,
  }) async {
    final result = await createTransactionUsecase(
      publicId: publicId,
      action: action,
      amount: amount,
      currency: currency,
      description: description,
      referenceId: referenceId,
    );
    return result.fold((_) => null, (message) => message);
  }

  Future<String?> loadTransactionApprovalRequests({
    required String publicId,
    required String status,
  }) async {
    final result = await getTransactionApprovalRequestsUsecase(
      publicId: publicId,
      status: status,
    );
    return result.fold((failure) {
      _transactionApprovalRequests = const [];
      notifyListeners();
      return failure.message;
    }, (requests) {
      _transactionApprovalRequests = requests;
      notifyListeners();
      return null;
    });
  }

  Future<String?> updateTransactionApproval({
    required String publicId,
    required String transactionId,
    required String status,
    required String reason,
  }) async {
    final result = await updateTransactionApprovalUsecase(
      publicId: publicId,
      transactionId: transactionId,
      status: status,
      reason: reason,
    );
    return result.fold((failure) => null, (message) {
      _transactionApprovalRequests = _transactionApprovalRequests
          .where((request) => request.id != transactionId)
          .toList();
      notifyListeners();
      return message;
    });
  }
}
