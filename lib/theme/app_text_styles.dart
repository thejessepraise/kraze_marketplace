import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A small, shared typographic scale.
///
/// WHY THIS EXISTS:
/// Screens were each picking their own font sizes/weights for headings,
/// section titles, etc. (24/bold here, 22/w700 there). This file gives
/// every screen the same few text styles to pull from, so headings and
/// section titles read as consistent across the whole app.
///
/// This intentionally stays small — just the handful of styles that
/// actually repeat across screens. Not a full typography system.
class AppTextStyles {
  /// Big page-level heading. e.g. "Favorites", "Messages", "Profile".
  static const TextStyle pageTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  );

  /// Muted subtitle/description directly under a page title.
  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Section headers within a page. e.g. "Recent Listings", "Categories".
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  /// Small label above a form field (e.g. Post Item's "Item Title",
  /// "Price", "Category", "Description"). Color is intentionally left
  /// to the caller (usually colorScheme.onSurfaceVariant) since this
  /// style is used on both light and dark surfaces.
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// The Kraze wordmark in the "Glitch" brand font, for use OUTSIDE
  /// Splash — small brand touches only (e.g. a header lockup), not full
  /// headings. Rule of thumb: one small Glitch mark per screen, at most.
  static const TextStyle brandMark = TextStyle(
    fontFamily: 'Glitch',
    fontWeight: FontWeight.w900,
    letterSpacing: 0.5,
  );
}

/// The Kraze brand gradient (same colors as the Splash "K" mark).
///
/// WHY A SHARED GETTER:
/// Splash already defines this gradient inline. Rather than every screen
/// inventing its own gradient colors/angles (which is explicitly what
/// we're avoiding), anything that wants "the Kraze gradient" pulls from
/// here so it's always the same two brand colors.
class AppGradients {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accentPrice],
  );
}

/// Shared spacing scale. Use these instead of ad-hoc SizedBox/padding
/// numbers so vertical rhythm stays consistent between screens.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
