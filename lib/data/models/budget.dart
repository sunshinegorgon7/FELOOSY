class Budget {
  final int? id;
  final int year;
  final int month;
  final int accountId;
  final double amount;
  final String currencyCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    this.id,
    required this.year,
    required this.month,
    required this.accountId,
    required this.amount,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
  });

  Budget copyWith({double? amount, String? currencyCode}) {
    return Budget(
      id: id,
      year: year,
      month: month,
      accountId: accountId,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      year: map['year'] as int,
      month: map['month'] as int,
      accountId: map['account_id'] as int? ?? 1,
      amount: (map['amount'] as num).toDouble(),
      currencyCode: map['currency_code'] as String,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'year': year,
      'month': month,
      'account_id': accountId,
      'amount': amount,
      'currency_code': currencyCode,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}
