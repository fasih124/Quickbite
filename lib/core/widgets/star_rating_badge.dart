// lib/core/widgets/star_rating_badge.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StarRatingBadge extends StatelessWidget {
  final double rating;
  final Color backgroundColor;
  final Color textColor;

  const StarRatingBadge({
    super.key,
    required this.rating,
    this.backgroundColor = Colors.white,
    this.textColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.starYellow, size: 14),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}