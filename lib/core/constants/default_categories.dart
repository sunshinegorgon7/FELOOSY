import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category.dart';

List<Category> buildDefaultCategories() {
  const uuid = Uuid();
  final now = DateTime.now();

  final data = [
    // Essential living
    ('Groceries', Icons.shopping_cart, const Color(0xFF4CAF50)),
    ('Dining Out', Icons.restaurant, const Color(0xFFFF7043)),
    ('Coffee', Icons.coffee, const Color(0xFF795548)),
    ('Transport', Icons.directions_car, const Color(0xFF2196F3)),
    ('Fuel', Icons.local_gas_station, const Color(0xFF607D8B)),
    ('Utilities', Icons.bolt, const Color(0xFFFFEB3B)),
    ('Rent / Housing', Icons.home, const Color(0xFF9C27B0)),
    ('Healthcare', Icons.local_hospital, const Color(0xFFF44336)),
    ('Pharmacy', Icons.medication, const Color(0xFFE91E63)),
    // Lifestyle
    ('Shopping', Icons.shopping_bag, const Color(0xFFFF9800)),
    ('Entertainment', Icons.movie, const Color(0xFF673AB7)),
    ('Sports / Gym', Icons.fitness_center, const Color(0xFF00BCD4)),
    ('Travel', Icons.flight, const Color(0xFF03A9F4)),
    // Income / returns
    ('Salary', Icons.account_balance_wallet, const Color(0xFF43A047)),
    ('Cashback', Icons.card_giftcard, const Color(0xFF8BC34A)),
    ('Refund', Icons.replay, const Color(0xFF009688)),
    // Catch-all
    ('Other', Icons.more_horiz, const Color(0xFF9E9E9E)),
  ];

  return data.indexed.map((entry) {
    final (index, (name, icon, color)) = entry;
    return Category(
      uuid: uuid.v4(),
      name: name,
      colorValue: color.toARGB32(),
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
      isCustom: false,
      isActive: true,
      sortOrder: index,
      createdAt: now,
    );
  }).toList();
}
