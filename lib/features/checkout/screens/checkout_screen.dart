// lib/features/checkout/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../data/mock_data.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  double _deliveryFee(List<CartItem> cart) {
    if (cart.isEmpty) return 0;
    try {
      return mockRestaurants
          .firstWhere((r) => r.id == cart.first.restaurantId)
          .deliveryFee;
    } catch (_) {
      return 49;
    }
  }

  double _subtotal(List<CartItem> cart) =>
      cart.fold(0.0, (s, i) => s + i.subtotal);

  double _grand(List<CartItem> cart) =>
      _subtotal(cart) + _deliveryFee(cart) + kServiceFee;

  String _estimatedArrival(List<CartItem> cart) {
    if (cart.isEmpty) return '7:45 PM';
    try {
      final r = mockRestaurants
          .firstWhere((r) => r.id == cart.first.restaurantId);
      final now = TimeOfDay.now();
      final totalMins =
          now.hour * 60 + now.minute + r.deliveryTimeMax;
      final h = (totalMins ~/ 60) % 12 == 0 ? 12 : (totalMins ~/ 60) % 12;
      final m = totalMins % 60;
      final suffix = (totalMins ~/ 60) >= 12 ? 'PM' : 'AM';
      return '$h:${m.toString().padLeft(2, '0')} $suffix';
    } catch (_) {
      return '7:45 PM';
    }
  }

  String _deliveryWindow(List<CartItem> cart) {
    if (cart.isEmpty) return '25 - 35 mins';
    try {
      final r = mockRestaurants
          .firstWhere((r) => r.id == cart.first.restaurantId);
      return '${r.deliveryTimeMin} - ${r.deliveryTimeMax} mins';
    } catch (_) {
      return '25 - 35 mins';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final selectedAddressIndex =
    ref.watch(selectedAddressIndexProvider);
    final selectedPaymentIndex =
    ref.watch(selectedPaymentIndexProvider);

    final address = mockUser.addresses.isNotEmpty
        ? mockUser.addresses[
    selectedAddressIndex.clamp(0, mockUser.addresses.length - 1)]
        : null;
    final payment = mockPaymentMethods[
    selectedPaymentIndex.clamp(0, mockPaymentMethods.length - 1)];

    final subtotal = _subtotal(cart);
    final deliveryFee = _deliveryFee(cart);
    final grand = _grand(cart);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar ──────────────────────────────────────────────────
          _CheckoutAppBar(onBack: () => context.safePop()),

          // ── Scrollable content ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  // Delivery Address
                  _AddressCard(
                    address: address,
                    onEdit: () => _showAddressPicker(context, ref),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Payment Method
                  _PaymentCard(
                    payment: payment,
                    onEdit: () => _showPaymentPicker(context, ref),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Order Summary
                  _OrderSummaryCard(
                    cart: cart,
                    subtotal: subtotal,
                    deliveryFee: deliveryFee,
                    serviceFee: kServiceFee,
                    grand: grand,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Estimated Delivery
                  _EstimatedDeliveryCard(
                    window: _deliveryWindow(cart),
                    arrivalTime: _estimatedArrival(cart),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // ── Place Order CTA ──────────────────────────────────────────
          _PlaceOrderButton(
            total: grand,
            onTap: () {
              ref.read(cartProvider.notifier).clearCart();
              context.push('/order-confirmed');
            },
          ),
        ],
      ),
    );
  }

  // ── Address picker bottom sheet ────────────────────────────────────────────
  void _showAddressPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressPickerSheet(
        addresses: mockUser.addresses,
        selectedIndex: ref.read(selectedAddressIndexProvider),
        onSelect: (i) {
          ref.read(selectedAddressIndexProvider.notifier).state = i;
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Payment picker bottom sheet ────────────────────────────────────────────
  void _showPaymentPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentPickerSheet(
        methods: mockPaymentMethods,
        selectedIndex: ref.read(selectedPaymentIndexProvider),
        onSelect: (i) {
          ref.read(selectedPaymentIndexProvider.notifier).state = i;
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _CheckoutAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: AppSpacing.sm,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back
          IconButton(
            icon: const Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 22),
            onPressed: onBack,
          ),

          // "Checkout" in red
          Text(
            'Checkout',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),

          const Spacer(),

          // Location
          const Icon(Icons.location_on,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 4),
          Text(
            'Current Location',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delivery Address Card
// ─────────────────────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final UserAddress? address;
  final VoidCallback onEdit;

  const _AddressCard({required this.address, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon circle
          _IconCircle(
            icon: Icons.location_on_rounded,
            color: AppColors.primary,
          ),

          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Address',
                    style: AppTextStyles.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  address?.fullAddress ??
                      'No address selected',
                  style: AppTextStyles.bodyMedium,
                ),
                if (address != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    address!.city,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ],
            ),
          ),

          // Edit
          GestureDetector(
            onTap: onEdit,
            child: Text(
              'Edit',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Method Card
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final PaymentMethod payment;
  final VoidCallback onEdit;

  const _PaymentCard({required this.payment, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          child: Row(
            children: [
              _IconCircle(
                icon: Icons.credit_card_rounded,
                color: AppColors.primary,
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Method',
                        style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 6),
                    if (payment.brand == 'cash')
                      Text('Cash on Delivery',
                          style: AppTextStyles.bodyMedium)
                    else
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius:
                              BorderRadius.circular(4),
                            ),
                            child: const Icon(
                                Icons.credit_card,
                                color: Colors.white,
                                size: 14),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•••• ${payment.last4}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Encrypted note
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Your payment is encrypted and secure.',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  final List<CartItem> cart;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double grand;

  const _OrderSummaryCard({
    required this.cart,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.grand,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _IconCircle(
                  icon: Icons.shopping_bag_rounded,
                  color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Text('Order Summary',
                  style: AppTextStyles.headlineSmall),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Cart items
          ...cart.map((item) => _OrderItemRow(item: item)),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),

          // Price breakdown
          _PriceRow(label: 'Subtotal', value: 'Rs. ${subtotal.toInt()}'),
          const SizedBox(height: AppSpacing.sm),
          _PriceRow(
              label: 'Delivery Fee',
              value: 'Rs. ${deliveryFee.toInt()}'),
          const SizedBox(height: AppSpacing.sm),
          _PriceRow(
              label: 'Service Fee',
              value: 'Rs. ${serviceFee.toInt()}'),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),

          // Total
          Row(
            children: [
              Text('Total',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const Spacer(),
              Text(
                'Rs. ${grand.toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final CartItem item;
  const _OrderItemRow({required this.item});

  String get _subtitle {
    final parts = <String>['${item.quantity}x'];
    if (item.selectedAddOns.isNotEmpty) {
      parts.add(item.selectedAddOns.first.name);
    }
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm + 2),
            child: CachedImage(
              url: item.menuItem.imageUrl,
              width: 60,
              height: 60,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Name + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menuItem.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(_subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Price
          Text(
            'Rs. ${item.subtotal.toInt()}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estimated Delivery Card
// ─────────────────────────────────────────────────────────────────────────────

class _EstimatedDeliveryCard extends StatelessWidget {
  final String window;
  final String arrivalTime;

  const _EstimatedDeliveryCard({
    required this.window,
    required this.arrivalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          _IconCircle(
            icon: Icons.timer_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Delivery',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 3),
              Text(
                '$window • Arriving by $arrivalTime',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Place Order Button
// ─────────────────────────────────────────────────────────────────────────────

class _PlaceOrderButton extends StatelessWidget {
  final double total;
  final VoidCallback onTap;

  const _PlaceOrderButton({required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        bottomPad > 0 ? bottomPad + 4 : AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE53935), Color(0xFFC62828)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.42),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Place Order',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      'Rs. ${total.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Legal text
          Text(
            'By placing this order you agree to our Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textHint,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: white section card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable: icon inside a soft-filled circle
// ─────────────────────────────────────────────────────────────────────────────

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Address Picker Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddressPickerSheet extends StatelessWidget {
  final List<UserAddress> addresses;
  final int selectedIndex;
  final void Function(int) onSelect;

  const _AddressPickerSheet({
    required this.addresses,
    required this.selectedIndex,
    required this.onSelect,
  });

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
          // Handle
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
          Text('Select Address', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          ...addresses.asMap().entries.map((e) {
            final isSelected = e.key == selectedIndex;
            return GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin:
                const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.06)
                      : AppColors.background,
                  borderRadius:
                  BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      e.value.isDefault
                          ? Icons.home_rounded
                          : Icons.location_on_outlined,
                      color: isSelected
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
                          Text(e.value.label,
                              style: AppTextStyles.titleMedium),
                          Text(e.value.fullAddress,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Picker Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentPickerSheet extends StatelessWidget {
  final List<PaymentMethod> methods;
  final int selectedIndex;
  final void Function(int) onSelect;

  const _PaymentPickerSheet({
    required this.methods,
    required this.selectedIndex,
    required this.onSelect,
  });

  IconData _iconFor(String brand) {
    switch (brand) {
      case 'cash':
        return Icons.payments_outlined;
      default:
        return Icons.credit_card_rounded;
    }
  }

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
          Text('Payment Method', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          ...methods.asMap().entries.map((e) {
            final isSelected = e.key == selectedIndex;
            final method = e.value;
            return GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin:
                const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.06)
                      : AppColors.background,
                  borderRadius:
                  BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _iconFor(method.brand),
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        method.brand == 'cash'
                            ? 'Cash on Delivery'
                            : '${method.label}  ••••  ${method.last4}',
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}