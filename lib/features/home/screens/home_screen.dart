// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/star_rating_badge.dart';
import '../../../data/mock_data.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _bannerController = PageController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _bannerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeLoadingProvider);
    final selectedCategoryIndex = ref.watch(selectedCategoryIndexProvider);
    final filteredRestaurants = ref.watch(filteredRestaurantsProvider);
    final cartCount = ref.watch(cartTotalQuantityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Top App Bar ──────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 0,
                toolbarHeight: 64,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(color: AppColors.surface),
                ),
                title: GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'DELIVER TO',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Current Location',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              SliverToBoxAdapter(
        child: homeAsync.when(
          loading: () => Column(
            children: [
              // Popular row shimmer
              _ShimmerPopularRow(),
              const SizedBox(height: AppSpacing.xxl),
              // Nearby list shimmer
              _ShimmerNearbyList(),
            ],
          ),
          error: (_, __) => const SizedBox(),
          data: (_)=>Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),

              // ── Search Bar ─────────────────────────────────────────
              _SearchBar(),

              const SizedBox(height: AppSpacing.lg),

              // ── Category Chips ─────────────────────────────────────
              _CategoryChips(
                selectedIndex: selectedCategoryIndex,
                onSelected: (i) => ref
                    .read(selectedCategoryIndexProvider.notifier)
                    .state = i,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Promo Banner Carousel ──────────────────────────────
              _BannerCarousel(controller: _bannerController),

              const SizedBox(height: AppSpacing.xxl),

              // ── Popular Near You ───────────────────────────────────
              _SectionHeader(
                title: 'Popular Near You',
                subtitle: 'Top picks from your local foodies',
                onViewAll: () {},
              ),

              const SizedBox(height: AppSpacing.md),

              _PopularRestaurantsRow(
                restaurants: mockRestaurants
                    .where((r) => r.isFeatured)
                    .toList(),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Nearby Restaurants ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: Text(
                  'Nearby Restaurants',
                  style: AppTextStyles.headlineMedium,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              _NearbyRestaurantsList(
                  restaurants: filteredRestaurants),

              const SizedBox(height: 100), // FAB + nav bar clearance
            ],
          ),
                ),
      ),
            ],
          ),

          // ── Floating History Button ────────────────────────────────────
          Positioned(
            bottom: 90,
            right: 16,
            child: _HistoryFAB(onTap: () => context.push('/orders')),
          ),
        ],
      ),
    );
  }
}


