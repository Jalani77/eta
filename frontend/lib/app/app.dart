import 'package:flutter/material.dart';

import '../presentation/screens/main_shell.dart';
import '../presentation/theme/yiri_theme.dart';

class YiriApp extends StatelessWidget {
  const YiriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yiri',
      debugShowCheckedModeBanner: false,
      theme: YiriTheme.light(),
      home: const MainShell(),
    );
  }
}
