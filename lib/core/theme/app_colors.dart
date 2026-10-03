import 'package:flutter/material.dart';

/// Centralized color palette for the Algorithm Visualizer.
///
/// Keep application colors here instead of declaring them inside
/// individual screens. This gives the entire application a single
/// source of truth for its visual identity.
abstract final class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // DARK BACKGROUNDS
  // ---------------------------------------------------------------------------

  static const Color background = Color(0xFF030712);
  static const Color background2 = Color(0xFF07101F);
  static const Color card = Color(0xFF0B1428);

  // ---------------------------------------------------------------------------
  // LIGHT BACKGROUNDS
  // ---------------------------------------------------------------------------

  static const Color lightBackground = Color(0xFFF3F7FC);
  static const Color lightBackground2 = Color(0xFFF8FAFC);
  static const Color lightCard = Colors.white;

  // ---------------------------------------------------------------------------
  // PRIMARY TEXT
  // ---------------------------------------------------------------------------

  static const Color darkPrimaryText = Color(0xFFF8FAFC);
  static const Color lightPrimaryText = Color(0xFF172033);

  // ---------------------------------------------------------------------------
  // SECONDARY TEXT
  // ---------------------------------------------------------------------------

  static const Color darkSecondaryText = Color(0xFF94A3B8);
  static const Color lightSecondaryText = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // MUTED TEXT
  // ---------------------------------------------------------------------------

  static const Color darkMutedText = Color(0xFF64748B);
  static const Color lightMutedText = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // BORDER
  // ---------------------------------------------------------------------------

  static const Color lightBorder = Color(0xFFD9E2EC);

  // ---------------------------------------------------------------------------
  // ACCENT COLORS
  // ---------------------------------------------------------------------------

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color pink = Color(0xFFFF4081);

  // ---------------------------------------------------------------------------
  // STATUS COLORS
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF29B6F6);
}