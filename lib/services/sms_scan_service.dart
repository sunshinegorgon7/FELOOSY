import 'dart:io';

import 'package:flutter/services.dart';

class SmsMessage {
  final String body;
  final String sender;
  final DateTime date;

  const SmsMessage({
    required this.body,
    required this.sender,
    required this.date,
  });
}

class SmsScanService {
  static const _channel = MethodChannel('com.feloosy/sms_inbox');

  /// Reads SMS inbox messages whose timestamp falls within [from]..[to].
  /// Throws [PlatformException] on permission denial or read error.
  static Future<List<SmsMessage>> readInbox({
    required DateTime from,
    required DateTime to,
  }) async {
    if (!Platform.isAndroid) return const [];

    final List<dynamic> raw = await _channel.invokeMethod('scan', {
      'from': from.millisecondsSinceEpoch,
      'to': to.millisecondsSinceEpoch,
    });

    return raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return SmsMessage(
        body: m['body'] as String? ?? '',
        sender: m['sender'] as String? ?? '',
        date: DateTime.fromMillisecondsSinceEpoch(
          (m['date'] as num).toInt(),
        ),
      );
    }).toList();
  }
}
