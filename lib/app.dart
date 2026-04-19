
// lib/app.dart
// ─────────────────────────────────────────────────────────────────────────────
// App entry point — GoRouter config + MaterialApp.router
// All 13 screens wired. ShellRoute wraps the 4 bottom-nav tabs.
// Navigation flow: /splash → /login → /address-setup → /home (shell)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';

// ── Auth screens ──────────────────────────────────────────────────────────────
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/address_setup_screen.dart';

// ── Shell (bottom nav) ────────────────────────────────────────────────────────
import 'features/home/screens/shell_screen.dart';

// ── Shell tabs ────────────────────────────────────────────────────────────────
import 'features/home/screens/home_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/profile/screens/profile_screen.dart';

// ── Full-screen flows (outside shell, no bottom nav) ─────────────────────────
import 'features/restaurant/screens/restaurant_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/checkout/screens/checkout_screen.dart';
import 'features/checkout/screens/order_confirmed_screen.dart';
import 'features/tracking/screens/tracking_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  // App always starts at splash
  initialLocation: '/splash',

  // Optional: log navigation events in debug mode
  debugLogDiagnostics: true,

  routes: [
    // ── 1. Splash ────────────────────────────────────────────────────────────
    // Auto-navigates to /login after animation sequence (~2.5s).
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => _fadeTransition(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),

    // ── 2. Login / Sign Up ───────────────────────────────────────────────────
    // Tab switcher between Login and Sign Up inside a single screen.
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _slideUpTransition(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),

    // ── 3. Address Setup ─────────────────────────────────────────────────────
    // Shown once after first login. "Confirm Address" → /home.
    GoRoute(
      path: '/address-setup',
      name: 'address-setup',
      pageBuilder: (context, state) => _slideUpTransition(
        key: state.pageKey,
        child: const AddressSetupScreen(),
      ),
    ),

    // ── 4. Restaurant Detail ─────────────────────────────────────────────────
    // Full-screen, no bottom nav. Navigated to from Home, Search, Order History.
    GoRoute(
      path: '/restaurant/:id',
      name: 'restaurant',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideRightTransition(
          key: state.pageKey,
          child: RestaurantScreen(restaurantId: id),
        );
      },
    ),

    // ── 5. Cart ──────────────────────────────────────────────────────────────
    // Full-screen cart (also accessible via /orders tab in shell,
    // but navigated to directly from restaurant "View Cart" bar).
    GoRoute(
      path: '/cart',
      name: 'cart',
      pageBuilder: (context, state) => _slideUpTransition(
        key: state.pageKey,
        child: const CartScreen(),
      ),
    ),

    // ── 6. Checkout ──────────────────────────────────────────────────────────
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      pageBuilder: (context, state) => _slideRightTransition(
        key: state.pageKey,
        child: const CheckoutScreen(),
      ),
    ),

    // ── 7. Order Confirmed ───────────────────────────────────────────────────
    GoRoute(
      path: '/order-confirmed',
      name: 'order-confirmed',
      pageBuilder: (context, state) => _fadeTransition(
        key: state.pageKey,
        child: const OrderConfirmedScreen(),
      ),
    ),

    // ── 8. Order Tracking ────────────────────────────────────────────────────
    GoRoute(
      path: '/tracking',
      name: 'tracking',
      pageBuilder: (context, state) => _slideRightTransition(
        key: state.pageKey,
        child: const TrackingScreen(),
      ),
    ),

    // ── 9–12. Shell (Bottom Nav) — Home / Search / Orders / Profile ──────────
    // ShellRoute keeps the BottomNavigationBar alive while switching tabs.
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        // 9. Home
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => _noTransition(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),

        // 10. Search
        GoRoute(
          path: '/search',
          name: 'search',
          pageBuilder: (context, state) => _noTransition(
            key: state.pageKey,
            child: const SearchScreen(),
          ),
        ),

        // 11. Orders (Order History — also shows current cart when empty)
        GoRoute(
          path: '/orders',
          name: 'orders',
          pageBuilder: (context, state) => _noTransition(
            key: state.pageKey,
            child: const OrderHistoryScreen(),
          ),
        ),

        // 12. Profile
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => _noTransition(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
  ],

  // ── Error page ──────────────────────────────────────────────────────────────
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: _ErrorScreen(error: state.error?.toString() ?? 'Unknown error'),
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Page transition helpers
// ─────────────────────────────────────────────────────────────────────────────

/// No transition — used for bottom nav tab switches (instant swap).
CustomTransitionPage<void> _noTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (_, __, ___, child) => child,
  );
}

/// Fade — used for splash → login and order-confirmed (feels like a reveal).
CustomTransitionPage<void> _fadeTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Slide up — used for sheets-as-pages: login, address-setup, cart.
CustomTransitionPage<void> _slideUpTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}

/// Slide from right — used for drill-down screens: restaurant, checkout, tracking.
CustomTransitionPage<void> _slideRightTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Screen
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Page not found',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'Go Home',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App widget
// ─────────────────────────────────────────────────────────────────────────────

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QuickBite',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}