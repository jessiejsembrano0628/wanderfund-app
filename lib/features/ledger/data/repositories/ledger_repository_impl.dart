import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/services/token_storage.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_remote_data_source.dart';
import '../models/ledger_model.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  final LedgerRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  LedgerRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, Ledger>> getLedger({required String publicId}) async {
    try {
      final token = tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthenticationFailure(message: 'No token found'));
      }
      return Right(
        await remoteDataSource.getLedger(publicId: publicId, token: token),
      );
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
  Future<Either<Failure, List<LedgerMember>>> getMembers({
    required String publicId,
  }) async {
    try {
      final token = tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthenticationFailure(message: 'No token found'));
      }
      return Right(
        await remoteDataSource.getMembers(publicId: publicId, token: token),
      );
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
  Future<Either<Failure, List<JoinRequest>>> getJoinRequests({
    required String publicId,
  }) async {
    try {
      final token = tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthenticationFailure(message: 'No token found'));
      }
      return Right(
        await remoteDataSource.getJoinRequests(
          publicId: publicId,
          token: token,
        ),
      );
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
  Future<Either<Failure, void>> updateJoinRequest({
    required String publicId,
    required String requestId,
    required String status,
  }) async {
    try {
      final token = tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthenticationFailure(message: 'No token found'));
      }
      await remoteDataSource.updateJoinRequest(
        publicId: publicId,
        requestId: requestId,
        status: status,
        token: token,
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
  Future<Either<Failure, String>> createTransaction({
    required String publicId,
    required String action,
    required double amount,
    required String currency,
    required String description,
    required String referenceId,
  }) async {
    try {
      final token = tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthenticationFailure(message: 'No token found'));
      }
      return Right(await remoteDataSource.createTransaction(
        publicId: publicId,
        action: action,
        amount: amount,
        currency: currency,
        description: description,
        referenceId: referenceId,
        token: token,
      ));
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
  Future<Either<Failure, List<TransactionEntry>>> getTransactionApprovalRequests({
    required String publicId,
  }) async {
    try {
      final token = tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthenticationFailure(message: 'No token found'));
      }
      return Right(await remoteDataSource.getTransactionApprovalRequests(
        publicId: publicId,
        token: token,
      ));
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
  Future<Either<Failure, String>> updateTransactionApproval({
    required String publicId,
    required String transactionId,
    required String status,
    required String reason,
  }) async {
    try {
      final token = tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthenticationFailure(message: 'No token found'));
      }
      return Right(await remoteDataSource.updateTransactionApproval(
        publicId: publicId,
        transactionId: transactionId,
        status: status,
        reason: reason,
        token: token,
      ));
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
}
