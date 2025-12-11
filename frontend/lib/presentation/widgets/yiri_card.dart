import 'package:flutter/material.dart';

import '../theme/yiri_theme.dart';

class YiriCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const YiriCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    // Layered look: subtle gradient under a crisp white card + realistic soft shadow.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            YiriTheme.lightGray,
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: YiriTheme.pureWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFFEDEFF2)),
        ),
        child: child,
      ),
    );
  }
}
