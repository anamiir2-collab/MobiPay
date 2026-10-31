import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../models/models.dart';

/* ==================================================================
 * Realistic Egyptian bank card visual (spec §2).
 * Each bank renders with its own gradient identity + emblem. Production
 * should place official bank SVG logos in assets/banks/ and swap the
 * emblem below for Image.asset — see README "Bank card artwork".
 * ================================================================== */

class BankCardWidget extends StatelessWidget {
  final BankCard card;
  /// Manual-entry preview can reveal the typed number while the user is
  /// entering it; after tokenization only the masked form is ever shown.
  final String? previewPan;
  final EdgeInsets padding;
  const BankCardWidget(this.card, {super.key, this.previewPan, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) {
    final b = card.bank;
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [b.c1, b.c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: C.shadowMd,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(children: [
            // diagonal sheen
            Positioned(
              right: -40,
              top: -60,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(width: 190, height: 340, color: Colors.white.withOpacity(0.06)),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -110,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(width: 90, height: 340, color: Colors.white.withOpacity(0.05)),
              ),
            ),
            Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _BankEmblem(bank: b, dark: false),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(b.displayEn, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: T.semi.copyWith(color: Colors.white, fontSize: 13)),
                        Text(b.displayAr, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: T.small.copyWith(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                      ]),
                    ),
                    Icon(Icons.contactless_rounded, color: Colors.white.withOpacity(0.8), size: 20),
                  ]),
                  const Spacer(),
                  Text(
                    previewPan != null ? _group(previewPan!) : '••••  ••••  ••••  ${card.last4}',
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2.2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(App.t('CARD HOLDER', 'حامل البطاقة'),
                            style: TextStyle(fontSize: 8.5, letterSpacing: 1.2, color: b.accent.withOpacity(0.9))),
                        const SizedBox(height: 2),
                        Text(card.holder, style: T.semi.copyWith(color: Colors.white, fontSize: 12, letterSpacing: 0.6)),
                      ]),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(App.t('VALID THRU', 'صالحة حتى'),
                          style: TextStyle(fontSize: 8.5, letterSpacing: 1.2, color: b.accent.withOpacity(0.9))),
                      const SizedBox(height: 2),
                      Text(card.exp, style: T.semi.copyWith(color: Colors.white, fontSize: 12)),
                    ]),
                    const SizedBox(width: 14),
                    _BrandMark(brand: card.brand),
                  ]),
                ],
              ),
            ),
            if (card.frozen) _FrozenOverlay(),
          ]),
        ),
      ),
    );
  }

  static String _group(String pan) {
    final clean = pan.replaceAll(' ', '');
    final sb = StringBuffer();
    for (var i = 0; i < clean.length; i += 4) {
      sb.write(clean.substring(i, i + 4 > clean.length ? clean.length : i + 4));
      if (i + 4 < clean.length) sb.write('  ');
    }
    return sb.toString();
  }
}

class _BankEmblem extends StatelessWidget {
  final BankBrand bank;
  final bool dark;
  const _BankEmblem({required this.bank, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: dark ? Colors.black.withOpacity(0.06) : Colors.white.withOpacity(0.14),
        shape: BoxShape.circle,
        border: Border.all(color: bank.accent.withOpacity(0.85), width: 1.2),
      ),
      child: Center(
        child: Text(bank.short,
            style: TextStyle(
              color: bank.accent,
              fontWeight: FontWeight.w800,
              fontSize: bank.short.length > 3 ? 10.5 : 12.5,
              letterSpacing: 0.5,
            )),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final PayBrand brand;
  const _BrandMark({required this.brand});

  @override
  Widget build(BuildContext context) {
    if (brand == PayBrand.visa) {
      return Text('VISA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ));
    }
    return SizedBox(
      width: 44,
      height: 26,
      child: Stack(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(width: 25, height: 25,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFEB001B).withOpacity(0.92))),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(width: 25, height: 25,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF79E1B).withOpacity(0.9))),
        ),
      ]),
    );
  }
}

class _FrozenOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white54),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.ac_unit_rounded, color: Colors.white, size: 15),
              const SizedBox(width: 6),
              Text(App.t('Frozen', 'مجمّدة'), style: T.semi.copyWith(color: Colors.white, fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Compact row representation used in lists & pickers.
class BankCardRow extends StatelessWidget {
  final BankCard card;
  final VoidCallback? onTap;
  final Widget? trailing;
  const BankCardRow(this.card, {super.key, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: D.card(radius: 16),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [card.bank.c1, card.bank.c2]),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(card.bank.short,
                  style: TextStyle(color: card.bank.accent, fontWeight: FontWeight.w800, fontSize: 11)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(App.t(card.bank.displayEn, card.bank.displayAr),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: T.semi.copyWith(color: C.text, fontSize: 13.5)),
                ),
                if (card.isDefault) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: C.primarySoft, borderRadius: BorderRadius.circular(6)),
                    child: Text(App.t('DEFAULT', 'افتراضية'), style: T.caption.copyWith(color: C.primary, fontSize: 8.5)),
                  ),
                ],
              ]),
              const SizedBox(height: 3),
              Text(
                App.t(
                  '${card.brand == PayBrand.visa ? 'Visa' : 'Mastercard'} ••${card.last4}${card.viaNfc ? '  ·  added via NFC' : ''}',
                  '${card.brand == PayBrand.visa ? 'فيزا' : 'ماستركارد'} ••${card.last4}${card.viaNfc ? '  ·  أُضيفت باللمس NFC' : ''}',
                ),
                style: T.small.copyWith(color: C.muted, fontSize: 11.5),
              ),
            ]),
          ),
          trailing ?? const Icon(Icons.chevron_right, color: C.muted),
        ]),
      ),
    );
  }
}
