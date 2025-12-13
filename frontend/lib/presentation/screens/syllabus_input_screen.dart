import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_state.dart';
import '../../state/syllabus_state.dart';
import '../../state/tab_state.dart';
import '../theme/yiri_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/section_header.dart';
import '../widgets/yiri_card.dart';

class SyllabusInputScreen extends ConsumerStatefulWidget {
  const SyllabusInputScreen({super.key});

  @override
  ConsumerState<SyllabusInputScreen> createState() => _SyllabusInputScreenState();
}

class _SyllabusInputScreenState extends ConsumerState<SyllabusInputScreen> {
  final _className = TextEditingController();
  final _syllabusText = TextEditingController();
  final _phone = TextEditingController();
  final _assumed = TextEditingController(text: '85');

  @override
  void dispose() {
    _className.dispose();
    _syllabusText.dispose();
    _phone.dispose();
    _assumed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(syllabusProvider);
    final auth = ref.watch(authProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: ListView(
        children: [
          const SectionHeader(
            title: 'Syllabus',
            subtitle: 'Paste your syllabus text. Yiri extracts weights + dates and schedules reminders 24h before due dates.',
          ),
          const SizedBox(height: 14),
          if (auth.token == null) ...[
            EmptyStateCard(
              icon: Icons.lock_outline,
              title: 'Sign in first',
              message: 'To submit a syllabus and schedule reminders, create an account in Settings and sign in.',
              ctaLabel: 'Go to Settings',
              onCta: () => ref.read(tabIndexProvider.notifier).state = 2,
            ),
            const SizedBox(height: 14),
          ],
          YiriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _className,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Class name',
                    hintText: 'e.g., Calculus I',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone number (optional)',
                    hintText: '+14155552671',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _assumed,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Assumed average for remaining work',
                    hintText: '85',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _syllabusText,
                  minLines: 8,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    labelText: 'Syllabus text',
                    alignLabelWithHint: true,
                    hintText:
                        'Homework 20%\nQuizzes 15%\nMidterm 25%\nFinal 40%\n\n2026-02-15 Exam 1\nFeb 20, 2026 Assignment 3',
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Submit syllabus',
                  busy: state.busy,
                  onPressed: auth.token == null
                      ? null
                      : () {
                    final assumed = double.tryParse(_assumed.text.trim()) ?? 85;
                    ref.read(syllabusProvider.notifier).submit(
                          className: _className.text.trim(),
                          syllabusText: _syllabusText.text,
                          phoneNumberE164: _phone.text,
                          assumedRemainingAverage: assumed,
                        );
                  },
                ),
                if (state.lastResult != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    state.lastResult!,
                    style: const TextStyle(color: YiriTheme.mutedText, fontWeight: FontWeight.w800),
                  ),
                ],
                if (state.error != null) ...[
                  const SizedBox(height: 10),
                  Text(state.error!, style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tip: Include lines like "Homework 20%" and dates like "2026-02-15 Exam 1" or "Feb 15, 2026 Assignment 3" for best results.',
            style: TextStyle(color: Color(0xFF6B7280), height: 1.25),
          ),
        ],
      ),
    );
  }
}
