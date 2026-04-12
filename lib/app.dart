import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

class OjakApp extends ConsumerWidget {
  const OjakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '오작',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const Scaffold(
        body: Center(
          child: Text('오작 - 사주 기반 소셜 매칭'),
        ),
      ),
    );
  }
}