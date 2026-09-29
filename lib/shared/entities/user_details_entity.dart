import 'package:equatable/equatable.dart';

class UserDetailsEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String email;
    final String userId;

  const UserDetailsEntity({
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.email,
      required this.userId,
  });

  @override
    List<Object?> get props => [userId, firstName, lastName, mobileNumber, email];
}
