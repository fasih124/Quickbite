// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../data/mock_data.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _ProfileAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── User header ────────────────────────────────────
                  _UserHeader(user: mockUser),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Stats row ──────────────────────────────────────
                  _StatsRow(),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Account Management ─────────────────────────────
                  _SectionLabel(label: 'ACCOUNT MANAGEMENT'),

                  const SizedBox(height: AppSpacing.md),

                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Manage Addresses',
                    onTap: () => _showAddressSheet(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MenuItem(
                    icon: Icons.savings_outlined,
                    label: 'Payment Methods',
                    onTap: () => _showPaymentSheet(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    iconColor: AppColors.primary,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {},
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Logout ─────────────────────────────────────────
                  _LogoutTile(
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddressListSheet(),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentListSheet(),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Log out?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.poppins(
              fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login');
            },
            child: Text('Log out',
                style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 6),
          Text(
            'Current Location',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary, size: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Header
// ─────────────────────────────────────────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  final AppUser user;
  const _UserHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar + edit FAB
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Avatar
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: AppShadows.card,
              ),
              child: ClipOval(
                child: CachedImage(url: user.avatarUrl),
              ),
            ),

            // Edit FAB
            Positioned(
              bottom: -2,
              right: -2,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: Colors.white, width: 2),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: AppSpacing.lg),

        // Name + email + badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _EliteBadge(),
            ],
          ),
        ),
      ],
    );
  }
}

class _EliteBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.35), width: 1),
      ),
      child: Text(
        'ELITE MEMBER',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row — Favorites + Orders
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_rounded,
            count: '12',
            label: 'FAVORITES',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_bag_rounded,
            count: '48',
            label: 'ORDERS',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: AppSpacing.md),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu Item Row
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: effectiveIconColor == AppColors.primary
                    ? AppColors.primary.withOpacity(0.10)
                    : const Color(0xFFF0F0F0),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),

            const SizedBox(width: AppSpacing.md),

            // Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Chevron
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout Tile
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm + 2),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.primary, size: 20),
            ),

            const SizedBox(width: AppSpacing.md),

            Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Address List Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddressListSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Saved Addresses',
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          ...mockUser.addresses.map((addr) => Container(
            margin:
            const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: addr.isDefault
                  ? AppColors.primary.withOpacity(0.06)
                  : AppColors.background,
              borderRadius:
              BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: addr.isDefault
                    ? AppColors.primary
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  addr.isDefault
                      ? Icons.home_rounded
                      : Icons.location_on_outlined,
                  color: addr.isDefault
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(addr.label,
                              style: AppTextStyles.titleMedium),
                          if (addr.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Default',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(addr.fullAddress,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
          )),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Center(
                child: Text(
                  '+ Add New Address',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment List Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentListSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const methods = [
      ('Visa', '•••• 4421', Icons.credit_card_rounded),
      ('Mastercard', '•••• 8832', Icons.credit_card_rounded),
      ('Cash on Delivery', '', Icons.payments_outlined),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Payment Methods',
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          ...methods.map((m) => Container(
            margin:
            const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
              BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(m.$3,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    m.$2.isEmpty
                        ? m.$1
                        : '${m.$1}  ${m.$2}',
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
          )),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Center(
                child: Text(
                  '+ Add Payment Method',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}