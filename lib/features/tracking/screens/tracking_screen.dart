// lib/features/tracking/screens/tracking_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Order step model
// ─────────────────────────────────────────────────────────────────────────────

enum StepStatus { completed, inProgress, pending }

class _OrderStep {
  final String title;
  final String time;
  final String description;
  final StepStatus status;
  final IconData icon;
  final String? progressBadge;
  final String? riderNote;

  const _OrderStep({
    required this.title,
    required this.time,
    required this.description,
    required this.status,
    required this.icon,
    this.progressBadge,
    this.riderNote,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock rider data
// ─────────────────────────────────────────────────────────────────────────────

class _RiderInfo {
  final String name;
  final double rating;
  final String reviewCount;
  final String avatarUrl;
  final String vehicle;
  final String plate;

  const _RiderInfo({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.avatarUrl,
    required this.vehicle,
    required this.plate,
  });
}

const _rider = _RiderInfo(
  name: 'Marco Santoro',
  rating: 4.9,
  reviewCount: '2.4k deliveries',
  avatarUrl:
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
  vehicle: 'Electric Scooter',
  plate: 'BK-992-RT',
);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {
  // Rider position animation — moves across the mock map
  late final AnimationController _riderMoveController;
  late final Animation<Offset> _riderPosition;

  // Pulse animation for the in-progress node
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  // Clock tick for estimated arrival display
  late Timer _clockTimer;
  late String _arrivalTime;

  static const _steps = [
    _OrderStep(
      title: 'Order Placed',
      time: '12:10 PM',
      description:
      'We\'ve received your order and sent it to the restaurant.',
      status: StepStatus.completed,
      icon: Icons.check_rounded,
    ),
    _OrderStep(
      title: 'Preparing Food',
      time: '12:15 PM',
      description: 'The chef is working their magic on your gourmet meal.',
      status: StepStatus.completed,
      icon: Icons.check_rounded,
    ),
    _OrderStep(
      title: 'Out for Delivery',
      time: '',
      description:
      'Marco is on the way! He\'s about 8 minutes away from you.',
      status: StepStatus.inProgress,
      icon: Icons.electric_moped_rounded,
      progressBadge: 'IN PROGRESS',
      riderNote:
      '"I\'m using a thermal bag to keep your food hot!" – Marco',
    ),
    _OrderStep(
      title: 'Delivered',
      time: 'Est. 12:45 PM',
      description: 'Enjoy your meal from The Culinary Editorial.',
      status: StepStatus.pending,
      icon: Icons.inventory_2_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _arrivalTime = '12:45 PM';

    // Rider moves slightly on the map
    _riderMoveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _riderPosition = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(8, -6),
    ).animate(CurvedAnimation(
      parent: _riderMoveController,
      curve: Curves.easeInOut,
    ));

    // Pulse for in-progress node
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Clock timer — just keeps the UI ticking
    _clockTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _riderMoveController.dispose();
    _pulseController.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar ──────────────────────────────────────────────────
          _TrackingAppBar(
            arrivalTime: _arrivalTime,
            onBack: () => context.safePop(),
          ),

          // ── Scrollable body ─────────────────────────────────────────
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
                  // Map
                  _MockMapWidget(
                    riderPosition: _riderPosition,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Rider card
                  _RiderCard(rider: _rider),

                  const SizedBox(height: AppSpacing.md),

                  // Order Journey
                  _OrderJourneyCard(
                    steps: _steps,
                    pulseScale: _pulseScale,
                  ),

                  const SizedBox(height: 80),
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

class _TrackingAppBar extends StatelessWidget {
  final String arrivalTime;
  final VoidCallback onBack;

  const _TrackingAppBar({
    required this.arrivalTime,
    required this.onBack,
  });

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

          // Title
          Text(
            'Tracking',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          // Estimated arrival
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ESTIMATED ARRIVAL',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    arrivalTime,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.access_time_rounded,
                        color: AppColors.primary, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock Map Widget — custom painted street grid + animated pins
// ─────────────────────────────────────────────────────────────────────────────

class _MockMapWidget extends StatelessWidget {
  final Animation<Offset> riderPosition;

  const _MockMapWidget({required this.riderPosition});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: 230,
        child: Stack(
          children: [
            // Map background — custom painter
            Positioned.fill(
              child: CustomPaint(painter: _MapGridPainter()),
            ),

            // Restaurant pin — top-left area
            Positioned(
              top: 60,
              left: 60,
              child: _MapPin(
                icon: Icons.restaurant_rounded,
                label: 'The Bistro',
                isRestaurant: true,
              ),
            ),

            // Home pin — center-right
            Positioned(
              top: 118,
              right: 70,
              child: _HomePill(),
            ),

            // Rider pin — animated
            AnimatedBuilder(
              animation: riderPosition,
              builder: (context, _) {
                return Positioned(
                  top: 95 + riderPosition.value.dy,
                  left: 155 + riderPosition.value.dx,
                  child: _RiderPin(label: 'Marco (Rider)'),
                );
              },
            ),

            // Map controls — bottom right
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                children: [
                  _MapControlBtn(icon: Icons.my_location_rounded),
                  const SizedBox(height: 8),
                  _MapControlBtn(icon: Icons.add_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map grid painter ──────────────────────────────────────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE8EBE4),
    );

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final minorRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 4;

    // Draw horizontal roads
    for (double y = 30; y < size.height; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Draw vertical roads
    for (double x = 40; x < size.width; x += 55) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Minor roads diagonal ish
    canvas.drawLine(
        const Offset(0, 80), Offset(size.width * 0.6, size.height),
        minorRoadPaint);
    canvas.drawLine(
        Offset(size.width * 0.3, 0),
        Offset(size.width, size.height * 0.7),
        minorRoadPaint);

    // Block fills between roads
    final blockPaint = Paint()..color = const Color(0xFFD6DAD2);
    canvas.drawRect(
        const Rect.fromLTWH(42, 32, 50, 40), blockPaint);
    canvas.drawRect(
        const Rect.fromLTWH(97, 32, 50, 40), blockPaint);
    canvas.drawRect(
        const Rect.fromLTWH(152, 77, 50, 36), blockPaint);
    canvas.drawRect(
        const Rect.fromLTWH(42, 122, 50, 40), blockPaint);
    canvas.drawRect(
        const Rect.fromLTWH(207, 32, 50, 40), blockPaint);
    canvas.drawRect(
        const Rect.fromLTWH(262, 77, 50, 36), blockPaint);
    canvas.drawRect(
        const Rect.fromLTWH(207, 122, 50, 40), blockPaint);
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => false;
}

// ── Map pins ──────────────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isRestaurant;

  const _MapPin({
    required this.icon,
    required this.label,
    this.isRestaurant = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isRestaurant
                ? const Color(0xFF1A1A1A)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 14),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: AppShadows.subtle,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RiderPin extends StatelessWidget {
  final String label;
  const _RiderPin({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.electric_moped_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadows.subtle,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.card,
      ),
      child: Text(
        'Your Home',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MapControlBtn extends StatelessWidget {
  final IconData icon;
  const _MapControlBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: AppShadows.subtle,
      ),
      child: Icon(icon, size: 18, color: AppColors.textPrimary),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rider Card
// ─────────────────────────────────────────────────────────────────────────────

class _RiderCard extends StatelessWidget {
  final _RiderInfo rider;
  const _RiderCard({required this.rider});

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
        children: [
          // ── Avatar + name + call/chat ────────────────────────────────
          Row(
            children: [
              // Avatar with online dot
              Stack(
                children: [
                  ClipOval(
                    child: CachedImage(
                      url: rider.avatarUrl,
                      width: 56,
                      height: 56,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        shape: BoxShape.circle,
                        border:
                        Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: AppSpacing.md),

              // Name + rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rider.name,
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.starYellow, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${rider.rating} (${rider.reviewCount})',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Call + chat buttons ──────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                      BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.call_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Call ${rider.name.split(' ').first}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Chat button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.chat_rounded,
                      color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),

          // ── Vehicle info rows ────────────────────────────────────────
          _InfoRow(label: 'Vehicle', value: rider.vehicle),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Plate', value: rider.plate),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

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
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Journey Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderJourneyCard extends StatelessWidget {
  final List<_OrderStep> steps;
  final Animation<double> pulseScale;

  const _OrderJourneyCard({
    required this.steps,
    required this.pulseScale,
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
          Text('Order Journey', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.lg),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;
            return _JourneyStep(
              step: step,
              isLast: isLast,
              pulseScale: pulseScale,
            );
          }),
        ],
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  final _OrderStep step;
  final bool isLast;
  final Animation<double> pulseScale;

  const _JourneyStep({
    required this.step,
    required this.isLast,
    required this.pulseScale,
  });

  Color get _nodeColor {
    switch (step.status) {
      case StepStatus.completed:
        return AppColors.primary;
      case StepStatus.inProgress:
        return AppColors.primary;
      case StepStatus.pending:
        return const Color(0xFFCCCCCC);
    }
  }

  Color get _titleColor {
    switch (step.status) {
      case StepStatus.completed:
        return AppColors.textPrimary;
      case StepStatus.inProgress:
        return AppColors.primary;
      case StepStatus.pending:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: node + connecting line ─────────────────────────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Node
                _StepNode(step: step, pulseScale: pulseScale),

                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: step.status == StepStatus.completed
                            ? AppColors.primary
                            : const Color(0xFFDDDDDD),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // ── Right: step content ───────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _titleColor,
                          ),
                        ),
                      ),
                      if (step.progressBadge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.10),
                            borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            step.progressBadge!,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        )
                      else if (step.time.isNotEmpty)
                        Text(
                          step.time,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    step.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: step.status == StepStatus.pending
                          ? AppColors.textHint
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  // Rider note bubble
                  if (step.riderNote != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.07),
                        borderRadius:
                        BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 1),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.riderNote!,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: AppColors.primary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
// Step Node — completed / in-progress (pulsing) / pending
// ─────────────────────────────────────────────────────────────────────────────

class _StepNode extends StatelessWidget {
  final _OrderStep step;
  final Animation<double> pulseScale;

  const _StepNode({required this.step, required this.pulseScale});

  @override
  Widget build(BuildContext context) {
    if (step.status == StepStatus.inProgress) {
      // Pulsing outlined circle with bike icon
      return AnimatedBuilder(
        animation: pulseScale,
        builder: (context, child) {
          return Transform.scale(
            scale: pulseScale.value,
            child: child,
          );
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(step.icon, color: AppColors.primary, size: 18),
        ),
      );
    }

    if (step.status == StepStatus.completed) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(step.icon, color: Colors.white, size: 18),
      );
    }

    // Pending
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        shape: BoxShape.circle,
        border: Border.all(
            color: const Color(0xFFDDDDDD), width: 2),
      ),
      child: Icon(step.icon, color: const Color(0xFFBBBBBB), size: 18),
    );
  }
}