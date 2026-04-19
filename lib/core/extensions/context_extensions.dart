// lib/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension SafeNavigation on BuildContext {
  /// Pops if possible, otherwise goes to /home.
  void safePop({String fallback = '/home'}) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}