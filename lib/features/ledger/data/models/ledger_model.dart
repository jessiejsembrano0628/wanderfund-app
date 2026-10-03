import 'package:equatable/equatable.dart';

class TransactionEntry extends Equatable {
  final String id;
  final String travelFundId;
  final String referenceId;
  final String description;
  final double amount;
  final String initiatedBy;
  final String status;
  final String rejectReason;
  final DateTime? createdAt;

  const TransactionEntry({
    required this.id,
    required this.travelFundId,
    required this.referenceId,
    required this.description,
    required this.amount,
    this.initiatedBy = '',
    required this.status,
    this.rejectReason = '',
    this.createdAt,
  });

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      id: (json['id'] ?? json['transaction_id'] ?? '').toString(),
      travelFundId: (json['travel_fund_id'] ?? '').toString(),
      referenceId: (json['reference_id'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      initiatedBy: (json['initiated_by'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      rejectReason: (json['reject_reason'] ?? '').toString(),
      createdAt: _toDateTime(
        json['date_created'] ??
            json['created_at'] ??
            json['createdAt'] ??
            json['created_date'] ??
            json['date'] ??
            json['timestamp'],
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      final milliseconds = value.abs() < 100000000000
          ? (value * 1000).round()
          : value.round();
      return DateTime.fromMillisecondsSinceEpoch(
        milliseconds,
        isUtc: true,
      ).toLocal();
    }
    final text = value.toString();
    final goTimestamp = RegExp(
      r'^(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}(?:\.\d+)?) ([+-]\d{4})',
    ).firstMatch(text);
    if (goTimestamp != null) {
      final offset = goTimestamp.group(3)!;
      final isoOffset = '${offset.substring(0, 3)}:${offset.substring(3)}';
      return DateTime.tryParse(
        '${goTimestamp.group(1)}T${goTimestamp.group(2)}$isoOffset',
      )?.toLocal();
    }
    return DateTime.tryParse(text)?.toLocal();
  }

  @override
  List<Object?> get props => [
    id,
    travelFundId,
    referenceId,
    description,
    amount,
    initiatedBy,
    status,
    rejectReason,
    createdAt,
  ];
}

class LedgerMember extends Equatable {
  final String id;
  final String name;
  final String role;
  final String email;

  const LedgerMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });

  factory LedgerMember.fromJson(Map<String, dynamic> json) {
    return LedgerMember(
      id: (json['UserID'] ?? json['user_id'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? '').toString(),
      role: (json['Role'] ?? json['role'] ?? '').toString(),
      email: (json['Email'] ?? json['email'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [name, role, email];
}

class JoinRequest extends Equatable {
  final String id;
  final String name;
  final String email;
  final String status;

  const JoinRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  JoinRequest withStatus(String nextStatus) {
    return JoinRequest(id: id, name: name, email: email, status: nextStatus);
  }

  @override
  List<Object?> get props => [id, name, email, status];
}

class Ledger extends Equatable {
  final String publicId;
  final double runningBalance;
  final List<TransactionEntry> transactions;

  const Ledger({
    required this.publicId,
    required this.runningBalance,
    required this.transactions,
  });

  factory Ledger.fromJson(Map<String, dynamic> json) {
    final transactions = json['transactions'];
    if (transactions == null) {
      return Ledger(
        publicId: (json['public_id'] ?? '').toString(),
        runningBalance: TransactionEntry._toDouble(json['running_balance']),
        transactions: const [],
      );
    }
    if (transactions is! List) {
      throw const FormatException(
        'Invalid ledger response: transactions is missing',
      );
    }

    return Ledger(
      publicId: (json['public_id'] ?? '').toString(),
      runningBalance: TransactionEntry._toDouble(json['running_balance']),
      transactions: transactions
          .map(
            (item) => TransactionEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [publicId, runningBalance, transactions];
}
