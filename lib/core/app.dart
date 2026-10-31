import 'package:flutter/material.dart';

/// Global app state for the prototype.
///
/// Locale switching rebuilds the whole tree so every screen flips between
/// English LTR and Arabic RTL (spec §9: full Arabic RTL + English LTR).
class App {
  App._();

  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));
  static final ValueNotifier<bool> dark = ValueNotifier(false);

  /// Bump after any mock-data mutation so tab screens re-read the lists.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static bool get isAr => locale.value.languageCode == 'ar';
  static bool get isDark => dark.value;
  static TextDirection get dir => isAr ? TextDirection.rtl : TextDirection.ltr;

  /// Inline translation helper: S.t('My Cards', 'بطاقاتي')
  static String t(String en, String ar) => isAr ? ar : en;

  static void toggleLocale() =>
      locale.value = isAr ? const Locale('en') : const Locale('ar');

  static void notifyChanged() => revision.value++;
}