class _ShimmerPopularRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              ShimmerBox(width: 160, height: 20, borderRadius: 6),
              const Spacer(),
              ShimmerBox(width: 60, height: 16, borderRadius: 6),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, __) => Container(
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  ShimmerBox(
                    width: 180,
                    height: 140,
                    borderRadius: AppRadius.lg,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 120, height: 14, borderRadius: 4),
                        const SizedBox(height: 8),
                        ShimmerBox(width: 90, height: 11, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerNearbyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 200, height: 22, borderRadius: 6),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(
            3,
                (_) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  ShimmerBox(width: 80, height: 80, borderRadius: AppRadius.md),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: double.infinity, height: 15, borderRadius: 4),
                        const SizedBox(height: 8),
                        ShimmerBox(width: 140, height: 11, borderRadius: 4),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ShimmerBox(width: 80, height: 22, borderRadius: 6),
                            const SizedBox(width: 8),
                            ShimmerBox(width: 60, height: 22, borderRadius: 6),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadows.subtle,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.lg),
              const Icon(Icons.search_rounded,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Search for sushi, burgers, or...',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Chips
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelected;

  const _CategoryChips({
    required this.selectedIndex,
    required this.onSelected,
  });

  static const _chips = [
    ('All', Icons.apps_rounded),
    ('Pizza', Icons.local_pizza_outlined),
    ('Burger', Icons.lunch_dining_outlined),
    ('Desi', Icons.rice_bowl_outlined),
    ('BBQ', Icons.outdoor_grill_outlined),
    ('Chinese', Icons.ramen_dining_outlined),
    ('Rolls', Icons.wrap_text_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _chips.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (label, icon) = _chips[index];
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius:
                BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.divider,
                ),
                boxShadow:
                isSelected ? AppShadows.subtle : [],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner Carousel
// ─────────────────────────────────────────────────────────────────────────────

class _BannerCarousel extends StatefulWidget {
  final PageController controller;
  const _BannerCarousel({required this.controller});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: widget.controller,
            itemCount: mockBanners.length,
            padEnds: false,
            itemBuilder: (context, index) {
              final banner = mockBanners[index];
              return _BannerCard(banner: banner);
            },
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: widget.controller,
          count: mockBanners.length,
          effect: const ExpandingDotsEffect(
            activeDotColor: AppColors.primary,
            dotColor: Color(0xFFE0E0E0),
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final PromoBanner banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: AppSpacing.lg, right: AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedImage(url: banner.imageUrl),

            // Dark gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xCC000000),
                    Color(0x55000000),
                    Colors.transparent,
                  ],
                  stops: [0, 0.55, 1],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SPECIAL OFFER',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                        BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        'Claim Now',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onViewAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View all',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
// Popular Restaurants – Horizontal scroll
// ─────────────────────────────────────────────────────────────────────────────

class _PopularRestaurantsRow extends StatelessWidget {
  final List<Restaurant> restaurants;
  const _PopularRestaurantsRow({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: restaurants.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          return _PopularCard(
            restaurant: restaurants[index],
            onTap: () => context.push(
                '/restaurant/${restaurants[index].id}'),
          );
        },
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const _PopularCard({
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                  child: CachedImage(
                    url: restaurant.imageUrl,
                    height: 140,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: StarRatingBadge(
                      rating: restaurant.rating),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: AppTextStyles.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${restaurant.deliveryTimeMin}-${restaurant.deliveryTimeMax} min',
                        style: AppTextStyles.bodySmall,
                      ),
                      const Text(' • ',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11)),
                      Expanded(
                        child: Text(
                          restaurant.category,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
// Nearby Restaurants – Vertical list
// ─────────────────────────────────────────────────────────────────────────────

class _NearbyRestaurantsList extends StatelessWidget {
  final List<Restaurant> restaurants;
  const _NearbyRestaurantsList({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: restaurants
            .map((r) => _NearbyRestaurantCard(
          restaurant: r,
          onTap: () =>
              context.push('/restaurant/${r.id}'),
        ))
            .toList(),
      ),
    );
  }
}

class _NearbyRestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const _NearbyRestaurantCard({
    required this.restaurant,
    required this.onTap,
  });

  String get _distanceText {
    // Simulate a distance
    final hash = restaurant.id.hashCode.abs() % 40;
    return '${(hash / 10 + 0.5).toStringAsFixed(1)} km';
  }

  bool get _isFreeDelivery => restaurant.deliveryFee < 50;

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
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: CachedImage(
                url: restaurant.imageUrl,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: AppTextStyles.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StarRatingBadge(
                          rating: restaurant.rating),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.cuisine,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _DeliveryBadge(
                        isFree: _isFreeDelivery,
                        fee: restaurant.deliveryFee,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.delivery_dining_rounded,
                          size: 13,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        _distanceText,
                        style: AppTextStyles.bodySmall,
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

class _DeliveryBadge extends StatelessWidget {
  final bool isFree;
  final double fee;

  const _DeliveryBadge({required this.isFree, required this.fee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFree
            ? AppColors.tagGreen.withAlpha(30)
            : AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        isFree ? 'Free Delivery' : 'Rs. ${fee.toInt()} Delivery.',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isFree ? AppColors.tagGreen : AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History FAB
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _HistoryFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.history_rounded,
            color: Colors.white, size: 24),
      ),
    );
  }
}