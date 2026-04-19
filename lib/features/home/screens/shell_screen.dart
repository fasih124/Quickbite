// lib/features/home/screens/shell_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../cart/providers/cart_provider.dart';

class ShellScreen extends ConsumerWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home', path: '/home'),
    (icon: Icons.search_rounded, label: 'Search', path: '/search'),
    (icon: Icons.shopping_bag_outlined, label: 'Orders', path: '/orders'),
    (icon: Icons.person_outline_rounded, label: 'Profile', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/orders')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartTotalQuantityProvider);
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isSelected = index == currentIndex;
                final showBadge = index == 2 && cartCount > 0;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.push(tab.path),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              tab.icon,
                              size: 24,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            if (showBadge)
                              Positioned(
                                top: -4,
                                right: -6,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    cartCount > 9 ? '9+' : '$cartCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}