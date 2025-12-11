import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/syllabus_state.dart';
import '../widgets/primary_button.dart';
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: ListView(
        children: [
          const Text('Syllabus Input', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text(
            'Paste your syllabus text. Yiri will extract weights + dates and schedule reminders 24h before due dates.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.25),
          ),
          const SizedBox(height: 14),
          YiriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _className,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Class name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Phone (E.164, e.g. +14155552671) — optional'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _assumed,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Assumed average for remaining work (e.g. 85)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _syllabusText,
                  minLines: 8,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    labelText: 'Syllabus text',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Submit syllabus',
                  busy: state.busy,
                  onPressed: () {
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
                  Text(state.lastResult!, style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w700)),
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
