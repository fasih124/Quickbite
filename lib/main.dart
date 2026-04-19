// lib/main.dart
// ─────────────────────────────────────────────────────────────────────────────
// App entry point.
// ProviderScope wraps everything so every ConsumerWidget/ConsumerStatefulWidget
// in the tree can read Riverpod providers.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // Ensure Flutter engine is initialised before calling platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait — food delivery apps are portrait-only.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style globally.
  // The splash screen overrides this temporarily with immersiveSticky.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    // ProviderScope is the Riverpod root. Every provider in the app lives here.
    // Passing an empty overrides list — swap in mocks during testing:
    //   overrides: [cartProvider.overrideWith(() => MockCartNotifier())]
    const ProviderScope(
      overrides: [],
      child: App(),
    ),
  );
}