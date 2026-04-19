// lib/features/checkout/screens/order_confirmed_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';

class OrderConfirmedScreen extends StatefulWidget {
  const OrderConfirmedScreen({super.key});

  @override
  State<OrderConfirmedScreen> createState() => _OrderConfirmedScreenState();
}

class _OrderConfirmedScreenState extends State<OrderConfirmedScreen>
    with TickerProviderStateMixin {

  // ── Only two controllers needed now ──────────────────────────────────────
  late final AnimationController _contentController;
  late final AnimationController _bottomController;

  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  late final String _orderId;
  late final String _deliveryWindow;

  @override
  void initState() {
    super.initState();

    // Generate order ID
    final rand = Random();
    final letters = String.fromCharCodes(
        List.generate(2, (_) => rand.nextInt(26) + 65));
    final digits = (10000 + rand.nextInt(89999)).toString();
    _orderId = '#$letters-$digits';
    _deliveryWindow = '24 – 32 min';

    // Content slides up after Lottie finishes
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));

    // Bottom label fades in last
    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Lottie drives its own timing via _onLottieComplete()
  }

  // Called by _LottieCheckIcon when animation finishes
  void _onLottieComplete() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _bottomController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          topPad + AppSpacing.xxxl,
          AppSpacing.lg,
          bottomPad + AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Lottie check ───────────────────────────────────────────
            _LottieCheckIcon(onComplete: _onLottieComplete),

            const SizedBox(height: AppSpacing.xxl),

            // ── Title + subtitle ───────────────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: Column(
                  children: [
                    Text(
                      'Order Placed!',
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your culinary journey has begun.',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Order info card ────────────────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: _OrderInfoCard(
                  orderId: _orderId,
                  deliveryWindow: _deliveryWindow,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Track My Order ─────────────────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: SlideTransition(
                position: _contentSlide,
                child: _TrackOrderButton(
                  onTap: () => context.push('/tracking'),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Return Home ────────────────────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: GestureDetector(
                onTap: () => context.push('/home'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Return Home',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Greyscale food image ───────────────────────────────────
            FadeTransition(
              opacity: _contentFade,
              child: _GreyscaleFoodImage(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Help footer ────────────────────────────────────────────
            FadeTransition(
              opacity: FadeTransition(opacity: _contentFade).opacity,
              child: _HelpFooter(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lottie Check Icon
// ─────────────────────────────────────────────────────────────────────────────

class _LottieCheckIcon extends StatefulWidget {
  final VoidCallback onComplete;
  const _LottieCheckIcon({required this.onComplete});

  @override
  State<_LottieCheckIcon> createState() => _LottieCheckIconState();
}

class _LottieCheckIconState extends State<_LottieCheckIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/check_success.json',
      controller: _lottieController,
      width: 140,
      height: 140,
      onLoaded: (composition) {
        _lottieController
          ..duration = composition.duration
          ..forward().then((_) => widget.onComplete());
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderInfoCard extends StatelessWidget {
  final String orderId;
  final String deliveryWindow;

  const _OrderInfoCard({
    required this.orderId,
    required this.deliveryWindow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER ID',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderId,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'STATUS',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Confirmed',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius:
                    BorderRadius.circular(AppRadius.sm + 2),
                  ),
                  child: const Icon(Icons.timer_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Arrival',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deliveryWindow,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Track My Order Button
// ─────────────────────────────────────────────────────────────────────────────

class _TrackOrderButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TrackOrderButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
              color: AppColors.primary.withOpacity(0.40),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Track My Order',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greyscale Food Image
// ─────────────────────────────────────────────────────────────────────────────

class _GreyscaleFoodImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: CachedImage(
          url:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80',
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Help Footer
// ─────────────────────────────────────────────────────────────────────────────

class _HelpFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
              fontSize: 13, color: AppColors.textSecondary),
          children: [
            const TextSpan(text: 'Need help? '),
            TextSpan(
              text: 'Contact Support',
              style: GoogleFonts.poppins(
                fontSize: 13,
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