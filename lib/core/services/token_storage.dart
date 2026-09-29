import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class TokenStorage {
  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }
}
