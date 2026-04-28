enum TransactionType { expense, income }

class Transaction {
  final int? id;
  final String uuid;
  final int accountId;
  final double amount;
  final TransactionType type;
  final String description;
  final String categoryUuid;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.uuid,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.description,
    required this.categoryUuid,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    double? amount,
    TransactionType? type,
    String? description,
    String? categoryUuid,
    DateTime? transactionDate,
  }) {
    return Transaction(
      id: id,
      uuid: uuid,
      accountId: accountId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      accountId: map['account_id'] as int? ?? 1,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      description: map['description'] as String,
      categoryUuid: map['category_uuid'] as String,
      transactionDate: DateTime.fromMillisecondsSinceEpoch(
          map['transaction_date'] as int),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'uuid': uuid,
      'account_id': accountId,
      'amount': amount,
      'type': type.name,
      'description': description,
      'category_uuid': categoryUuid,
      'transaction_date': transactionDate.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}
