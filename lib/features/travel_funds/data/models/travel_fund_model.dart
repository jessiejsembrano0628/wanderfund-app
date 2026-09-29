import 'package:equatable/equatable.dart';

class TravelFund extends Equatable {
  final String role;
  final String publicId;
  final String travelFundName;
  final String status;

  const TravelFund({
    required this.role,
    required this.publicId,
    required this.travelFundName,
    required this.status,
  });

  factory TravelFund.fromJson(Map<String, dynamic> json) {
    return TravelFund(
      role: (json['Role'] ?? json['role'] ?? '').toString(),
      publicId: (json['PublicID'] ?? json['public_id'] ?? '').toString(), 
      travelFundName: (json['TravelFundName'] ?? json['travel_fund_name'] ?? '').toString(),
      status: (json['Status'] ?? json['status'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [role, publicId, status];
}
