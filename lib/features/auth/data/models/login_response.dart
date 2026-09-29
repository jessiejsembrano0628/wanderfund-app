import 'package:equatable/equatable.dart';
import '../../../../shared/entities/user_details_entity.dart';

class UserDetails extends Equatable {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String email;

  const UserDetails({
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.email,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      firstName: (json['FirstName'] ??
          json['firstName'] ??
          json['first_name'] ??
          '')
        .toString(),
      lastName: (json['LastName'] ??
          json['lastName'] ??
          json['last_name'] ??
          '')
        .toString(),
      mobileNumber: (json['MobileNumber'] ??
          json['mobileNumber'] ??
          json['mobile_number'] ??
          '')
        .toString(),
      email: (json['Email'] ?? json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'MobileNumber': mobileNumber,
      'Email': email,
    };
  }

  UserDetailsEntity toEntity({required String userId}) {
    return UserDetailsEntity(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      email: email,
    );
  }

  @override
  List<Object?> get props => [firstName, lastName, mobileNumber, email];
}

class LoginResponse extends Equatable {
  final String accessToken;
  final String userId;
  final UserDetails userDetails;

  const LoginResponse({
    required this.accessToken,
    required this.userId,
    required this.userDetails,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json['accessToken'] == null || json['accessToken'].toString().isEmpty) {
      throw FormatException('Invalid login response: accessToken is missing or empty');
    }
    if (json['userDetails'] == null) {
      throw FormatException('Invalid login response: userDetails is missing');
    }
    
    return LoginResponse(
      accessToken: (json['accessToken'] ?? '') as String,
      userId: (json['userId'] ?? '') as String,
      userDetails: UserDetails.fromJson(json['userDetails'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'userId': userId,
      'userDetails': userDetails.toJson(),
    };
  }

  @override
  List<Object?> get props => [accessToken, userId, userDetails];
}
