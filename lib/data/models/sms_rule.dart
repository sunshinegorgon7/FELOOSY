class SmsRule {
  final int? id;
  final String keyword;
  final String? description;
  final String categoryUuid;
  final String transactionType;
  final int accountId;
  final String? amountRegex;
  final bool isActive;
  final DateTime createdAt;

  const SmsRule({
    this.id,
    required this.keyword,
    this.description,
    required this.categoryUuid,
    required this.transactionType,
    required this.accountId,
    this.amountRegex,
    this.isActive = true,
    required this.createdAt,
  });

  /// The label used as the transaction description when this rule fires.
  /// Falls back to the keyword when no custom description is set.
  String get transactionDescription => description?.isNotEmpty == true ? description! : keyword;

  SmsRule copyWith({
    String? keyword,
    String? description,
    bool clearDescription = false,
    String? categoryUuid,
    String? transactionType,
    int? accountId,
    String? amountRegex,
    bool? isActive,
    bool clearAmountRegex = false,
  }) {
    return SmsRule(
      id: id,
      keyword: keyword ?? this.keyword,
      description: clearDescription ? null : (description ?? this.description),
      categoryUuid: categoryUuid ?? this.categoryUuid,
      transactionType: transactionType ?? this.transactionType,
      accountId: accountId ?? this.accountId,
      amountRegex: clearAmountRegex ? null : (amountRegex ?? this.amountRegex),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  factory SmsRule.fromMap(Map<String, dynamic> map) {
    return SmsRule(
      id: map['id'] as int?,
      keyword: map['keyword'] as String,
      description: map['description'] as String?,
      categoryUuid: map['category_uuid'] as String,
      transactionType: map['transaction_type'] as String,
      accountId: map['account_id'] as int? ?? 1,
      amountRegex: map['amount_regex'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'keyword': keyword,
      'description': description,
      'category_uuid': categoryUuid,
      'transaction_type': transactionType,
      'account_id': accountId,
      'amount_regex': amountRegex,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}
