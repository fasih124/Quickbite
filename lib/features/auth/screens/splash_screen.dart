// lib/features/auth/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────────────────

  // Logo: scale up from 0.6 + fade in
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Badge dot: pops in after logo
  late final AnimationController _badgeController;
  late final Animation<double> _badgeScale;

  // Name + tagline: slide up + fade in
  late final AnimationController _textController;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // Tagline separately (staggered after name)
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  // Bottom label: last to appear
  late final AnimationController _bottomController;
  late final Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();

    // Hide status bar for full immersion
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // ── Logo (0ms → 700ms) ────────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // ── Badge dot (400ms → 700ms) ─────────────────────────────────────
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );

    // ── Name + subtitle (600ms → 1100ms) ─────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Tagline staggered inside same controller
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    // ── Bottom label (1200ms → 1600ms) ────────────────────────────────
    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeIn),
    );

    // ── Sequence ──────────────────────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Step 1: Logo
    await _logoController.forward();

    // Step 2: Badge dot
    await Future.delayed(const Duration(milliseconds: 50));
    await _badgeController.forward();

    // Step 3: Text
    await Future.delayed(const Duration(milliseconds: 100));
    await _textController.forward();

    // Step 4: Bottom
    await Future.delayed(const Duration(milliseconds: 200));
    await _bottomController.forward();

    // Step 5: Navigate after a pause
    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      context.push('/login');
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _logoController.dispose();
    _badgeController.dispose();
    _textController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EE),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              Color(0xFFFAF6F4), // light warm center
              Color(0xFFEDE5E0), // slightly darker warm edges
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Main content — vertically centered slightly above middle ──
            Positioned.fill(
              child: Column(
                children: [
                  // Top spacer — ~35% of screen
                  SizedBox(height: size.height * 0.32),

                  // ── Logo block ───────────────────────────────────────
                  _AnimatedLogo(
                    logoScale: _logoScale,
                    logoFade: _logoFade,
                    badgeScale: _badgeScale,
                  ),

                  const SizedBox(height: 28),

                  // ── App name + curator label ─────────────────────────
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: _AppNameBlock(),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Tagline ──────────────────────────────────────────
                  FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: _Tagline(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom label — pinned to bottom ───────────────────────
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 28,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _bottomFade,
                child: _BottomLabel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Logo
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedLogo extends StatelessWidget {
  final Animation<double> logoScale;
  final Animation<double> logoFade;
  final Animation<double> badgeScale;

  const _AnimatedLogo({
    required this.logoScale,
    required this.logoFade,
    required this.badgeScale,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: logoFade,
      child: ScaleTransition(
        scale: logoScale,
        child: SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── White outer card ─────────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE53935),
                        Color(0xFFC62828),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant_menu_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // ── Red notification dot (top-right) ─────────────────────
              Positioned(
                top: -2,
                right: 2,
                child: ScaleTransition(
                  scale: badgeScale,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFF5F0EE), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Name Block — "Quick" dark + "Bite" red + subtitle
// ─────────────────────────────────────────────────────────────────────────────

class _AppNameBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // QuickBite
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Quick',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2A2A2A),
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Bite',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFC62828),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // THE KINETIC CURATOR
        Text(
          'THE KINETIC CURATOR',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFAAAAAA),
            letterSpacing: 3.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tagline
// ─────────────────────────────────────────────────────────────────────────────

class _Tagline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Text(
        'Transcending delivery into a sensory\njourney of flavors.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF888888),
          height: 1.65,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Label — "CURATED BY CULINARY EDITORIAL" with divider lines
// ─────────────────────────────────────────────────────────────────────────────

class _BottomLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Row(
        children: [
          // Left divider
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFCCCCCC),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Text(
            'CURATED BY CULINARY EDITORIAL',
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFAAAAAA),
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Right divider
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFCCCCCC),
            ),
          ),
        ],
      ),
    );
  }
}