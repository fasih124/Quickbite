// lib/features/cart/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../data/mock_data.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();
  PromoCode? _appliedPromo;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // ── Derived totals ────────────────────────────────────────────────────────

  double _subtotal(List<CartItem> cart) =>
      cart.fold(0.0, (s, i) => s + i.subtotal);

  double _deliveryFee(List<CartItem> cart) {
    if (cart.isEmpty) return 0;
    final restaurantId = cart.first.restaurantId;
    try {
      return mockRestaurants
          .firstWhere((r) => r.id == restaurantId)
          .deliveryFee;
    } catch (_) {
      return 49;
    }
  }

  double _taxes(double subtotal) => (subtotal * 0.05).floorToDouble();

  double _discount(double subtotal) {
    if (_appliedPromo == null) return 0;
    if (subtotal < _appliedPromo!.minOrderValue) return 0;
    final raw = subtotal * (_appliedPromo!.discountPercent / 100);
    return raw.clamp(0, _appliedPromo!.maxDiscount);
  }

  double _grand(List<CartItem> cart) {
    final sub = _subtotal(cart);
    return sub + _deliveryFee(cart) + _taxes(sub) - _discount(sub);
  }

  // ── Promo logic ───────────────────────────────────────────────────────────

  void _applyPromo(List<CartItem> cart) {
    final code = _promoController.text.trim().toUpperCase();
    final found = mockPromoCodes.where((p) => p.code == code);
    if (found.isEmpty) {
      setState(() {
        _appliedPromo = null;
        _promoError = 'Invalid promo code';
      });
      return;
    }
    final promo = found.first;
    final sub = _subtotal(cart);
    if (sub < promo.minOrderValue) {
      setState(() {
        _appliedPromo = null;
        _promoError =
        'Minimum order Rs. ${promo.minOrderValue.toInt()} required';
      });
      return;
    }
    setState(() {
      _appliedPromo = promo;
      _promoError = null;
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${promo.description} applied!',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.tagGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _restaurantName(List<CartItem> cart) {
    if (cart.isEmpty) return '';
    try {
      return mockRestaurants
          .firstWhere((r) => r.id == cart.first.restaurantId)
          .name;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: cart.isEmpty
          ? _EmptyCart(onBrowse: () => context.push('/home'))
          : Column(
        children: [
          // ── Custom AppBar ─────────────────────────────────────
          _CartAppBar(),

          // ── Scrollable content ────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Text('Your Cart',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      )),

                  const SizedBox(height: 4),

                  // Subtitle — "N items from RestaurantName"
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                            text:
                            '${cart.length} ${cart.length == 1 ? 'item' : 'items'} from '),
                        TextSpan(
                          text: _restaurantName(cart),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Cart items
                  ...cart.map((item) => _CartItemCard(
                    item: item,
                    onIncrement: () => notifier.addItem(
                      restaurantId: item.restaurantId,
                      menuItem: item.menuItem,
                      selectedAddOns: item.selectedAddOns,
                    ),
                    onDecrement: () =>
                        notifier.decrementItem(item.uniqueKey),
                    onDismiss: () =>
                        notifier.removeItem(item.uniqueKey),
                  )),

                  const SizedBox(height: AppSpacing.md),

                  // Promo code
                  _PromoField(
                    controller: _promoController,
                    appliedPromo: _appliedPromo,
                    error: _promoError,
                    onApply: () => _applyPromo(cart),
                    onRemove: () => setState(() {
                      _appliedPromo = null;
                      _promoController.clear();
                      _promoError = null;
                    }),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Order summary
                  _OrderSummary(
                    subtotal: _subtotal(cart),
                    deliveryFee: _deliveryFee(cart),
                    taxes: _taxes(_subtotal(cart)),
                    discount: _discount(_subtotal(cart)),
                    grand: _grand(cart),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),

          // ── Go to Checkout CTA ────────────────────────────────
          _CheckoutButton(
            total: _grand(cart),
            onTap: () => context.push('/checkout'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _CartAppBar extends StatelessWidget {
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
// Cart Item Card
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDismiss;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDismiss,
  });

  String get _addOnsSummary {
    if (item.selectedAddOns.isEmpty) return '';
    return item.selectedAddOns.map((a) => a.name).join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.uniqueKey),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.primary, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: CachedImage(
                url: item.menuItem.imageUrl,
                width: 80,
                height: 80,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Name + add-ons + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuItem.name,
                    style: AppTextStyles.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (_addOnsSummary.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      _addOnsSummary,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  Row(
                    children: [
                      // Price
                      Text(
                        'Rs. ${item.subtotal.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),

                      const Spacer(),

                      // Qty stepper pill
                      _QtyPill(
                        quantity: item.quantity,
                        onDecrement: onDecrement,
                        onIncrement: onIncrement,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Qty Pill  — grey background − 1 +
// ─────────────────────────────────────────────────────────────────────────────

class _QtyPill extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QtyPill({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillBtn(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$quantity',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          _PillBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PillBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Promo Code Field
// ─────────────────────────────────────────────────────────────────────────────

class _PromoField extends StatelessWidget {
  final TextEditingController controller;
  final PromoCode? appliedPromo;
  final String? error;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _PromoField({
    required this.controller,
    required this.appliedPromo,
    required this.error,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isApplied = appliedPromo != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
            border: error != null
                ? Border.all(color: AppColors.primary.withOpacity(0.5))
                : isApplied
                ? Border.all(
                color: AppColors.tagGreen.withOpacity(0.6))
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                isApplied
                    ? Icons.check_circle_rounded
                    : Icons.local_offer_rounded,
                color:
                isApplied ? AppColors.tagGreen : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: isApplied
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appliedPromo!.code,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tagGreen,
                      ),
                    ),
                    Text(
                      appliedPromo!.description,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                )
                    : TextField(
                  controller: controller,
                  textCapitalization:
                  TextCapitalization.characters,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a promo code',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              GestureDetector(
                onTap: isApplied ? onRemove : onApply,
                child: Text(
                  isApplied ? 'Remove' : 'Apply',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isApplied
                        ? AppColors.textSecondary
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Error message
        if (error != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              error!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double discount;
  final double grand;

  const _OrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.taxes,
    required this.discount,
    required this.grand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: 'Rs. ${subtotal.toInt()}',
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'Delivery Fee',
            value: 'Rs. ${deliveryFee.toInt()}',
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'Taxes & Fees',
            value: 'Rs. ${taxes.toInt()}',
          ),
          if (discount > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _SummaryRow(
              label: 'Discount',
              value: '− Rs. ${discount.toInt()}',
              valueColor: AppColors.tagGreen,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

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
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Go to Checkout Button
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutButton extends StatelessWidget {
  final double total;
  final VoidCallback onTap;

  const _CheckoutButton({required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        bottomPad > 0 ? bottomPad : AppSpacing.lg,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE53935),
                Color(0xFFC62828),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Go to Checkout',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Cart State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CartAppBar(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.primary,
                    size: 44,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Your cart is empty',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Add items from a restaurant to get started',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                GestureDetector(
                  onTap: onBrowse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                      BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Browse Restaurants',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}