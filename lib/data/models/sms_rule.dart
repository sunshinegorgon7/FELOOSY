class SmsRule {
  final int? id;
  final String keyword;
  final String? description;
  final String categoryUuid;
  final String transactionType;
  final List<int> accountIds;
  final String? amountRegex;
  final bool isActive;
  final DateTime createdAt;

  const SmsRule({
    this.id,
    required this.keyword,
    this.description,
    required this.categoryUuid,
    required this.transactionType,
    required this.accountIds,
    this.amountRegex,
    this.isActive = true,
    required this.createdAt,
  });

  String get transactionDescription => description?.isNotEmpty == true ? description! : keyword;

  SmsRule copyWith({
    String? keyword,
    String? description,
    bool clearDescription = false,
    String? categoryUuid,
    String? transactionType,
    List<int>? accountIds,
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
      accountIds: accountIds ?? this.accountIds,
      amountRegex: clearAmountRegex ? null : (amountRegex ?? this.amountRegex),
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  factory SmsRule.fromMap(Map<String, dynamic> map, {List<int>? accountIds}) {
    return SmsRule(
      id: map['id'] as int?,
      keyword: map['keyword'] as String,
      description: map['description'] as String?,
      categoryUuid: map['category_uuid'] as String,
      transactionType: map['transaction_type'] as String,
      accountIds: accountIds ?? [map['account_id'] as int? ?? 1],
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
      'amount_regex': amountRegex,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}
