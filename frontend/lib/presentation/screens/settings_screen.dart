import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/app_settings.dart';
import '../../state/auth_state.dart';
import '../../state/classes_state.dart';
import '../../state/tab_state.dart';
import '../../state/user_profile_state.dart';
import '../theme/yiri_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import '../widgets/yiri_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _baseUrl = TextEditingController();
  final _goal = TextEditingController();
  final _phone = TextEditingController();

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider);
    _baseUrl.text = settings.baseUrl;
    _goal.text = settings.goalFinalGrade.toStringAsFixed(0);

    ref.listen<AuthState>(authProvider, (prev, next) {
      final wasOut = prev?.token == null;
      final isIn = next.token != null;
      if (wasOut && isIn) {
        ref.read(classesProvider.notifier).refresh();
        ref.read(userProfileProvider.notifier).refresh();
        ref.read(tabIndexProvider.notifier).state = 0;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in. Dashboard is synced.')),
        );
      }
    });
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _goal.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final auth = ref.watch(authProvider);
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;

    if (_phone.text.isEmpty && profile?.phoneNumberE164 != null) {
      _phone.text = profile!.phoneNumberE164!;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: ListView(
        children: [
          const SectionHeader(title: 'Settings'),
          const SizedBox(height: 14),

          YiriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Backend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                TextField(
                  controller: _baseUrl,
                  decoration: const InputDecoration(labelText: 'API base URL (e.g. http://localhost:3001)'),
                  onSubmitted: (v) => ref.read(appSettingsProvider.notifier).setBaseUrl(v.trim()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _goal,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Goal final grade (e.g. 90)'),
                  onSubmitted: (v) {
                    final d = double.tryParse(v.trim());
                    if (d != null) ref.read(appSettingsProvider.notifier).setGoalFinalGrade(d);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Current goal: ${settings.goalFinalGrade.toStringAsFixed(0)}%',
                  style: const TextStyle(color: YiriTheme.mutedText, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          YiriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                if (auth.token == null) ...[
                  const Text(
                    'Create an account (or sign in) to connect your dashboard to the backend.',
                    style: TextStyle(color: YiriTheme.mutedText, height: 1.25),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password (min 8 chars)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Sign in',
                          busy: auth.busy,
                          onPressed: () => ref.read(authProvider.notifier).login(_email.text.trim(), _password.text),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: auth.busy
                              ? null
                              : () => ref.read(authProvider.notifier).register(_email.text.trim(), _password.text),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text('Signed in as ${auth.email ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number for reminders (E.164)',
                      hintText: '+14155552671',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: profileState.busy
                              ? null
                              : () async {
                                  final g = double.tryParse(_goal.text.trim());
                                  final goalFinal = g ?? settings.goalFinalGrade;
                                  await ref.read(userProfileProvider.notifier).update(
                                        phoneNumberE164: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                                        goalFinalGrade: goalFinal,
                                      );
                                  await ref.read(appSettingsProvider.notifier).setGoalFinalGrade(goalFinal);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Saved settings.')),
                                    );
                                  }
                                },
                          child: profileState.busy ? const Text('Saving…') : const Text('Save reminder settings'),
                        ),
                      ),
                    ],
                  ),
                  if (profileState.error != null) ...[
                    const SizedBox(height: 10),
                    Text(profileState.error!, style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w700)),
                  ],
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Sign out',
                    onPressed: () => ref.read(authProvider.notifier).signOut(),
                  ),
                ],
                if (auth.error != null) ...[
                  const SizedBox(height: 10),
                  Text(auth.error!, style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Text(
            'Twilio reminders are scheduled by the backend when you submit a syllabus. Ensure the backend has Twilio env vars set before deploying.',
            style: TextStyle(color: Color(0xFF6B7280), height: 1.25),
          ),
        ],
      ),
    );
  }
}
