// lib/features/restaurant/screens/restaurant_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../data/mock_data.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/add_to_cart_sheet.dart';

class RestaurantScreen extends ConsumerWidget {
  final String restaurantId;
  const RestaurantScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantByIdProvider(restaurantId));

    if (restaurant == null) {
      return Scaffold(
        body: Center(
          child: Text('Restaurant not found',
              style: AppTextStyles.headlineSmall),
        ),
      );
    }

    return _RestaurantBody(restaurant: restaurant);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main body — owns the CustomScrollView + SliverAppBar
// ─────────────────────────────────────────────────────────────────────────────

class _RestaurantBody extends ConsumerWidget {
  final Restaurant restaurant;
  const _RestaurantBody({required this.restaurant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
    ref.watch(menuCategoriesProvider(restaurant.id));
    final activeIndex =
    ref.watch(activeMenuCategoryProvider(restaurant.id));
    final filteredItems =
    ref.watch(filteredMenuItemsProvider(restaurant.id));
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartSubtotalProvider);
    final cartCount = ref.watch(cartTotalQuantityProvider);

    // Group ALL menu items by category for section rendering
    final Map<String, List<MenuItem>> grouped = {};
    for (final item in restaurant.menu) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    // If a category is actively selected, show only that group
    final bool isFiltered = categories.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── Hero SliverAppBar ──────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: const Color(0xFF1A0A05),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.safePop(),
                    ),
                  ),
                  actions: [
                    _CircleIconButton(
                      icon: Icons.share_outlined,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _CircleIconButton(
                      icon: Icons.favorite_border_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: _HeroBanner(
                        restaurant: restaurant),
                  ),
                ),

                // ── Info Card ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _InfoCard(restaurant: restaurant),
                ),

                // ── Category Tabs ──────────────────────────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoryTabsDelegate(
                    categories: categories,
                    activeIndex: activeIndex,
                    onSelected: (i) => ref
                        .read(activeMenuCategoryProvider(
                        restaurant.id)
                        .notifier)
                        .state = i,
                  ),
                ),

                // ── Menu Sections ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _MenuSections(
                    restaurant: restaurant,
                    grouped: grouped,
                    activeCategory:
                    isFiltered && categories.isNotEmpty
                        ? categories[activeIndex]
                        : null,
                  ),
                ),

                // Bottom padding for cart bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),

            // ── View Cart Bar ──────────────────────────────────────────────
            if (cartCount > 0 &&
                (cart.isEmpty ||
                    cart.first.restaurantId == restaurant.id))
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: _ViewCartBar(
                  itemCount: cartCount,
                  total: cartTotal,
                  onTap: () => context.push('/cart'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final Restaurant restaurant;
  const _HeroBanner({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Dark background
        Container(color: const Color(0xFF1A0A05)),

        // Restaurant image — positioned in lower half as "food hero"
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 280,
          child: CachedImage(
            url: restaurant.imageUrl,
            fit: BoxFit.cover,
          ),
        ),

        // Gradient — dark top, fades to image
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Color(0xCC1A0A05),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // "Restaurant Hero" watermark label at bottom
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius:
                BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                'Restaurant Hero',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Card — white rounded card that overlaps the hero
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Restaurant restaurant;
  const _InfoCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _RatingPill(rating: restaurant.rating),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Address
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  restaurant.address,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Delivery time chip
          _InfoChip(
            icon: Icons.access_time_rounded,
            label:
            '${restaurant.deliveryTimeMin}-${restaurant.deliveryTimeMax} min',
          ),

          const SizedBox(height: AppSpacing.sm),

          // Delivery fee chip
          _InfoChip(
            icon: Icons.delivery_dining_rounded,
            label: restaurant.deliveryFee < 1
                ? 'Free Delivery'
                : 'Rs. ${restaurant.deliveryFee.toInt()} Delivery',
          ),

          const SizedBox(height: AppSpacing.md),

          // Cuisine tags
          Text(
            restaurant.cuisine.split(', ').join(' • '),
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          Text(
            'RATING',
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Tabs — Sticky header
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final int activeIndex;
  final void Function(int) onSelected;

  const _CategoryTabsDelegate({
    required this.categories,
    required this.activeIndex,
    required this.onSelected,
  });

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isActive = index == activeIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius:
                BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.divider,
                ),
              ),
              child: Text(
                categories[index],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryTabsDelegate old) =>
      old.activeIndex != activeIndex ||
          old.categories.length != categories.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu Sections
// ─────────────────────────────────────────────────────────────────────────────

class _MenuSections extends StatelessWidget {
  final Restaurant restaurant;
  final Map<String, List<MenuItem>> grouped;
  final String? activeCategory;

  const _MenuSections({
    required this.restaurant,
    required this.grouped,
    required this.activeCategory,
  });

  @override
  Widget build(BuildContext context) {
    final entriesToShow = activeCategory != null
        ? grouped.entries
        .where((e) => e.key == activeCategory)
        .toList()
        : grouped.entries.toList();

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entriesToShow.map((entry) {
          return _MenuSection(
            sectionTitle: 'Popular ${entry.key}',
            items: entry.value,
            restaurantId: restaurant.id,
          );
        }).toList(),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String sectionTitle;
  final List<MenuItem> items;
  final String restaurantId;

  const _MenuSection({
    required this.sectionTitle,
    required this.items,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg),
          child: Text(
            sectionTitle,
            style: AppTextStyles.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...items.map((item) => _MenuItemCard(
          item: item,
          restaurantId: restaurantId,
        )),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu Item Card
// ─────────────────────────────────────────────────────────────────────────────

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String restaurantId;

  const _MenuItemCard({
    required this.item,
    required this.restaurantId,
  });

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddToCartSheet(
          item: item,
          restaurantId: restaurantId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: CachedImage(
                url: item.imageUrl,
                width: 80,
                height: 80,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rs. ${item.price.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    item.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // ADD TO ORDER button
                  GestureDetector(
                    onTap: () => _openSheet(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ADD TO ORDER',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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
// View Cart Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ViewCartBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback onTap;

  const _ViewCartBar({
    required this.itemCount,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VIEW CART',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '$itemCount ${itemCount == 1 ? 'Item' : 'Items'} Selected',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular icon button (back / share / heart in appbar)
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}