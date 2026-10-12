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

    if (value is DateTime) {
      return value.year <= 1 ? null : value.toLocal();
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    final normalized = raw.replaceAll(RegExp(r'\s+UTC$'), '');
    final goMatch = RegExp(
      r'^(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2}(?:\.\d+)?)'
      r'(?:\s*([+-]\d{2}(?::?\d{2})?))?(?:\s*([+-]\d{2}))?$',
    ).firstMatch(normalized);

    if (goMatch != null) {
      final date = goMatch.group(1)!;
      final time = goMatch.group(2)!;
      final tz = goMatch.group(3) ?? goMatch.group(4);

      String iso = '${date}T$time';
      if (tz != null && tz.isNotEmpty) {
        final normalizedOffset = tz.length == 3
            ? '${tz.substring(0, 3)}:${tz.substring(3)}'
            : tz;
        iso = '$iso$normalizedOffset';
      }

      final parsed = DateTime.tryParse(iso);
      if (parsed == null || parsed.year <= 1) return null;
      return parsed.toLocal();
    }

    final parsed = DateTime.tryParse(normalized);
    if (parsed == null || parsed.year <= 1) return null;

    return parsed.toLocal();
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
