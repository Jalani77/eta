import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/app_settings.dart';
import '../../state/auth_state.dart';
import '../widgets/primary_button.dart';
import '../widgets/yiri_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _baseUrl = TextEditingController();
  final _goal = TextEditingController();

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider);
    _baseUrl.text = settings.baseUrl;
    _goal.text = settings.goalFinalGrade.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _goal.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final auth = ref.watch(authProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: ListView(
        children: [
          const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
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
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
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
