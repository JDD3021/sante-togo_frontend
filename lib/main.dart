import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// Main entry point for SANTÉ+ TOGO
/// 
/// This is a ProviderScope-wrapped app that uses Riverpod for state management
/// and go_router for navigation.
void main() {
  runApp(
    const ProviderScope(
      child: SantePlusTogoApp(),
    ),
  );
}

/// Root widget for SANTÉ+ TOGO application
class SantePlusTogoApp extends ConsumerWidget {
  const SantePlusTogoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SANTÉ+ TOGO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
