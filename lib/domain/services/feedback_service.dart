import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_info.dart';

class FeedbackService {
  FeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> submit({
    required User user,
    required String type,
    required String message,
    String? replyEmail,
  }) async {
    final payload = <String, dynamic>{
      'type': type,
      'message': message,
      'app_version': kAppVersionLabel,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'status': 'new',
      'source': 'settings',
      'user_uid': user.uid,
      'created_at': FieldValue.serverTimestamp(),
      'created_at_ms': DateTime.now().millisecondsSinceEpoch,
      if ((user.email ?? '').trim().isNotEmpty) 'user_email': user.email!.trim(),
      if ((user.displayName ?? '').trim().isNotEmpty)
        'user_display_name': user.displayName!.trim(),
      if ((replyEmail ?? '').trim().isNotEmpty)
        'reply_email': replyEmail!.trim(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('feedback')
        .add(payload);
  }
}
