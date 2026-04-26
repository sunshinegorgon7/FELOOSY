import 'package:flutter/material.dart';
import '../../data/models/category.dart';

// Stable hardcoded UUIDs — must never change, as transactions reference them.
// Using deterministic IDs prevents category-UUID drift across reinstalls.
const kDefaultCategoryUuids = [
  '00000000-0000-0000-0000-000000000001', // Groceries
  '00000000-0000-0000-0000-000000000002', // Dining Out
  '00000000-0000-0000-0000-000000000003', // Coffee
  '00000000-0000-0000-0000-000000000004', // Transport
  '00000000-0000-0000-0000-000000000005', // Fuel
  '00000000-0000-0000-0000-000000000006', // Utilities
  '00000000-0000-0000-0000-000000000007', // Rent / Housing
  '00000000-0000-0000-0000-000000000008', // Healthcare
  '00000000-0000-0000-0000-000000000009', // Pharmacy
  '00000000-0000-0000-0000-000000000010', // Shopping
  '00000000-0000-0000-0000-000000000011', // Entertainment
  '00000000-0000-0000-0000-000000000012', // Sports / Gym
  '00000000-0000-0000-0000-000000000013', // Travel
  '00000000-0000-0000-0000-000000000014', // Salary
  '00000000-0000-0000-0000-000000000015', // Cashback
  '00000000-0000-0000-0000-000000000016', // Refund
];

// Parallel list of (name, icon, color) — index must match _kUuids above.
const kDefaultCategoryData = [
  ('Groceries',     Icons.shopping_cart,          Color(0xFF4CAF50)),
  ('Dining Out',    Icons.restaurant,              Color(0xFFFF7043)),
  ('Coffee',        Icons.coffee,                  Color(0xFF795548)),
  ('Transport',     Icons.directions_car,          Color(0xFF2196F3)),
  ('Fuel',          Icons.local_gas_station,       Color(0xFF607D8B)),
  ('Utilities',     Icons.bolt,                    Color(0xFFFFEB3B)),
  ('Rent / Housing',Icons.home,                    Color(0xFF9C27B0)),
  ('Healthcare',    Icons.local_hospital,          Color(0xFFF44336)),
  ('Pharmacy',      Icons.medication,              Color(0xFFE91E63)),
  ('Shopping',      Icons.shopping_bag,            Color(0xFFFF9800)),
  ('Entertainment', Icons.movie,                   Color(0xFF673AB7)),
  ('Sports / Gym',  Icons.fitness_center,          Color(0xFF00BCD4)),
  ('Travel',        Icons.flight,                  Color(0xFF03A9F4)),
  ('Salary',        Icons.account_balance_wallet,  Color(0xFF43A047)),
  ('Cashback',      Icons.card_giftcard,           Color(0xFF8BC34A)),
  ('Refund',        Icons.replay,                  Color(0xFF009688)),
];

List<Category> buildDefaultCategories() {
  final now = DateTime.now();
  return kDefaultCategoryData.indexed.map((entry) {
    final (index, (name, icon, color)) = entry;
    return Category(
      uuid: kDefaultCategoryUuids[index],
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
