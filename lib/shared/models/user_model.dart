import 'package:equatable/equatable.dart';
import '../entities/user_entity.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    required this.createdAt,
  });

  /// Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profileImage: json['profileImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      profileImage: profileImage,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, profileImage, createdAt];
}
