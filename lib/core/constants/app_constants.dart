class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  static const String travelFundCommandBaseUrl = 'http://localhost:8080/api';
  static const String apiVersion = 'v1';
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // Endpoints
  static const String loginEndpoint = '$baseUrl/$apiVersion/login';
  static const String registerEndpoint = '$baseUrl/$apiVersion/register';
  static const String logoutEndpoint = '$baseUrl/$apiVersion/logout';
  static const String getUserEndpoint = '$baseUrl/$apiVersion/user';
  static String travelFundsEndpoint(String userId) =>
      '$baseUrl/$apiVersion/wanderfund/$userId';
  static String travelFundInviteEndpoint(String publicId) =>
      '$baseUrl/$apiVersion/wanderfund/invite/$publicId';
  static String ledgerEndpoint(String publicId) =>
      '$baseUrl/$apiVersion/wanderfund/generate/$publicId/ledger';
  static String membersEndpoint(String publicId) =>
      '$baseUrl/$apiVersion/wanderfund/$publicId/members';
  static String groupJoinRequestEndpoint(String publicId) =>
      '$baseUrl/$apiVersion/wanderfund/group-join-request/$publicId';
  static String approveGroupJoinRequestEndpoint(String publicId) =>
      '$baseUrl/$apiVersion/wanderfund/group-join-request/$publicId/approve';
  static String rejectGroupJoinRequestEndpoint(String publicId) =>
      '$baseUrl/$apiVersion/wanderfund/group-join-request/$publicId/reject';
  static const String createTransactionEndpoint =
      '$baseUrl/$apiVersion/wanderfund/transactions/create';
  static String transactionApprovalRequestsEndpoint(
    String publicId, {
    required String status,
  }) =>
      '$baseUrl/$apiVersion/wanderfund/transactions/$publicId/approval-requests?status=$status';
  static const String approveTransactionEndpoint =
      '$baseUrl/$apiVersion/wanderfund/transactions/approve';
  static const String rejectTransactionEndpoint =
      '$baseUrl/$apiVersion/wanderfund/transactions/reject';
  static const String createTravelFundEndpoint =
      '$travelFundCommandBaseUrl/$apiVersion/wanderfund/create-travel-fund';
  static String joinTravelFundEndpoint(String inviteCode) =>
      '$travelFundCommandBaseUrl/$apiVersion/wanderfund/join-travel-fund/$inviteCode';
  static String archiveTravelFundEndpoint(String publicId) =>
      '$travelFundCommandBaseUrl/$apiVersion/wanderfund/archive/$publicId';

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String unexpectedError = 'An unexpected error occurred.';

  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
