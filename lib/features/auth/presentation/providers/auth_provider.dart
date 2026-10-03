import 'package:flutter/material.dart';
import '../../../../core/error/failure.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../../../../shared/entities/user_details_entity.dart';
import '../../../../shared/entities/user_entity.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  UserEntity? _user;
  UserDetailsEntity? _userDetails;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _canRetryInitialization = false;
  String? _errorMessage;

  UserEntity? get user => _user;
  UserDetailsEntity? get userDetails => _userDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get canRetryInitialization => _canRetryInitialization;

  AuthProvider({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
  });

  Future<void> initialize() async {
    if (_isInitialized && !_canRetryInitialization) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getCurrentUserUsecase();
    result.fold(
      (failure) {
        _user = null;
        _isAuthenticated = false;
        final signedOut =
            failure is AuthenticationFailure ||
            (failure is ServerFailure &&
                (failure.code == '404' || failure.code == '504'));
        _errorMessage = signedOut ? null : failure.message;
        _canRetryInitialization = !signedOut;
      },
      (user) {
        _user = user;
        _isAuthenticated = true;
        _errorMessage = null;
        _canRetryInitialization = false;
      },
    );
    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await registerUsecase(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        mobileNumber: mobileNumber,
      );
      result.fold(
        (failure) => _errorMessage = failure.message,
        (_) => _errorMessage = null,
      );
      _isLoading = false;
      notifyListeners();
      return result.isRight();
    } catch (_) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await loginUsecase(email: email, password: password);

      result.fold(
        (failure) {
          _isAuthenticated = false;
          _userDetails = null;
          _errorMessage = failure.message;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (userDetails) {
          _userDetails = userDetails;
          _isAuthenticated = true;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
          return true;
        },
      );

      return result.isRight();
    } catch (e) {
      _isAuthenticated = false;
      _userDetails = null;
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _isAuthenticated = false;
    _canRetryInitialization = false;
    _user = null;
    _userDetails = null;
    notifyListeners();

    await logoutUsecase();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    final result = await getCurrentUserUsecase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _user = user;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
