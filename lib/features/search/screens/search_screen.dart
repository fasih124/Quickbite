// lib/features/search/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../data/mock_data.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/search_provider.dart';

// ── Category grid data ────────────────────────────────────────────────────────
class _Category {
  final String label;
  final String imageUrl;
  const _Category({required this.label, required this.imageUrl});
}

const _popularCategories = [
  _Category(
    label: 'Pizza',
    imageUrl:
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
  ),
  _Category(
    label: 'Burger',
    imageUrl:
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
  ),
  _Category(
    label: 'Breakfast',
    imageUrl:
    'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=400&q=80',
  ),
  _Category(
    label: 'Asian',
    imageUrl:
    'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400&q=80',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final liveResults = ref.watch(searchResultsProvider);
    final recentResults = ref.watch(recentSearchesProvider);
    final isSearching = query.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar ──────────────────────────────────────────────────
          _SearchAppBar(),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  _SearchBar(
                    controller: _searchController,
                    focusNode: _focusNode,
                    isFocused: _isFocused,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  if (!isSearching) ...[
                    // ── Popular Categories ─────────────────────────
                    Text('Popular Categories',
                        style: AppTextStyles.headlineMedium),
                    const SizedBox(height: AppSpacing.lg),
                    _CategoryGrid(
                      categories: _popularCategories,
                      onTap: (label) {
                        _searchController.text = label;
                        _onSearchChanged(label);
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ── Recent Results ─────────────────────────────
                    if (recentResults.isNotEmpty) ...[
                      Row(
                        children: [
                          Text('Recent Results',
                              style: AppTextStyles.headlineMedium),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => ref
                                .read(recentSearchesProvider.notifier)
                                .clear(),
                            child: Text(
                              'Clear History',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...recentResults.map((r) => _ResultCard(
                        result: r,
                        onTap: () => _onResultTap(r),
                        onAddToOrder: r.type ==
                            SearchResultType.menuItem
                            ? () => _onAddToOrder(r)
                            : null,
                      )),
                    ],
                  ] else ...[
                    // ── Live Search Results ────────────────────────
                    if (liveResults.isEmpty)
                      _EmptySearchState(query: query)
                    else ...[
                      Text(
                        '${liveResults.length} result${liveResults.length == 1 ? '' : 's'} for "$query"',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...liveResults.map((r) => _ResultCard(
                        result: r,
                        onTap: () => _onResultTap(r),
                        onAddToOrder: r.type ==
                            SearchResultType.menuItem
                            ? () => _onAddToOrder(r)
                            : null,
                      )),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onResultTap(SearchResult result) {
    ref.read(recentSearchesProvider.notifier).add(result);
    if (result.type == SearchResultType.restaurant) {
      context.push('/restaurant/${result.restaurant!.id}');
    } else {
      context.push('/restaurant/${result.menuItemRestaurantId}');
    }
  }

  void _onAddToOrder(SearchResult result) {
    if (result.menuItem == null || result.menuItemRestaurantId == null) {
      return;
    }
    ref.read(cartProvider.notifier).addItem(
      restaurantId: result.menuItemRestaurantId!,
      menuItem: result.menuItem!,
      selectedAddOns: const [],
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.menuItem!.name} added to cart',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchAppBar extends StatelessWidget {
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
// Search Bar — red border when focused
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isFocused ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: AppShadows.subtle,
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.lg),
                const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for restaurants or dishes...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: onClear,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.close_rounded,
                          color: AppColors.textSecondary, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Filter button
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.subtle,
          ),
          child: const Icon(Icons.tune_rounded,
              color: AppColors.primary, size: 22),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Grid — 2 × 2
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final List<_Category> categories;
  final void Function(String) onTap;

  const _CategoryGrid({
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: categories
          .map((cat) => _CategoryCard(category: cat, onTap: onTap))
          .toList(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _Category category;
  final void Function(String) onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(category.label),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedImage(url: category.imageUrl),

            // Dark gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xBB000000),
                  ],
                ),
              ),
            ),

            // Label
            Center(
              child: Text(
                category.label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result Card — adapts for Restaurant vs MenuItem
// ─────────────────────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;
  final VoidCallback? onAddToOrder;

  const _ResultCard({
    required this.result,
    required this.onTap,
    this.onAddToOrder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: result.type == SearchResultType.restaurant
            ? _RestaurantResult(restaurant: result.restaurant!)
            : _MenuItemResult(
          item: result.menuItem!,
          restaurantName: result.menuItemRestaurantName!,
          onAddToOrder: onAddToOrder!,
        ),
      ),
    );
  }
}

// ── Restaurant result layout ──────────────────────────────────────────────────

class _RestaurantResult extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantResult({required this.restaurant});

  String get _priceTier {
    if (restaurant.deliveryFee < 50) return r'$';
    if (restaurant.deliveryFee < 80) return r'$$';
    if (restaurant.deliveryFee < 100) return r'$$$';
    return r'$$$$';
  }

  bool get _isFreeDelivery => restaurant.deliveryFee < 50;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: CachedImage(
            url: restaurant.imageUrl,
            width: 90,
            height: 90,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
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
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RatingPill(rating: restaurant.rating),
                ],
              ),

              const SizedBox(height: 4),

              // Cuisine + price tier
              Text(
                '${restaurant.category} • ${restaurant.cuisine.split(',').first.trim()} • $_priceTier',
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Time + delivery
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${restaurant.deliveryTimeMin}-${restaurant.deliveryTimeMax} min',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.delivery_dining_rounded,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _isFreeDelivery
                        ? 'Free Delivery'
                        : 'Rs. ${restaurant.deliveryFee.toInt()} Delivery',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Menu item result layout ───────────────────────────────────────────────────

class _MenuItemResult extends StatelessWidget {
  final MenuItem item;
  final String restaurantName;
  final VoidCallback onAddToOrder;

  const _MenuItemResult({
    required this.item,
    required this.restaurantName,
    required this.onAddToOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: CachedImage(
            url: item.imageUrl,
            width: 90,
            height: 90,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + price
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              // "at RestaurantName"
              Text(
                'at $restaurantName',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 4),

              // Description
              Text(
                item.description,
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Add to Order →
              GestureDetector(
                onTap: onAddToOrder,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add to Order',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.primary, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rating Pill
// ─────────────────────────────────────────────────────────────────────────────

class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded,
              color: AppColors.starYellow, size: 13),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 12,
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
// Empty Search State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptySearchState extends StatelessWidget {
  final String query;
  const _EmptySearchState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No results for "$query"',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a different dish, restaurant,\nor cuisine name.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}