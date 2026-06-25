import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app/app_flavor.dart';

const _trialStartKey = 'feloosy_trial_start_ms';
const _trialOptOutKey = 'feloosy_trial_opt_out';
const _kTrialDays = 14;

class TrialState {
  final DateTime? startDate;
  final bool isOptedOut;
  const TrialState({this.startDate, this.isOptedOut = false});

  bool get hasStarted => startDate != null;
  bool get isActive =>
      hasStarted &&
      !isOptedOut &&
      DateTime.now().difference(startDate!).inDays < _kTrialDays;
  bool get hasExpired => hasStarted && !isActive;
  int get daysRemaining =>
      (hasStarted && !isOptedOut &&
          DateTime.now().difference(startDate!).inDays < _kTrialDays)
          ? _kTrialDays - DateTime.now().difference(startDate!).inDays
          : 0;
}

final trialProvider =
    AsyncNotifierProvider<TrialNotifier, TrialState>(TrialNotifier.new);

class TrialNotifier extends AsyncNotifier<TrialState> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<TrialState> build() async {
    if (AppFlavor.isDev) return const TrialState();

    final optedOut = await _storage.read(key: _trialOptOutKey) == 'true';

    final raw = await _storage.read(key: _trialStartKey);
    if (raw != null) {
      final ms = int.tryParse(raw);
      if (ms != null) {
        return TrialState(
          startDate: DateTime.fromMillisecondsSinceEpoch(ms),
          isOptedOut: optedOut,
        );
      }
    }

    // First prod launch: record trial start.
    final now = DateTime.now();
    await _storage.write(
        key: _trialStartKey, value: '${now.millisecondsSinceEpoch}');
    return TrialState(startDate: now);
  }

  Future<void> endTrialEarly() async {
    await _storage.write(key: _trialOptOutKey, value: 'true');
    ref.invalidateSelf();
  }

  Future<void> restartTrial() async {
    await _storage.delete(key: _trialOptOutKey);
    ref.invalidateSelf();
  }
}
