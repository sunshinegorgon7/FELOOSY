import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits today's local date (time stripped to midnight) and re-emits each time
/// the calendar day rolls over at local midnight. Depending on this provider
/// instead of calling [DateTime.now()] directly ensures that period providers
/// switch at local midnight even when the app stays open overnight — not at UTC
/// midnight or whenever the next unrelated rebuild happens to fire.
final currentDateProvider = StreamProvider<DateTime>((ref) async* {
  yield DateUtils.dateOnly(DateTime.now());

  while (true) {
    final now = DateTime.now();
    final nextMidnight = DateUtils.dateOnly(now).add(const Duration(days: 1));
    // +1s buffer so we never fire fractionally early due to timer drift.
    await Future<void>.delayed(
        nextMidnight.difference(now) + const Duration(seconds: 1));
    yield DateUtils.dateOnly(DateTime.now());
  }
});
