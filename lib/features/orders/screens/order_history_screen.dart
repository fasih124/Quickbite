// lib/features/orders/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../data/mock_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local order model for display
// ─────────────────────────────────────────────────────────────────────────────

class _DisplayOrder {
  final String id;
  final String restaurantName;
  final String restaurantImageUrl;
  final String restaurantId;
  final double total;
  final DateTime placedAt;
  final bool isOngoing;
  final String? statusLabel; // e.g. "PREPARING", "ON THE WAY"

  const _DisplayOrder({
    required this.id,
    required this.restaurantName,
    required this.restaurantImageUrl,
    required this.restaurantId,
    required this.total,
    required this.placedAt,
    required this.isOngoing,
    this.statusLabel,
  });
}

// Simulate ongoing + past orders from mock data
final _ongoingOrders = [
  _DisplayOrder(
    id: '#QB-88219',
    restaurantName: "Student Biryani",
    restaurantImageUrl:
    'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?w=400&q=80',
    restaurantId: 'r_1',
    total: 1109,
    placedAt: DateTime.now().subtract(const Duration(minutes: 18)),
    isOngoing: true,
    statusLabel: 'PREPARING',
  ),
];

final _pastOrders = [
  _DisplayOrder(
    id: '#QB-77102',
    restaurantName: 'Wok & Roll',
    restaurantImageUrl:
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
    restaurantId: 'r_5',
    total: 1089,
    placedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
    isOngoing: false,
  ),
  _DisplayOrder(
    id: '#QB-66514',
    restaurantName: 'Burger Lab',
    restaurantImageUrl:
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
    restaurantId: 'r_2',
    total: 1348,
    placedAt: DateTime.now().subtract(const Duration(days: 5, hours: 11)),
    isOngoing: false,
  ),
  _DisplayOrder(
    id: '#QB-55301',
    restaurantName: 'Shinwari Tikka House',
    restaurantImageUrl:
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&q=80',
    restaurantId: 'r_4',
    total: 2737,
    placedAt: DateTime.now().subtract(const Duration(days: 8, hours: 2)),
    isOngoing: false,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Tab provider
// ─────────────────────────────────────────────────────────────────────────────

final _activeTabProvider = StateProvider<int>((ref) => 0); // 0=Ongoing 1=Past

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(_activeTabProvider);
    final orders = activeTab == 0 ? _ongoingOrders : _pastOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── AppBar ──────────────────────────────────────────────────
          _HistoryAppBar(),

          // ── Scrollable content ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Text(
                    'Order History',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tracking your culinary adventures.',
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Tab switcher ─────────────────────────────────────
                  _TabSwitcher(
                    activeIndex: activeTab,
                    onChanged: (i) =>
                    ref.read(_activeTabProvider.notifier).state = i,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Order cards ──────────────────────────────────────
                  if (orders.isEmpty)
                    _EmptyOrdersState(isOngoing: activeTab == 0)
                  else
                    ...orders.map((order) => _OrderCard(
                      order: order,
                      onTrack: () => context.push('/tracking'),
                      onDetails: () {},
                      onReorder: () =>
                          context.push('/restaurant/${order.restaurantId}'),
                      onReview: () {},
                      onReceipt: () {},
                    )),
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
// AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryAppBar extends StatelessWidget {
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
// Tab Switcher — pill toggle
// ─────────────────────────────────────────────────────────────────────────────

class _TabSwitcher extends StatelessWidget {
  final int activeIndex;
  final void Function(int) onChanged;

  const _TabSwitcher({
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          _TabPill(
            label: 'Ongoing',
            isActive: activeIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabPill(
            label: 'Past',
            isActive: activeIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: isActive ? AppShadows.subtle : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final _DisplayOrder order;
  final VoidCallback onTrack;
  final VoidCallback onDetails;
  final VoidCallback onReorder;
  final VoidCallback onReview;
  final VoidCallback onReceipt;

  const _OrderCard({
    required this.order,
    required this.onTrack,
    required this.onDetails,
    required this.onReorder,
    required this.onReview,
    required this.onReceipt,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDay =
    DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(orderDay).inDays;

    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$h:$m $suffix';

    if (diff == 0) return 'Today, $timeStr';
    if (diff == 1) return 'Yesterday, $timeStr';

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // ── Main content ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: thumbnail + info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(AppRadius.md),
                        child: CachedImage(
                          url: order.restaurantImageUrl,
                          width: 80,
                          height: 80,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.md),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // Leave space for badge if ongoing
                            if (order.isOngoing)
                              const SizedBox(height: AppSpacing.xl),

                            Text(
                              order.restaurantName,
                              style: AppTextStyles.headlineSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.id} • ${_formatDate(order.placedAt)}',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rs. ${order.total.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Action buttons
                  order.isOngoing
                      ? _OngoingActions(
                    onTrack: onTrack,
                    onDetails: onDetails,
                  )
                      : _PastActions(
                    orderId: order.id,
                    onReorder: onReorder,
                    onReview: onReview,
                    onReceipt: onReceipt,
                  ),
                ],
              ),
            ),

            // ── Status badge — top right corner ──────────────────────
            if (order.statusLabel != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    order.statusLabel!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Ongoing action buttons ────────────────────────────────────────────────────

class _OngoingActions extends StatelessWidget {
  final VoidCallback onTrack;
  final VoidCallback onDetails;

  const _OngoingActions({
    required this.onTrack,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Track Order',
            onTap: onTrack,
            style: _ButtonStyle.grey,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionButton(
            label: 'Order Details',
            onTap: onDetails,
            style: _ButtonStyle.red,
          ),
        ),
      ],
    );
  }
}

// ── Past action buttons ───────────────────────────────────────────────────────

class _PastActions extends StatelessWidget {
  final String orderId;
  final VoidCallback onReorder;
  final VoidCallback onReview;
  final VoidCallback onReceipt;

  const _PastActions({
    required this.orderId,
    required this.onReorder,
    required this.onReview,
    required this.onReceipt,
  });

  // Show "Leave Review" for more recent, "View Receipt" for older
  bool get _showReview =>
      (int.tryParse(orderId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0) > 70000;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Reorder',
            onTap: onReorder,
            style: _ButtonStyle.redText,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionButton(
            label: _showReview ? 'Leave Review' : 'View Receipt',
            onTap: _showReview ? onReview : onReceipt,
            style: _ButtonStyle.greyOutlined,
          ),
        ),
      ],
    );
  }
}

// ── Shared action button ──────────────────────────────────────────────────────

enum _ButtonStyle { grey, red, redText, greyOutlined }

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _ButtonStyle style;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;

    switch (style) {
      case _ButtonStyle.grey:
        bgColor = const Color(0xFFF0F0F0);
        textColor = AppColors.textPrimary;
        break;
      case _ButtonStyle.red:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case _ButtonStyle.redText:
        bgColor = const Color(0xFFF0F0F0);
        textColor = AppColors.primary;
        break;
      case _ButtonStyle.greyOutlined:
        bgColor = Colors.transparent;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.divider, width: 1.5);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: border,
          boxShadow: style == _ButtonStyle.red ? AppShadows.subtle : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyOrdersState extends StatelessWidget {
  final bool isOngoing;
  const _EmptyOrdersState({required this.isOngoing});

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
              child: Icon(
                isOngoing
                    ? Icons.delivery_dining_outlined
                    : Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isOngoing ? 'No active orders' : 'No past orders',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isOngoing
                  ? 'Place an order to see it here'
                  : 'Your completed orders will appear here',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}