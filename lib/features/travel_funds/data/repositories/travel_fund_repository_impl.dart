import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/services/token_storage.dart';
import '../../domain/repositories/travel_fund_repository.dart';
import '../datasources/travel_fund_remote_data_source.dart';
import '../models/travel_fund_model.dart';

class TravelFundRepositoryImpl implements TravelFundRepository {
  final TravelFundRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  TravelFundRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, List<TravelFund>>> getTravelFunds({
    required String userId,
  }) async {
    try {
      final token = tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        return const Left(AuthenticationFailure(message: 'No token found'));
      }
      return Right(await remoteDataSource.getTravelFunds(userId: userId, token: token));
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
  Future<Either<Failure, String>> getTravelFundInviteCode({
    required String publicId,
  }) async {
    try {
      final token = _tokenOrFailure();
      if (token is Failure) return Left(token);
      return Right(await remoteDataSource.getTravelFundInviteCode(
        publicId: publicId,
        token: token as String,
      ));
    } catch (e) {
      return _mapFailure(e);
    }
  }

  @override
  Future<Either<Failure, String>> createTravelFund({
    required String name,
    required String description,
    required String baseCurrency,
  }) async {
    try {
      final token = _tokenOrFailure();
      if (token is Failure) return Left(token);
      return Right(await remoteDataSource.createTravelFund(
        name: name,
        description: description,
        baseCurrency: baseCurrency,
        token: token as String,
      ));
    } catch (e) {
      return _mapFailure(e);
    }
  }

  @override
  Future<Either<Failure, String>> joinTravelFund({required String inviteCode}) async {
    try {
      final token = _tokenOrFailure();
      if (token is Failure) return Left(token);
      return Right(await remoteDataSource.joinTravelFund(
        inviteCode: inviteCode,
        token: token as String,
      ));
    } catch (e) {
      return _mapFailure(e);
    }
  }

  @override
  Future<Either<Failure, void>> archiveTravelFund({
    required String publicId,
  }) async {
    try {
      final token = _tokenOrFailure();
      if (token is Failure) return Left(token);
      await remoteDataSource.archiveTravelFund(
        publicId: publicId,
        token: token as String,
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

  dynamic _tokenOrFailure() {
    final token = tokenStorage.getToken();
    return token == null || token.isEmpty
        ? const AuthenticationFailure(message: 'No token found')
        : token;
  }

  Either<Failure, String> _mapFailure(Object error) {
    if (error is AuthenticationException) {
      return Left(AuthenticationFailure(message: error.message));
    }
    if (error is ServerException) return Left(ServerFailure(message: error.message));
    if (error is NetworkException) return Left(NetworkFailure(message: error.message));
    return Left(UnexpectedFailure(message: error.toString()));
  }
}
