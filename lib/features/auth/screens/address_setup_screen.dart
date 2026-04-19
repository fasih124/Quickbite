// lib/features/auth/screens/address_setup_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/mock_data.dart';

class AddressSetupScreen extends StatefulWidget {
  const AddressSetupScreen({super.key});

  @override
  State<AddressSetupScreen> createState() => _AddressSetupScreenState();
}

class _AddressSetupScreenState extends State<AddressSetupScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  int _selectedAddressIndex = 0;
  bool _isDetecting = false;

  // Pulse animation for the map pin
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // Blob drift animation
  late final AnimationController _blobController;
  late final Animation<double> _blobOffset;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: false);

    _pulseScale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _blobOffset = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _blobController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _blobController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _detectLocation() async {
    setState(() => _isDetecting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isDetecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location detected: F-7/2, Islamabad',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.tagGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmAddress() => context.push('/home');

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar ──────────────────────────────────────────────────
          _AddressAppBar(),

          // ── Scrollable content ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Where are we\ndelivering today?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Enter your address to see restaurants and\nstores near you delivering fresh meals.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Dark map card
                  _DarkMapCard(
                    pulseScale: _pulseScale,
                    pulseOpacity: _pulseOpacity,
                    blobOffset: _blobOffset,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Search bar
                  _AddressSearchBar(controller: _searchCtrl),

                  const SizedBox(height: AppSpacing.md),

                  // Detect location
                  _DetectLocationButton(
                    isDetecting: _isDetecting,
                    onTap: _detectLocation,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Saved addresses
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Saved Addresses',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _SavedAddressCard(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    subtitle: mockUser.addresses[0].fullAddress,
                    isSelected: _selectedAddressIndex == 0,
                    onTap: () =>
                        setState(() => _selectedAddressIndex = 0),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  _SavedAddressCard(
                    icon: Icons.work_rounded,
                    label: 'Work',
                    subtitle: mockUser.addresses.length > 1
                        ? mockUser.addresses[1].fullAddress
                        : 'Jinnah Avenue, Blue Area, Islamabad',
                    isSelected: _selectedAddressIndex == 1,
                    onTap: () =>
                        setState(() => _selectedAddressIndex = 1),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Confirm Address CTA ───────────────────────────────────────
          _ConfirmAddressButton(
            onTap: _confirmAddress,
            bottomPad: bottomPad,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _AddressAppBar extends StatelessWidget {
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
// Dark Map Card — custom painted dark map + animated orange blob + pulsing pin
// ─────────────────────────────────────────────────────────────────────────────

class _DarkMapCard extends StatelessWidget {
  final Animation<double> pulseScale;
  final Animation<double> pulseOpacity;
  final Animation<double> blobOffset;

  const _DarkMapCard({
    required this.pulseScale,
    required this.pulseOpacity,
    required this.blobOffset,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          children: [
            // Dark map background
            Positioned.fill(
              child: CustomPaint(
                painter: _DarkMapPainter(),
              ),
            ),

            // Animated orange blob coverage zone
            Positioned.fill(
              child: AnimatedBuilder(
                animation: blobOffset,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _OrangeBlobPainter(
                        offsetY: blobOffset.value),
                  );
                },
              ),
            ),

            // Pulsing ring + pin
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse ring
                  AnimatedBuilder(
                    animation: pulseScale,
                    builder: (context, _) {
                      return Opacity(
                        opacity: pulseOpacity.value,
                        child: Container(
                          width: 44 * pulseScale.value,
                          height: 44 * pulseScale.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary
                                .withOpacity(0.35),
                          ),
                        ),
                      );
                    },
                  ),

                  // Pin circle
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66D32F2F),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.location_on,
                        color: Colors.white, size: 26),
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

// ── Dark map grid painter ────────────────────────────────────────────────────

class _DarkMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A2332),
    );

    final roadPaint = Paint()
      ..color = const Color(0xFF2A3A50)
      ..strokeWidth = 6;

    final minorRoadPaint = Paint()
      ..color = const Color(0xFF243040)
      ..strokeWidth = 3;

    // Horizontal roads
    for (double y = 20; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Vertical roads
    for (double x = 25; x < size.width; x += 35) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
    // Diagonal
    canvas.drawLine(
        const Offset(0, 60), Offset(size.width * 0.7, size.height),
        minorRoadPaint);
    canvas.drawLine(
        Offset(size.width * 0.25, 0),
        Offset(size.width, size.height * 0.8),
        minorRoadPaint);
  }

  @override
  bool shouldRepaint(_DarkMapPainter old) => false;
}

// ── Orange blob coverage zone ────────────────────────────────────────────────

class _OrangeBlobPainter extends CustomPainter {
  final double offsetY;
  _OrangeBlobPainter({required this.offsetY});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + offsetY;

    final paint = Paint()
      ..color = const Color(0xCCE8822A)
      ..style = PaintingStyle.fill;

    // Draw organic blob using bezier curves
    final path = Path();
    path.moveTo(cx - 60, cy - 50);
    path.cubicTo(cx - 110, cy - 80, cx - 30, cy - 110, cx + 20, cy - 70);
    path.cubicTo(cx + 80, cy - 40, cx + 100, cy + 10, cx + 60, cy + 50);
    path.cubicTo(cx + 30, cy + 90, cx - 40, cy + 80, cx - 80, cy + 40);
    path.cubicTo(cx - 120, cy + 10, cx - 30, cy - 20, cx - 60, cy - 50);
    path.close();

    canvas.drawPath(path, paint);

    // Lighter inner blob
    final innerPaint = Paint()
      ..color = const Color(0x88F0A040)
      ..style = PaintingStyle.fill;

    final innerPath = Path();
    innerPath.moveTo(cx - 30, cy - 28);
    innerPath.cubicTo(
        cx - 60, cy - 45, cx + 10, cy - 55, cx + 35, cy - 30);
    innerPath.cubicTo(
        cx + 60, cy - 5, cx + 45, cy + 35, cx + 20, cy + 42);
    innerPath.cubicTo(
        cx - 10, cy + 50, cx - 50, cy + 30, cx - 55, cy + 5);
    innerPath.cubicTo(
        cx - 60, cy - 20, cx - 10, cy - 10, cx - 30, cy - 28);
    innerPath.close();

    canvas.drawPath(innerPath, innerPaint);

    // Small orange dot at top of blob
    canvas.drawCircle(
      Offset(cx + 20, cy - 72 + offsetY * 0.3),
      5,
      Paint()..color = const Color(0xFFFF8C42),
    );
  }

  @override
  bool shouldRepaint(_OrangeBlobPainter old) => old.offsetY != offsetY;
}

// ─────────────────────────────────────────────────────────────────────────────
// Address Search Bar
// ─────────────────────────────────────────────────────────────────────────────

class _AddressSearchBar extends StatefulWidget {
  final TextEditingController controller;
  const _AddressSearchBar({required this.controller});

  @override
  State<_AddressSearchBar> createState() => _AddressSearchBarState();
}

class _AddressSearchBarState extends State<_AddressSearchBar> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: _focused ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: widget.controller,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search for your street or building...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textHint),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
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
// Detect Current Location Button
// ─────────────────────────────────────────────────────────────────────────────

class _DetectLocationButton extends StatelessWidget {
  final bool isDetecting;
  final VoidCallback onTap;

  const _DetectLocationButton({
    required this.isDetecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDetecting ? null : onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDetecting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              const Icon(Icons.my_location_rounded,
                  color: AppColors.primary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isDetecting ? 'Detecting...' : 'Detect Current Location',
              style: GoogleFonts.poppins(
                fontSize: 15,
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

// ─────────────────────────────────────────────────────────────────────────────
// Saved Address Card
// ─────────────────────────────────────────────────────────────────────────────

class _SavedAddressCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SavedAddressCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon square
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm + 2),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),

            const SizedBox(width: AppSpacing.md),

            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Check if selected
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirm Address CTA
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmAddressButton extends StatelessWidget {
  final VoidCallback onTap;
  final double bottomPad;

  const _ConfirmAddressButton({
    required this.onTap,
    required this.bottomPad,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              'Confirm Address',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}