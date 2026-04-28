import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_info.dart';
import '../../domain/services/feedback_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firebase_sync_provider.dart';

enum FeedbackType { bug, idea, question }

Future<bool?> showFeedbackSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _FeedbackSheet(),
  );
}

class _FeedbackSheet extends ConsumerStatefulWidget {
  const _FeedbackSheet();

  @override
  ConsumerState<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<_FeedbackSheet> {
  final _messageCtrl = TextEditingController();
  final _replyEmailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _service = FeedbackService();

  FeedbackType _type = FeedbackType.bug;
  bool _sending = false;
  bool _authBusy = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if ((user?.email ?? '').trim().isNotEmpty) {
      _replyEmailCtrl.text = user!.email!.trim();
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _replyEmailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: user == null
              ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Send feedback', style: tt.titleLarge),
                  const Gap(8),
                  Text(
                    'Sign in with Google to send feedback securely from inside the app.',
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const Gap(20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _authBusy ? null : _signIn,
                      icon: _authBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(_authBusy ? 'Signing in...' : 'Sign in'),
                    ),
                  ),
                ],
              )
              : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send feedback', style: tt.titleLarge),
                    const Gap(8),
                    Text(
                      'Share a bug, idea, or question. We will store it privately in your synced account.',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const Gap(16),
                    SegmentedButton<FeedbackType>(
                      segments: const [
                        ButtonSegment(
                          value: FeedbackType.bug,
                          icon: Icon(Icons.bug_report_outlined),
                          label: Text('Bug'),
                        ),
                        ButtonSegment(
                          value: FeedbackType.idea,
                          icon: Icon(Icons.lightbulb_outline),
                          label: Text('Idea'),
                        ),
                        ButtonSegment(
                          value: FeedbackType.question,
                          icon: Icon(Icons.help_outline),
                          label: Text('Question'),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (selection) {
                        setState(() => _type = selection.first);
                      },
                    ),
                    const Gap(16),
                    TextFormField(
                      controller: _messageCtrl,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 1000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        hintText: 'Tell us what happened or what would help.',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Please add a message.';
                        }
                        return null;
                      },
                    ),
                    const Gap(12),
                    TextFormField(
                      controller: _replyEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Reply email',
                        hintText: 'Optional',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return null;
                        final ok = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(text);
                        return ok ? null : 'Enter a valid email address.';
                      },
                    ),
                    const Gap(10),
                    Text(
                      'Signed in as ${user.email ?? user.displayName ?? 'Google account'} | $kAppVersionLabel',
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _sending ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _sending ? null : () => _submit(user),
                            child: Text(
                              _sending ? 'Sending...' : 'Send feedback',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _authBusy = true);
    try {
      final user = await ref.read(googleAuthActionsProvider).signIn();
      if (user != null) {
        await ref.read(syncOrchestratorProvider).onSignIn(user.uid);
        if (_replyEmailCtrl.text.trim().isEmpty &&
            (user.email ?? '').trim().isNotEmpty) {
          _replyEmailCtrl.text = user.email!.trim();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _authBusy = false);
    }
  }

  Future<void> _submit(User user) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);
    try {
      await _service.submit(
        user: user,
        type: _type.name,
        message: _messageCtrl.text.trim(),
        replyEmail: _replyEmailCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send feedback: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
