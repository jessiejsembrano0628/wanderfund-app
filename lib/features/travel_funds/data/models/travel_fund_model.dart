import 'package:equatable/equatable.dart';

class TravelFund extends Equatable {
  final String role;
  final String publicId;
  final String travelFundName;
  final String status;
  final String description;
  final DateTime? createdAt;
  final DateTime? travelDate;

  const TravelFund({
    required this.role,
    required this.publicId,
    required this.travelFundName,
    required this.status,
    this.description = '',
    this.createdAt,
    this.travelDate,
  });

  factory TravelFund.fromJson(Map<String, dynamic> json) {
    return TravelFund(
      role: (json['Role'] ?? json['role'] ?? '').toString(),
      publicId: (json['PublicID'] ?? json['public_id'] ?? '').toString(), 
      travelFundName: (json['TravelFundName'] ?? json['travel_fund_name'] ?? '').toString(),
      status: (json['Status'] ?? json['status'] ?? '').toString(),
      description: (json['Description'] ?? json['description'] ?? '').toString(),
      createdAt: _parseDateTime(
        json['CreatedAt'] ?? json['created_at'] ?? json['createdAt'],
      ),
      travelDate: _parseDateTime(
        json['TravelDate'] ?? json['travel_date'] ?? json['travelDate'],
      ),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  @override
  List<Object?> get props => [
    role,
    publicId,
    travelFundName,
    status,
    description,
    createdAt,
    travelDate,
  ];
}
