import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app/app_flavor.dart';

const _trialStartKey = 'feloosy_trial_start_ms';
const _kTrialDays = 14;

class TrialState {
  final DateTime? startDate;
  const TrialState({this.startDate});

  bool get hasStarted => startDate != null;
  bool get isActive =>
      hasStarted &&
      DateTime.now().difference(startDate!).inDays < _kTrialDays;
  bool get hasExpired => hasStarted && !isActive;
  int get daysRemaining =>
      isActive ? _kTrialDays - DateTime.now().difference(startDate!).inDays : 0;
}

final trialProvider =
    AsyncNotifierProvider<TrialNotifier, TrialState>(TrialNotifier.new);

class TrialNotifier extends AsyncNotifier<TrialState> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<TrialState> build() async {
    if (AppFlavor.isDev) return const TrialState();

    final raw = await _storage.read(key: _trialStartKey);
    if (raw != null) {
      final ms = int.tryParse(raw);
      if (ms != null) {
        return TrialState(startDate: DateTime.fromMillisecondsSinceEpoch(ms));
      }
    }

    // First prod launch: record trial start.
    final now = DateTime.now();
    await _storage.write(
        key: _trialStartKey, value: '${now.millisecondsSinceEpoch}');
    return TrialState(startDate: now);
  }
}
