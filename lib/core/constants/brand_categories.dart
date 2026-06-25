import 'package:flutter/material.dart';
import '../../data/models/category.dart';

// Stable UUIDs for brand categories — never change once deployed.
// Sequential from ...000019 (after the 18 default categories).
const kBrandCategoryUuids = [
  // AED – UAE
  '00000000-0000-0000-0000-000000000019', // Amazon AE
  '00000000-0000-0000-0000-000000000020', // Noon
  '00000000-0000-0000-0000-000000000021', // Talabat
  '00000000-0000-0000-0000-000000000022', // Careem
  '00000000-0000-0000-0000-000000000023', // LuLu Hypermarket
  // SAR – Saudi Arabia
  '00000000-0000-0000-0000-000000000024', // Amazon SA
  '00000000-0000-0000-0000-000000000025', // Noon SA
  '00000000-0000-0000-0000-000000000026', // HungerStation
  '00000000-0000-0000-0000-000000000027', // Jarir
  '00000000-0000-0000-0000-000000000028', // Extra
  // USD – United States
  '00000000-0000-0000-0000-000000000029', // Amazon US
  '00000000-0000-0000-0000-000000000030', // Walmart
  '00000000-0000-0000-0000-000000000031', // Target
  '00000000-0000-0000-0000-000000000032', // DoorDash
  '00000000-0000-0000-0000-000000000033', // Uber Eats
  // GBP – United Kingdom
  '00000000-0000-0000-0000-000000000034', // Amazon UK
  '00000000-0000-0000-0000-000000000035', // Tesco
  '00000000-0000-0000-0000-000000000036', // ASOS
  '00000000-0000-0000-0000-000000000037', // Deliveroo
  '00000000-0000-0000-0000-000000000038', // Just Eat
  // EUR – Eurozone
  '00000000-0000-0000-0000-000000000039', // Amazon EU
  '00000000-0000-0000-0000-000000000040', // Zalando
  '00000000-0000-0000-0000-000000000041', // Glovo
  '00000000-0000-0000-0000-000000000042', // Spotify
  '00000000-0000-0000-0000-000000000043', // Booking.com
  // INR – India
  '00000000-0000-0000-0000-000000000044', // Amazon IN
  '00000000-0000-0000-0000-000000000045', // Flipkart
  '00000000-0000-0000-0000-000000000046', // Swiggy
  '00000000-0000-0000-0000-000000000047', // Zomato
  '00000000-0000-0000-0000-000000000048', // Myntra
  // EGP – Egypt
  '00000000-0000-0000-0000-000000000049', // Amazon EG
  '00000000-0000-0000-0000-000000000050', // Talabat EG
  '00000000-0000-0000-0000-000000000051', // Vodafone
  '00000000-0000-0000-0000-000000000052', // Careem EG
  '00000000-0000-0000-0000-000000000053', // Noon EG
  // PKR – Pakistan
  '00000000-0000-0000-0000-000000000054', // Daraz
  '00000000-0000-0000-0000-000000000055', // Foodpanda
  '00000000-0000-0000-0000-000000000056', // Careem PK
  '00000000-0000-0000-0000-000000000057', // Jazz
  '00000000-0000-0000-0000-000000000058', // Bykea
  // NGN – Nigeria
  '00000000-0000-0000-0000-000000000059', // Jumia
  '00000000-0000-0000-0000-000000000060', // Konga
  '00000000-0000-0000-0000-000000000061', // Glovo NG
  '00000000-0000-0000-0000-000000000062', // Bolt Food
  '00000000-0000-0000-0000-000000000063', // Opay
  // BRL – Brazil
  '00000000-0000-0000-0000-000000000064', // Mercado Livre
  '00000000-0000-0000-0000-000000000065', // iFood
  '00000000-0000-0000-0000-000000000066', // Amazon BR
  '00000000-0000-0000-0000-000000000067', // Magazine Luiza
  '00000000-0000-0000-0000-000000000068', // Americanas
];

