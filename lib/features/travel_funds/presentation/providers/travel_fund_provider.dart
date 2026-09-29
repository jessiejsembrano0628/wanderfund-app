import 'package:flutter/foundation.dart';
import '../../../../core/error/failure.dart';
import '../../data/models/travel_fund_model.dart';
import '../../domain/usecases/travel_fund_usecase.dart';

class TravelFundProvider extends ChangeNotifier {
  final GetTravelFundsUsecase getTravelFundsUsecase;
  final GetTravelFundInviteCodeUsecase getTravelFundInviteCodeUsecase;
  final CreateTravelFundUsecase createTravelFundUsecase;
  final JoinTravelFundUsecase joinTravelFundUsecase;

  TravelFundProvider({
    required this.getTravelFundsUsecase,
    required this.getTravelFundInviteCodeUsecase,
    required this.createTravelFundUsecase,
    required this.joinTravelFundUsecase,
  });

  List<TravelFund> _funds = const [];
  bool _isLoading = false;
  bool _isAuthenticationError = false;
  String? _errorMessage;
  bool _isActionLoading = false;
  String? _actionErrorMessage;

  List<TravelFund> get funds => _funds;
  bool get isLoading => _isLoading;
  bool get isAuthenticationError => _isAuthenticationError;
  String? get errorMessage => _errorMessage;
  bool get isActionLoading => _isActionLoading;
  String? get actionErrorMessage => _actionErrorMessage;
  String? get actionMessage => _actionMessage;

  Future<void> loadFunds({required String userId}) async {
    _isLoading = true;
    _isAuthenticationError = false;
    _errorMessage = null;
    notifyListeners();

    final result = await getTravelFundsUsecase(userId: userId);
    result.fold(
      (failure) {
        _isAuthenticationError = failure is AuthenticationFailure;
        _errorMessage = failure.message;
      },
      (funds) => _funds = funds,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createTravelFund({
    required String name,
    required String description,
    required String baseCurrency,
  }) async {
    _startAction();
    final result = await createTravelFundUsecase(
      name: name,
      description: description,
      baseCurrency: baseCurrency,
    );
    final inviteCode = result.fold(
      (failure) {
        _actionErrorMessage = failure.message;
        return null;
      },
      (inviteCode) {
        _actionErrorMessage = null;
        _actionMessage = 'Travel fund created.';
        return inviteCode;
      },
    );
    _isActionLoading = false;
    notifyListeners();
    return inviteCode;
  }

  Future<String?> getTravelFundInviteCode({required String publicId}) async {
    _startAction();
    final result = await getTravelFundInviteCodeUsecase(publicId: publicId);
    final inviteCode = result.fold(
      (failure) {
        _actionErrorMessage = failure.message;
        return null;
      },
      (inviteCode) {
        _actionErrorMessage = null;
        return inviteCode;
      },
    );
    _isActionLoading = false;
    notifyListeners();
    return inviteCode;
  }

  Future<String?> joinTravelFund({required String inviteCode}) async {
    _startAction();
    final result = await joinTravelFundUsecase(inviteCode: inviteCode);
    final success = result.fold(
      (failure) {
        _actionErrorMessage = failure.message;
        return false;
      },
      (message) {
        _actionErrorMessage = null;
        _actionMessage = message;
        return true;
      },
    );
    _isActionLoading = false;
    notifyListeners();
    return success ? _actionMessage : null;
  }

  String? _actionMessage;

  void _startAction() {
    _isActionLoading = true;
    _actionErrorMessage = null;
    _actionMessage = null;
    notifyListeners();
  }

}
