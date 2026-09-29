import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/ledger_model.dart';
import '../repositories/ledger_repository.dart';

class GetLedgerUsecase {
  final LedgerRepository repository;

  GetLedgerUsecase({required this.repository});

  Future<Either<Failure, Ledger>> call({required String publicId}) {
    return repository.getLedger(publicId: publicId);
  }
}

class GetLedgerMembersUsecase {
  final LedgerRepository repository;

  GetLedgerMembersUsecase({required this.repository});

  Future<Either<Failure, List<LedgerMember>>> call({required String publicId}) {
    return repository.getMembers(publicId: publicId);
  }
}

class GetJoinRequestsUsecase {
  final LedgerRepository repository;

  GetJoinRequestsUsecase({required this.repository});

  Future<Either<Failure, List<JoinRequest>>> call({required String publicId}) {
    return repository.getJoinRequests(publicId: publicId);
  }
}

class UpdateJoinRequestUsecase {
  final LedgerRepository repository;

  UpdateJoinRequestUsecase({required this.repository});

  Future<Either<Failure, void>> call({
    required String publicId,
    required String requestId,
    required String status,
  }) {
    return repository.updateJoinRequest(
      publicId: publicId,
      requestId: requestId,
      status: status,
    );
  }
}

class CreateTransactionUsecase {
  final LedgerRepository repository;

  CreateTransactionUsecase({required this.repository});

  Future<Either<Failure, String>> call({
    required String publicId,
    required String action,
    required double amount,
    required String currency,
    required String description,
    required String referenceId,
  }) {
    return repository.createTransaction(
      publicId: publicId,
      action: action,
      amount: amount,
      currency: currency,
      description: description,
      referenceId: referenceId,
    );
  }
}

class GetTransactionApprovalRequestsUsecase {
  final LedgerRepository repository;

  GetTransactionApprovalRequestsUsecase({required this.repository});

  Future<Either<Failure, List<TransactionEntry>>> call({
    required String publicId,
  }) {
    return repository.getTransactionApprovalRequests(publicId: publicId);
  }
}

class UpdateTransactionApprovalUsecase {
  final LedgerRepository repository;

  UpdateTransactionApprovalUsecase({required this.repository});

  Future<Either<Failure, String>> call({
    required String publicId,
    required String transactionId,
    required String status,
    required String reason,
  }) {
    return repository.updateTransactionApproval(
      publicId: publicId,
      transactionId: transactionId,
      status: status,
      reason: reason,
    );
  }
}
