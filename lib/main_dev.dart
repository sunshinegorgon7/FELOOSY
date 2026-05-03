import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/app_flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFlavor.initialize(Flavor.dev);
  runApp(const ProviderScope(child: FeloosyApp()));
}
