import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 0 = Dashboard, 1 = Syllabus, 2 = Settings
final tabIndexProvider = StateProvider<int>((ref) => 0);
