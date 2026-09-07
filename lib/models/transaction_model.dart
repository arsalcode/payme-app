class TransactionModel {
  final String? id;
  final String? userId;
  final String? transactionType; // 'topup', 'transfer_in', 'transfer_out', 'payment'
  final String? title;
  final int? amount;
  final String? status;
  final DateTime? createdAt;

  TransactionModel({
    this.id,
    this.userId,
    this.transactionType,
    this.title,
    this.amount,
    this.status,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      transactionType: json['transaction_type'],
      title: json['title'],
      amount: json['amount'] is int
          ? json['amount']
          : (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? 'success',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'transaction_type': transactionType,
      'title': title,
      'amount': amount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
