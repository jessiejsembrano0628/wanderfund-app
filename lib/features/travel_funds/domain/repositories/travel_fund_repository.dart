import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/travel_fund_model.dart';

abstract class TravelFundRepository {
  Future<Either<Failure, List<TravelFund>>> getTravelFunds({required String userId});
  Future<Either<Failure, String>> getTravelFundInviteCode({
    required String publicId,
  });
  Future<Either<Failure, String>> createTravelFund({
    required String name,
    required String description,
    required String baseCurrency,
  });
  Future<Either<Failure, String>> joinTravelFund({required String inviteCode});
}
