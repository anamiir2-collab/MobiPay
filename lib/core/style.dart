import 'package:flutter/material.dart';

import 'app.dart';

/// MobiPay design tokens – ported from the existing token sheet and re-branded
/// for MobiPay (spec §9). Light + dark palettes.
class C {
  C._();

  // Brand
  static const Color primary = Color(0xFF6C3CE0);
  static const Color primaryDeep = Color(0xFF4B21A8);
  static const Color secondary = Color(0xFF2D9CDB);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFEB5757);
  static const Color warning = Color(0xFFF2994A);

  // Light palette
  static const Color _bgL = Color(0xFFF7F8FA);
  static const Color _cardL = Color(0xFFFFFFFF);
  static const Color _altL = Color(0xFFF0F1F5);
  static const Color _inputL = Color(0xFFEEF0F4);
  static const Color _lineL = Color(0xFFE7E9F0);
  static const Color _textL = Color(0xFF101828);
  static const Color _subL = Color(0xFF5B6472);
  static const Color _mutedL = Color(0xFF98A2B3);

  // Dark palette
  static const Color dBg = Color(0xFF0C0F16);
  static const Color _bgD = Color(0xFF0C0F16);
  static const Color _cardD = Color(0xFF161B24);
  static const Color _altD = Color(0xFF1D232E);
  static const Color _inputD = Color(0xFF1C222D);
  static const Color _lineD = Color(0x14FFFFFF);
  static const Color _textD = Color(0xFFF4F6FA);
  static const Color _subD = Color(0xFFA7B0BF);
  static const Color _mutedD = Color(0xFF69748A);

  static Color get bg => App.isDark ? _bgD : _bgL;
  static Color get card => App.isDark ? _cardD : _cardL;
  static Color get alt => App.isDark ? _altD : _altL;
  static Color get input => App.isDark ? _inputD : _inputL;
  static Color get line => App.isDark ? _lineD : _lineL;
  static Color get text => App.isDark ? _textD : _textL;
  static Color get sub => App.isDark ? _subD : _subL;
  static Color get muted => App.isDark ? _mutedD : _mutedL;

  static Color get primarySoft =>
      App.isDark ? const Color(0x338B5CF6) : const Color(0x1F6C3CE0);
  static Color get secondarySoft =>
      App.isDark ? const Color(0x333FA8E0) : const Color(0x242D9CDB);
  static Color get successSoft =>
      App.isDark ? const Color(0x332ECC71) : const Color(0x2127AE60);
  static Color get errorSoft =>
      App.isDark ? const Color(0x33F0616D) : const Color(0x1FEB5757);
  static Color get warningSoft =>
      App.isDark ? const Color(0x33F2A54A) : const Color(0x26F2994A);

  static const LinearGradient gradPrimary = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient gradPrimaryDeep = LinearGradient(
    colors: [Color(0xFF4B21A8), Color(0xFF6C3CE0), Color(0xFF2D9CDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: App.isDark
              ? Colors.black.withOpacity(0.35)
              : const Color(0x12101828),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ];
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: App.isDark
              ? Colors.black.withOpacity(0.5)
              : const Color(0x1F101828),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}

/// Typography (Inter via system default in the prototype; ship Inter TTFs in
/// assets/fonts for production – see README).
class T {
  T._();
  static const TextStyle display =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 0.2);
  static const TextStyle h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w800);
  static const TextStyle h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  static const TextStyle h3 = TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600);
  static const TextStyle body = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400);
  static const TextStyle semi = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600);
  static const TextStyle small = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400);
  static const TextStyle caption =
      TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4);
  static const TextStyle button = TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600);
  static const TextStyle num =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 1.6);
}

/// Shared decorations.
class D {
  D._();
  static BoxDecoration card({double radius = 18, Color? color}) => BoxDecoration(
        color: color ?? C.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: C.line),
        boxShadow: C.shadowSm,
      );
  static InputDecoration field(BuildContext context, String hint,
      {Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: C.input,
      hintStyle: T.body.copyWith(color: C.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: C.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.primary, width: 1.6),
      ),
    );
  }
}
