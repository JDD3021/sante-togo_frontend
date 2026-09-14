import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography for Dekera
///
/// - Titles and branding: Baloo 2 (rounded, warm), weight 700-800
/// - Interface/content text: Inter (neutral, very readable), min 16px body, 14px labels
/// - Minimum font size: 12px (no text below this anywhere)
class AppTextStyles {
  AppTextStyles._();

  // Brand/Title font - Baloo 2 for warmth and approachability
  static TextStyle get brand => GoogleFonts.baloo2(
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );

  static TextStyle get brandBold => GoogleFonts.baloo2(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  // Body font - Inter for readability
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      );

  static TextStyle get bodyBold => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  // Secondary text
  static TextStyle get secondary => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.inkSoft,
      );

  static TextStyle get secondaryMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.inkSoft,
      );

  // Labels (minimum 14px per requirements)
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.inkSoft,
      );

  // Minimum allowed font size (12px) - use sparingly
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.inkSoft,
      );

  // Headings
  static TextStyle get h1 => GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );

  static TextStyle get h2 => GoogleFonts.baloo2(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      );

  static TextStyle get h3 => GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get h4 => GoogleFonts.baloo2(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );
}
