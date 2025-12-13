import 'package:flutter/material.dart';

import '../theme/yiri_theme.dart';
import 'yiri_card.dart';

class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return YiriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: YiriTheme.yiriRed.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, color: YiriTheme.yiriRed),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: YiriTheme.mutedText, height: 1.25)),
          if (ctaLabel != null && onCta != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: onCta,
                child: Text(ctaLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
