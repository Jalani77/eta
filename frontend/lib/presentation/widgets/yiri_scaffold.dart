import 'package:flutter/material.dart';

import '../theme/yiri_theme.dart';

class YiriScaffold extends StatelessWidget {
  final Widget child;

  const YiriScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        // Pure white dominates; subtle gray underlay provides depth under cards.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            YiriTheme.pureWhite,
            Color(0xFFFFFFFF),
            Color(0xFFF7F7F9),
          ],
          stops: [0.0, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}
