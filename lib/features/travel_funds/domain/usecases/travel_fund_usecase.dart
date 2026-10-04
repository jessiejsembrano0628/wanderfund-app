import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/travel_fund_model.dart';
import '../repositories/travel_fund_repository.dart';

class GetTravelFundsUsecase {
  final TravelFundRepository repository;

  GetTravelFundsUsecase({required this.repository});

  Future<Either<Failure, List<TravelFund>>> call({required String userId}) {
    return repository.getTravelFunds(userId: userId);
  }
}

class GetTravelFundInviteCodeUsecase {
  final TravelFundRepository repository;

  GetTravelFundInviteCodeUsecase({required this.repository});

  Future<Either<Failure, String>> call({required String publicId}) {
    return repository.getTravelFundInviteCode(publicId: publicId);
  }
}

class CreateTravelFundUsecase {
  final TravelFundRepository repository;

  CreateTravelFundUsecase({required this.repository});

  Future<Either<Failure, String>> call({
    required String name,
    required String description,
    required String baseCurrency,
  }) {
    return repository.createTravelFund(
      name: name,
      description: description,
      baseCurrency: baseCurrency,
    );
  }
}

class JoinTravelFundUsecase {
  final TravelFundRepository repository;

  JoinTravelFundUsecase({required this.repository});

  Future<Either<Failure, String>> call({required String inviteCode}) {
    return repository.joinTravelFund(inviteCode: inviteCode);
  }
}

class ArchiveTravelFundUsecase {
  final TravelFundRepository repository;

  ArchiveTravelFundUsecase({required this.repository});

  Future<Either<Failure, void>> call({required String publicId}) {
    return repository.archiveTravelFund(publicId: publicId);
  }
}
