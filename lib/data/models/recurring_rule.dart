import 'package:flutter/material.dart' show DateUtils;

enum RecurringFrequency { daily, weekly, monthly, annually }

class RecurringRule {
  final String uuid;
  final int accountId;
  final double amount;
  final String type; // 'expense' | 'income'
  final String description;
  final String categoryUuid;
  final RecurringFrequency frequency;
  final DateTime startDate; // date-only (time zeroed)
  final DateTime? lastGeneratedDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringRule({
    required this.uuid,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.description,
    required this.categoryUuid,
    required this.frequency,
    required this.startDate,
    this.lastGeneratedDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringRule copyWith({
    double? amount,
    String? type,
    String? description,
    String? categoryUuid,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? lastGeneratedDate,
    bool? isActive,
  }) {
    return RecurringRule(
      uuid: uuid,
      accountId: accountId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory RecurringRule.fromMap(Map<String, dynamic> map) {
    return RecurringRule(
      uuid: map['uuid'] as String,
      accountId: map['account_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      description: map['description'] as String,
      categoryUuid: map['category_uuid'] as String,
      frequency: RecurringFrequency.values.byName(map['frequency'] as String),
      startDate: DateUtils.dateOnly(
          DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int)),
      lastGeneratedDate: map['last_generated_date'] != null
          ? DateUtils.dateOnly(DateTime.fromMillisecondsSinceEpoch(
              map['last_generated_date'] as int))
          : null,
      isActive: (map['is_active'] as int) == 1,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'account_id': accountId,
      'amount': amount,
      'type': type,
      'description': description,
      'category_uuid': categoryUuid,
      'frequency': frequency.name,
      'start_date': startDate.millisecondsSinceEpoch,
      'last_generated_date': lastGeneratedDate?.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
