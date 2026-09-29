import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/ledger_model.dart';

abstract class LedgerRepository {
  Future<Either<Failure, Ledger>> getLedger({required String publicId});
  Future<Either<Failure, List<LedgerMember>>> getMembers({
    required String publicId,
  });
  Future<Either<Failure, List<JoinRequest>>> getJoinRequests({
    required String publicId,
  });
  Future<Either<Failure, void>> updateJoinRequest({
    required String publicId,
    required String requestId,
    required String status,
  });
  Future<Either<Failure, String>> createTransaction({
    required String publicId,
    required String action,
    required double amount,
    required String currency,
    required String description,
    required String referenceId,
  });
  Future<Either<Failure, List<TransactionEntry>>> getTransactionApprovalRequests({
    required String publicId,
  });
  Future<Either<Failure, String>> updateTransactionApproval({
    required String publicId,
    required String transactionId,
    required String status,
    required String reason,
  });
}
