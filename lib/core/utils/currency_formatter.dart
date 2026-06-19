import 'package:intl/intl.dart';

/// Centralized currency formatting utility for the TravelHub app.
///
/// All monetary values displayed in the UI must go through this class
/// so that formatting is consistent across every screen.
///
/// ### Rules
/// - Whole numbers (or values with only trailing zeros) are shown without
///   a decimal part:  `35329.0  →  35,329 EGP`
/// - Values with genuine decimal precision are preserved:
///   `35329.75  →  35,329.75 EGP`
/// - Thousands separators are always added:
///   `10450  →  10,450 EGP`
class CurrencyFormatter {
  CurrencyFormatter._(); // static-only class — not instantiable

  // ── formatters (created once, reused on every call) ─────────────────────

  /// Formats an integer-like amount: no decimal portion.
  static final _wholeFormat = NumberFormat('#,##0', 'en_US');

  /// Formats an amount that has genuine fractional digits (up to 2 d.p.).
  static final _decimalFormat = NumberFormat('#,##0.##', 'en_US');

  // ── public API ───────────────────────────────────────────────────────────

  /// Returns a formatted price string with the "EGP" currency suffix.
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.format(35329.0)   // "35,329 EGP"
  /// CurrencyFormatter.format(10450.0)   // "10,450 EGP"
  /// CurrencyFormatter.format(2424.0)    // "2,424 EGP"
  /// CurrencyFormatter.format(35329.75)  // "35,329.75 EGP"
  /// ```
  static String format(double amount, {String currency = 'EGP'}) {
    final formatted = _hasDecimals(amount)
        ? _decimalFormat.format(amount)
        : _wholeFormat.format(amount);
    return '$formatted $currency';
  }

  /// Returns only the numeric portion (with thousands separators), without
  /// the currency suffix. Useful when the suffix is rendered separately.
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.formatNumber(35329.0)   // "35,329"
  /// CurrencyFormatter.formatNumber(35329.75)  // "35,329.75"
  /// ```
  static String formatNumber(double amount) {
    return _hasDecimals(amount)
        ? _decimalFormat.format(amount)
        : _wholeFormat.format(amount);
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  /// Returns true when [amount] has a non-zero fractional part.
  static bool _hasDecimals(double amount) => amount != amount.truncateToDouble();
}
