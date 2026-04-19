// lib/features/restaurant/widgets/add_to_cart_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../data/mock_data.dart';
import '../../cart/providers/cart_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Internal model — size variant row
// ─────────────────────────────────────────────────────────────────────────────
class _SizeOption {
  final String id;
  final String label;
  final double extraPrice;
  const _SizeOption(
      {required this.id, required this.label, required this.extraPrice});
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet entry point
// ─────────────────────────────────────────────────────────────────────────────
class AddToCartSheet extends ConsumerStatefulWidget {
  final MenuItem item;
  final String restaurantId;

  const AddToCartSheet({
    super.key,
    required this.item,
    required this.restaurantId,
  });

  @override
  ConsumerState<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends ConsumerState<AddToCartSheet> {
  int _quantity = 1;

  // Size — single select (index into _sizes)
  late int _selectedSizeIndex;

  // Add-ons — multi-select by id
  final Set<String> _selectedAddOnIds = {};

  // We simulate size options based on the first 3 add-ons when count >= 3,
  // and treat remaining as add-ons. This matches the design pattern where
  // "Size Options" is REQUIRED and "Add-ons" is optional.
  late final List<_SizeOption> _sizes;
  late final List<AddOn> _addOns;

  @override
  void initState() {
    super.initState();
    _buildSizesAndAddOns();
    _selectedSizeIndex = 0;
  }

  void _buildSizesAndAddOns() {
    final all = widget.item.addOns;

    if (all.length >= 3) {
      // First add-on = "Small (Regular)" at base price
      // Remaining = real add-ons
      _sizes = [
        _SizeOption(
            id: 'size_sm', label: 'Small (Regular Patty)', extraPrice: 0),
        _SizeOption(
            id: 'size_md',
            label: 'Medium (Large Patty)',
            extraPrice: all[0].price),
        _SizeOption(
            id: 'size_lg',
            label: 'Large (Double Patty)',
            extraPrice: all[0].price * 2),
      ];
      _addOns = all.skip(1).toList();
    } else {
      // No size section — treat all as add-ons
      _sizes = [];
      _addOns = all;
    }
  }

  double get _sizeExtra =>
      _sizes.isNotEmpty ? _sizes[_selectedSizeIndex].extraPrice : 0;

  double get _addOnsExtra => _addOns
      .where((a) => _selectedAddOnIds.contains(a.id))
      .fold(0.0, (s, a) => s + a.price);

  double get _unitPrice => widget.item.price + _sizeExtra + _addOnsExtra;
  double get _total => _unitPrice * _quantity;

  List<AddOn> get _selectedAddOnObjects =>
      _addOns.where((a) => _selectedAddOnIds.contains(a.id)).toList();

  void _addToCart() {
    // For size: inject it as a pseudo add-on so cart captures the upgrade price
    final List<AddOn> finalAddOns = [];
    if (_sizes.isNotEmpty && _sizes[_selectedSizeIndex].extraPrice > 0) {
      finalAddOns.add(AddOn(
        id: _sizes[_selectedSizeIndex].id,
        name: _sizes[_selectedSizeIndex].label,
        price: _sizes[_selectedSizeIndex].extraPrice,
      ));
    }
    finalAddOns.addAll(_selectedAddOnObjects);

    for (var i = 0; i < _quantity; i++) {
      ref.read(cartProvider.notifier).addItem(
        restaurantId: widget.restaurantId,
        menuItem: widget.item,
        selectedAddOns: finalAddOns,
      );
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} added to cart',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl + 4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Item header ──────────────────────────────────────
                  _ItemHeader(item: widget.item),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Price + Popular badge ────────────────────────────
                  _PriceRow(
                    basePrice: widget.item.price,
                    extraPrice: _sizeExtra + _addOnsExtra,
                    isPopular: widget.item.isPopular,
                  ),

                  // ── Size Options ─────────────────────────────────────
                  if (_sizes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Size Options',
                      badge: 'REQUIRED',
                      badgeColor: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ..._sizes.asMap().entries.map((entry) {
                      final i = entry.key;
                      final size = entry.value;
                      final isSelected = i == _selectedSizeIndex;
                      return _RadioRow(
                        label: size.label,
                        extraPrice: size.extraPrice,
                        isSelected: isSelected,
                        onTap: () =>
                            setState(() => _selectedSizeIndex = i),
                      );
                    }),
                  ],

                  // ── Add-ons ──────────────────────────────────────────
                  if (_addOns.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionHeader(
                      title: 'Add-ons',
                      badge: 'Select multiple',
                      badgeColor: AppColors.textSecondary,
                      badgeFilled: false,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ..._addOns.map((addOn) {
                      final isSelected =
                      _selectedAddOnIds.contains(addOn.id);
                      return _CheckboxRow(
                        label: addOn.name,
                        extraPrice: addOn.price,
                        isSelected: isSelected,
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selectedAddOnIds.remove(addOn.id);
                          } else {
                            _selectedAddOnIds.add(addOn.id);
                          }
                        }),
                      );
                    }),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // ── Sticky bottom bar ──────────────────────────────────────────
          _BottomBar(
            quantity: _quantity,
            total: _total,
            onDecrement: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
            onIncrement: () => setState(() => _quantity++),
            onAddToCart: _addToCart,
            bottomPadding: bottomPadding + bottomInset,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item Header — name left, image right
// ─────────────────────────────────────────────────────────────────────────────
class _ItemHeader extends StatelessWidget {
  final MenuItem item;
  const _ItemHeader({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Thumbnail — dark square card
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedImage(url: item.imageUrl),
                // "SAFE WORK" watermark overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.55),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'SAFE WORK',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
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

// ─────────────────────────────────────────────────────────────────────────────
// Price row
// ─────────────────────────────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final double basePrice;
  final double extraPrice;
  final bool isPopular;

  const _PriceRow({
    required this.basePrice,
    required this.extraPrice,
    required this.isPopular,
  });

  @override
  Widget build(BuildContext context) {
    final total = basePrice + extraPrice;
    return Row(
      children: [
        Text(
          'Rs. ${total.toInt()}',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        if (isPopular) ...[
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              'Popular Choice',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header — title left, badge right
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String badge;
  final Color badgeColor;
  final bool badgeFilled;

  const _SectionHeader({
    required this.title,
    required this.badge,
    required this.badgeColor,
    this.badgeFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
        const Spacer(),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: badgeFilled
              ? BoxDecoration(
            color: badgeColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: badgeColor.withOpacity(0.3)),
          )
              : null,
          child: Text(
            badge,
            style: GoogleFonts.poppins(
              fontSize: badgeFilled ? 11 : 13,
              fontWeight: FontWeight.w600,
              color: badgeColor,
              letterSpacing: badgeFilled ? 0.8 : 0,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Radio row — single select size option
// ─────────────────────────────────────────────────────────────────────────────
class _RadioRow extends StatelessWidget {
  final String label;
  final double extraPrice;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.label,
    required this.extraPrice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.04)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                  isSelected ? AppColors.primary : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              )
                  : null,
            ),

            const SizedBox(width: AppSpacing.md),

            // Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Price
            Text(
              extraPrice == 0
                  ? '+Rs. 0'
                  : '+Rs. ${extraPrice.toInt()}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkbox row — multi select add-on
// ─────────────────────────────────────────────────────────────────────────────
class _CheckboxRow extends StatelessWidget {
  final String label;
  final double extraPrice;
  final bool isSelected;
  final VoidCallback onTap;

  const _CheckboxRow({
    required this.label,
    required this.extraPrice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.04)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Checkbox square
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                  isSelected ? AppColors.primary : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: AppSpacing.md),

            // Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Price
            Text(
              '+Rs. ${extraPrice.toInt()}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom bar — qty selector + Add to Cart CTA
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int quantity;
  final double total;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onAddToCart;
  final double bottomPadding;

  const _BottomBar({
    required this.quantity,
    required this.total,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAddToCart,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        bottomPadding > 0 ? bottomPadding : AppSpacing.lg,
      ),
      child: Row(
        children: [
          // ── Qty pill ──────────────────────────────────────────────────
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyBtn(icon: Icons.remove, onTap: onDecrement),
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      '$quantity',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                _QtyBtn(icon: Icons.add, onTap: onIncrement),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Add to Cart CTA ───────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: onAddToCart,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Add to Cart  '),
                        TextSpan(
                          text: 'Rs. ${total.toInt()}',
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
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Qty button — inside the grey pill
// ─────────────────────────────────────────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 52,
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}