// (name, fallbackIcon, color, currencyHint, logoDomain)
// logoDomain is passed to https://logo.clearbit.com/{domain}
const kBrandCategoryData = [
  // AED – UAE
  ('Amazon',           Icons.storefront,       Color(0xFF7A6040), 'AED', 'amazon.ae'),
  ('Noon',             Icons.storefront,       Color(0xFF8A7A2E), 'AED', 'noon.com'),
  ('Talabat',          Icons.delivery_dining,  Color(0xFF9A4A2A), 'AED', 'talabat.com'),
  ('Careem',           Icons.directions_car,   Color(0xFF3A7A58), 'AED', 'careem.com'),
  ('LuLu',             Icons.shopping_cart,    Color(0xFF8A3A40), 'AED', 'gcc.luluhypermarket.com'),
  // SAR – Saudi Arabia
  ('Amazon',           Icons.storefront,       Color(0xFF7A6040), 'SAR', 'amazon.sa'),
  ('Noon',             Icons.storefront,       Color(0xFF8A7A2E), 'SAR', 'noon.com'),
  ('HungerStation',    Icons.delivery_dining,  Color(0xFF9A4A2A), 'SAR', 'hungerstation.com'),
  ('Jarir',            Icons.menu_book,        Color(0xFF4A6A8A), 'SAR', 'jarir.com'),
  ('Extra',            Icons.devices,          Color(0xFF5A508A), 'SAR', 'extrastores.com'),
  // USD – United States
  ('Amazon',           Icons.storefront,       Color(0xFF7A6040), 'USD', 'amazon.com'),
  ('Walmart',          Icons.storefront,       Color(0xFF4A6A8A), 'USD', 'walmart.com'),
  ('Target',           Icons.storefront,       Color(0xFF8A3040), 'USD', 'target.com'),
  ('DoorDash',         Icons.delivery_dining,  Color(0xFF9A3040), 'USD', 'doordash.com'),
  ('Uber Eats',        Icons.delivery_dining,  Color(0xFF4A5A4A), 'USD', 'ubereats.com'),
  // GBP – United Kingdom
  ('Amazon UK',        Icons.storefront,       Color(0xFF7A6040), 'GBP', 'amazon.co.uk'),
  ('Tesco',            Icons.shopping_cart,    Color(0xFF3A6A4A), 'GBP', 'tesco.com'),
  ('ASOS',             Icons.shopping_bag,     Color(0xFF3A3A4A), 'GBP', 'asos.com'),
  ('Deliveroo',        Icons.delivery_dining,  Color(0xFF3A7A70), 'GBP', 'deliveroo.com'),
  ('Just Eat',         Icons.delivery_dining,  Color(0xFF9A5A2A), 'GBP', 'just-eat.co.uk'),
  // EUR – Eurozone
  ('Amazon',           Icons.storefront,       Color(0xFF7A6040), 'EUR', 'amazon.de'),
  ('Zalando',          Icons.shopping_bag,     Color(0xFF9A5A2A), 'EUR', 'zalando.com'),
  ('Glovo',            Icons.delivery_dining,  Color(0xFF8A7A2E), 'EUR', 'glovoapp.com'),
  ('Spotify',          Icons.music_note,       Color(0xFF3A7A50), 'EUR', 'spotify.com'),
  ('Booking.com',      Icons.hotel,            Color(0xFF4A5A8A), 'EUR', 'booking.com'),
  // INR – India
  ('Amazon',           Icons.storefront,       Color(0xFF7A6040), 'INR', 'amazon.in'),
  ('Flipkart',         Icons.storefront,       Color(0xFF4A5A8A), 'INR', 'flipkart.com'),
  ('Swiggy',           Icons.delivery_dining,  Color(0xFF9A5A2A), 'INR', 'swiggy.com'),
  ('Zomato',           Icons.delivery_dining,  Color(0xFF9A3A40), 'INR', 'zomato.com'),
  ('Myntra',           Icons.shopping_bag,     Color(0xFF8A5A70), 'INR', 'myntra.com'),
  // EGP – Egypt
  ('Amazon',           Icons.storefront,       Color(0xFF7A6040), 'EGP', 'amazon.eg'),
  ('Talabat',          Icons.delivery_dining,  Color(0xFF9A4A2A), 'EGP', 'talabat.com'),
  ('Vodafone',         Icons.phone_android,    Color(0xFF8A3A40), 'EGP', 'vodafone.com'),
  ('Careem',           Icons.directions_car,   Color(0xFF3A7A58), 'EGP', 'careem.com'),
  ('Noon',             Icons.storefront,       Color(0xFF8A7A2E), 'EGP', 'noon.com'),
  // PKR – Pakistan
  ('Daraz',            Icons.storefront,       Color(0xFF9A5A2A), 'PKR', 'daraz.com'),
  ('Foodpanda',        Icons.delivery_dining,  Color(0xFF8A3A6A), 'PKR', 'foodpanda.com'),
  ('Careem',           Icons.directions_car,   Color(0xFF3A7A58), 'PKR', 'careem.com'),
  ('Jazz',             Icons.phone_android,    Color(0xFF8A3A40), 'PKR', 'jazz.com.pk'),
  ('Bykea',            Icons.directions_bike,  Color(0xFF3A7A58), 'PKR', 'bykea.com'),
  // NGN – Nigeria
  ('Jumia',            Icons.storefront,       Color(0xFF9A5A2A), 'NGN', 'jumia.com.ng'),
  ('Konga',            Icons.storefront,       Color(0xFF9A3A40), 'NGN', 'konga.com'),
  ('Glovo',            Icons.delivery_dining,  Color(0xFF8A7A2E), 'NGN', 'glovoapp.com'),
  ('Bolt Food',        Icons.delivery_dining,  Color(0xFF3A7A58), 'NGN', 'bolt.eu'),
  ('Opay',             Icons.account_balance_wallet, Color(0xFF3A7A50), 'NGN', 'opayweb.com'),
  // BRL – Brazil
  ('Mercado Livre',    Icons.storefront,       Color(0xFF8A7A2E), 'BRL', 'mercadolivre.com.br'),
  ('iFood',            Icons.delivery_dining,  Color(0xFF9A3A40), 'BRL', 'ifood.com.br'),
  ('Amazon',           Icons.storefront,       Color(0xFF7A6040), 'BRL', 'amazon.com.br'),
  ('Magalu',           Icons.storefront,       Color(0xFF4A5A8A), 'BRL', 'magazineluiza.com.br'),
  ('Americanas',       Icons.storefront,       Color(0xFF8A3A40), 'BRL', 'americanas.com.br'),
];

List<Category> buildBrandCategories() {
  final now = DateTime.now();
  return kBrandCategoryData.indexed.map((entry) {
    final (index, (name, icon, color, currencyHint, _)) = entry;
    return Category(
      uuid: kBrandCategoryUuids[index],
      name: name,
      colorValue: color.toARGB32(),
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
      isCustom: false,
      isActive: true,
      sortOrder: 1000 + index,
      transactionType: 'expense',
      createdAt: now,
      currencyHint: currencyHint,
    );
  }).toList();
}
