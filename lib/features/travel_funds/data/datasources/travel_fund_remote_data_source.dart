import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/travel_fund_model.dart';

abstract class TravelFundRemoteDataSource {
  Future<List<TravelFund>> getTravelFunds({required String userId, required String token});
  Future<String> getTravelFundInviteCode({required String publicId, required String token});
  Future<String> createTravelFund({
    required String name,
    required String description,
    required String baseCurrency,
    required String token,
  });
  Future<String> joinTravelFund({required String inviteCode, required String token});
  Future<void> archiveTravelFund({required String publicId, required String token});
}

class TravelFundRemoteDataSourceImpl implements TravelFundRemoteDataSource {
  final ApiService apiService;

  TravelFundRemoteDataSourceImpl({required this.apiService});

  @override
  Future<String> getTravelFundInviteCode({
    required String publicId,
    required String token,
  }) async {
    final response = await apiService.get(
      endpoint: AppConstants.travelFundInviteEndpoint(publicId),
      token: token,
    );
    final body = response is Map<String, dynamic> ? response['body'] : null;
    if (body is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid travel fund invite response');
    }
    final inviteCode = body['invite_code']?.toString() ?? '';
    if (inviteCode.isEmpty) {
      throw ServerException(message: 'Invite code was not returned');
    }
    return inviteCode;
  }

  @override
  Future<List<TravelFund>> getTravelFunds({
    required String userId,
    required String token,
  }) async {
    final response = await apiService.get(
      endpoint: AppConstants.travelFundsEndpoint(userId),
      token: token,
    );

    if (response is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid travel funds response');
    }

    final body = response['body'];
    if (body == null) {
      return const [];
    }
    if (body is! List) {
      throw ServerException(message: 'Invalid travel funds response');
    }

    try {
      return body
          .map((item) => TravelFund.fromJson(item as Map<String, dynamic>))
          .where((fund) => fund.publicId.isNotEmpty)
          .toList();
    } catch (_) {
      throw ServerException(message: 'Invalid travel funds response');
    }
  }

  @override
  Future<String> createTravelFund({
    required String name,
    required String description,
    required String baseCurrency,
    required String token,
  }) async {
    final response = await apiService.post(
      endpoint: AppConstants.createTravelFundEndpoint,
      token: token,
      body: {
        'name': name,
        'description': description,
        'base_currency': baseCurrency,
      },
    );
    final body = response is Map<String, dynamic> ? response['body'] : null;
    if (body is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid create travel fund response');
    }
    final publicId = (body['public_id'] ?? body['PublicID'])?.toString() ?? '';
    if (publicId.isEmpty) {
      throw ServerException(message: 'Travel fund public ID was not returned');
    }
    return publicId;
  }

  @override
  Future<String> joinTravelFund({
    required String inviteCode,
    required String token,
  }) async {
    final response = await apiService.get(
      endpoint: AppConstants.joinTravelFundEndpoint(inviteCode),
      token: token,
    );
    final body = response is Map<String, dynamic> ? response['body'] : null;
    if (body is! Map<String, dynamic>) {
      throw ServerException(message: 'Invalid join travel fund response');
    }
    return body['message']?.toString() ?? 'Join request submitted.';
  }

  @override
  Future<void> archiveTravelFund({
    required String publicId,
    required String token,
  }) async {
    await apiService.put(
      endpoint: AppConstants.archiveTravelFundEndpoint(publicId),
      token: token,
      body: const <String, dynamic>{},
    );
  }
}
