import 'package:flutter/material.dart';

import '../theme/yiri_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 26,
              decoration: BoxDecoration(
                color: YiriTheme.yiriRed,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(color: YiriTheme.mutedText, height: 1.25),
          ),
        ],
      ],
    );
  }
}
