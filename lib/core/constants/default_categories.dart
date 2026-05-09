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
  '00000000-0000-0000-0000-000000000017', // Reimbursement
  '00000000-0000-0000-0000-000000000018', // Insurance
];

// (name, icon, color, transactionType)
const kDefaultCategoryData = [
  ('Groceries',      Icons.shopping_cart,          Color(0xFF5FB574), 'expense'),
  ('Dining Out',     Icons.restaurant,              Color(0xFFF5A623), 'expense'),
  ('Coffee',         Icons.coffee,                  Color(0xFFC4821A), 'expense'),
  ('Transport',      Icons.directions_car,          Color(0xFF7FA890), 'expense'),
  ('Fuel',           Icons.local_gas_station,       Color(0xFFA89070), 'expense'),
  ('Utilities',      Icons.bolt,                    Color(0xFFF5D623), 'expense'),
  ('Rent / Housing', Icons.home,                    Color(0xFF9A7FB0), 'expense'),
  ('Healthcare',     Icons.thermostat,              Color(0xFFE58040), 'expense'),
  ('Pharmacy',       Icons.medication,              Color(0xFFD96A8A), 'expense'),
  ('Shopping',       Icons.shopping_bag,            Color(0xFFE08A10), 'expense'),
  ('Entertainment',  Icons.movie,                   Color(0xFFA87FC4), 'expense'),
  ('Sports / Gym',   Icons.fitness_center,          Color(0xFF5FB5A8), 'expense'),
  ('Travel',         Icons.flight,                  Color(0xFF7FB5D9), 'expense'),
  ('Salary',         Icons.account_balance_wallet,  Color(0xFF5FB574), 'income'),
  ('Cashback',       Icons.card_giftcard,           Color(0xFFB5D95F), 'income'),
  ('Refund',         Icons.replay,                  Color(0xFF5FB5D9), 'income'),
  ('Reimbursement',  Icons.receipt_long,            Color(0xFF7FB5A8), 'income'),
  ('Insurance',      Icons.health_and_safety,       Color(0xFF6BA8D9), 'income'),
];

List<Category> buildDefaultCategories() {
  final now = DateTime.now();
  return kDefaultCategoryData.indexed.map((entry) {
    final (index, (name, icon, color, type)) = entry;
    return Category(
      uuid: kDefaultCategoryUuids[index],
      name: name,
      colorValue: color.toARGB32(),
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
      isCustom: false,
      isActive: true,
      sortOrder: index,
      transactionType: type,
      createdAt: now,
    );
  }).toList();
}
