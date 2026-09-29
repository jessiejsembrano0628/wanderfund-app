import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/ledger_model.dart';

abstract class LedgerRemoteDataSource {
  Future<Ledger> getLedger({required String publicId, required String token});
  Future<List<LedgerMember>> getMembers({
    required String publicId,
    required String token,
  });
  Future<List<JoinRequest>> getJoinRequests({
    required String publicId,
    required String token,
  });
  Future<void> updateJoinRequest({
    required String publicId,
    required String requestId,
    required String status,
    required String token,
  });
  Future<String> createTransaction({
    required String publicId,
    required String action,
    required double amount,
    required String currency,
    required String description,
    required String referenceId,
    required String token,
  });
  Future<List<TransactionEntry>> getTransactionApprovalRequests({
    required String publicId,
    required String token,
  });
  Future<String> updateTransactionApproval({
    required String publicId,
    required String transactionId,
    required String status,
    required String reason,
    required String token,
  });
}

class LedgerRemoteDataSourceImpl implements LedgerRemoteDataSource {
  final ApiService apiService;

  LedgerRemoteDataSourceImpl({required this.apiService});

  @override
  Future<Ledger> getLedger({
    required String publicId,
    required String token,
  }) async {
    final response = await apiService.get(
      endpoint: AppConstants.ledgerEndpoint(publicId),
      token: token,
    );

    if (response is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid ledger response');
    }

    try {
      final body = response['body'];
      if (body is! Map<String, dynamic>) {
        throw ServerException(message: 'Invalid ledger response body');
      }
      return Ledger.fromJson(body);
    } on FormatException catch (e) {
      throw ServerException(message: e.message);
    } catch (_) {
      throw ServerException(message: 'Invalid ledger response');
    }
  }

  @override
  Future<List<LedgerMember>> getMembers({
    required String publicId,
    required String token,
  }) async {
    final response = await apiService.get(
      endpoint: AppConstants.membersEndpoint(publicId),
      token: token,
    );

    if (response is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid members response');
    }

    final body = response['body'];
    if (body == null) {
      return const [];
    }
    if (body is! List) {
      throw ServerException(message: 'Invalid members response body');
    }

    try {
      return body
          .map((item) => LedgerMember.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw ServerException(message: 'Invalid members response');
    }
  }

  @override
  Future<List<JoinRequest>> getJoinRequests({
    required String publicId,
    required String token,
  }) async {
    final response = await apiService.get(
      endpoint: AppConstants.groupJoinRequestEndpoint(publicId),
      token: token,
    );

    if (response is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid join requests response');
    }

    final body = response['body'];
    if (body == null) return const [];
    if (body is! List) {
      throw ServerException(message: 'Invalid join requests response body');
    }

    try {
      return body
          .map((item) => JoinRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw ServerException(message: 'Invalid join requests response');
    }
  }

  @override
  Future<void> updateJoinRequest({
    required String publicId,
    required String requestId,
    required String status,
    required String token,
  }) async {
    final normalizedStatus = status.toUpperCase();

    final endpoint = switch (normalizedStatus) {
      'APPROVED' => AppConstants.approveGroupJoinRequestEndpoint(publicId),
      'REJECTED' => AppConstants.rejectGroupJoinRequestEndpoint(publicId),
      _ => throw ArgumentError.value(
        status,
        'status',
        'Unsupported join request status',
      ),
    };

    await apiService.put(
      endpoint: endpoint,
      token: token,
      body: {'user_id': requestId},
    );
  }

  @override
  Future<String> createTransaction({
    required String publicId,
    required String action,
    required double amount,
    required String currency,
    required String description,
    required String referenceId,
    required String token,
  }) async {
    final response = await apiService.post(
      endpoint: AppConstants.createTransactionEndpoint,
      token: token,
      body: {
        'travel_fund_id': publicId,
        'action': action,
        'amount': amount,
        'currency': currency,
        'description': description,
        'reference_id': referenceId,
      },
    );

    if (response is! Map<String, dynamic> || response['body'] is! List) {
      throw ServerException(message: 'Invalid create transaction response');
    }
    return _responseMessage(response, 'Transaction request submitted.');
  }

  @override
  Future<List<TransactionEntry>> getTransactionApprovalRequests({
    required String publicId,
    required String token,
  }) async {
    final response = await apiService.get(
      endpoint: AppConstants.transactionApprovalRequestsEndpoint(publicId),
      token: token,
    );
    if (response is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid transaction approval response');
    }
    final body = response['body'];
    if (body == null) return const [];
    if (body is! List) {
      throw ServerException(
        message: 'Invalid transaction approval response body',
      );
    }

    try {
      return body
          .map(
            (item) => TransactionEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      throw ServerException(message: 'Invalid transaction approval response');
    }
  }

  @override
  Future<String> updateTransactionApproval({
    required String publicId,
    required String transactionId,
    required String status,
    required String reason,
    required String token,
  }) async {
    final normalizedStatus = status.toUpperCase();
    final isApproval = normalizedStatus == 'APPROVED';
    if (!isApproval && normalizedStatus != 'REJECTED') {
      throw ArgumentError.value(
        status,
        'status',
        'Unsupported transaction status',
      );
    }
    final response = await apiService.post(
      endpoint: isApproval
          ? AppConstants.approveTransactionEndpoint
          : AppConstants.rejectTransactionEndpoint,
      token: token,
      body: {
        'public_id': publicId,
        'transaction_id': transactionId,
        if (!isApproval) 'reject_reason': reason,
      },
    );
    if (response is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid transaction approval response');
    }
    return _responseMessage(
      response,
      isApproval
          ? 'Approved transaction successfully.'
          : 'Rejected transaction successfully.',
    );
  }

  String _responseMessage(Map<String, dynamic> response, String fallback) {
    final message = response['msg']?.toString().trim();
    return message == null || message.isEmpty ? fallback : message;
  }
}
