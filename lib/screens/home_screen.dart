import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../widgets/ui.dart';
import 'my_cards_screen.dart';
import 'my_wallets_screen.dart';
import 'nfc_pay_screen.dart';
import 'qr_scan_screen.dart';
import 'recharge_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = DateTime.now().hour;
    final greeting = h < 12
        ? App.t('Good morning', 'صباح الخير')
        : h < 18
            ? App.t('Good afternoon', 'مساء الخير')
            : App.t('Good evening', 'مساء الخير');
    final def = userCards.where((c) => c.isDefault).firstOrNull ?? userCards.first;

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            /* ── header ── */
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => App.revision.value++, // profile lives in shell tab 3
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(gradient: C.gradPrimary, shape: BoxShape.circle),
                    child: const Center(
                        child: Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(greeting, style: T.small.copyWith(color: C.muted)),
                    Text(App.t(demoUser['name']!, demoUser['nameAr']!),
                        style: T.h3.copyWith(color: C.text, fontSize: 17)),
                  ]),
                ),
                Stack(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: C.card, shape: BoxShape.circle, border: Border.all(color: C.line)),
                    child: const Icon(Icons.notifications_none_rounded, size: 21, color: C.text),
                  ),
                  Positioned(
                    top: 9,
                    right: 11,
                    child: Container(width: 8, height: 8, decoration: BoxDecoration(color: C.error, shape: BoxShape.circle, border: Border.all(color: C.card, width: 1.4))),
                  ),
                ]),
              ]),
            ),

            /* ── default payment method ── */
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _toTab(context, 1),
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: D.card(),
                  child: Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [def.bank.c1, def.bank.c2]),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(child: Text(def.bank.short, style: TextStyle(color: def.bank.accent, fontWeight: FontWeight.w800, fontSize: 10))),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(App.t('Default payment method', 'طريقة الدفع الافتراضية'),
                            style: T.small.copyWith(color: C.muted, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          App.isAr ? '${def.bank.displayAr} ••${def.last4}' : '${def.bank.displayEn} ••${def.last4}',
                          style: T.semi.copyWith(color: C.text, fontSize: 13.5),
                        ),
                      ]),
                    ),
                    Text(App.t('Change', 'تغيير'), style: T.semi.copyWith(color: C.primary, fontSize: 12.5)),
                  ]),
                ),
              ),
            ),

            /* ── NFC hero action ── */
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NfcPayScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: C.gradPrimaryDeep,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: C.primary.withOpacity(0.4), blurRadius: 22, offset: const Offset(0, 10))],
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const DemoBadge(),
                        const SizedBox(height: 8),
                        Text(App.t('Pay with NFC', 'ادفع باللمس'),
                            style: T.h2.copyWith(color: Colors.white, fontSize: 21)),
                        Text('ادفع باللمس', style: T.small.copyWith(color: Colors.white.withOpacity(0.65))),
                        const SizedBox(height: 6),
                        Text(
                          App.t('Hold your phone near any contactless terminal', 'قرّب هاتفك من أي نقطة دفع بالتقريب'),
                          style: T.small.copyWith(color: Colors.white.withOpacity(0.85), height: 1.4),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), shape: BoxShape.circle),
                      child: const Icon(Icons.contactless_rounded, color: Colors.white, size: 30),
                    ),
                  ]),
                ),
              ),
            ),

            /* ── quick actions ── */
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(children: [
                _QuickAction(icon: Icons.qr_code_scanner_rounded, tint: C.secondarySoft,
                    labelEn: 'Scan QR', labelAr: 'مسح رمز',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrScanScreen()))),
                _QuickAction(icon: Icons.credit_card_rounded, tint: C.primarySoft,
                    labelEn: 'My Cards', labelAr: 'بطاقاتي',
                    onTap: () => _toTab(context, 1)),
                _QuickAction(icon: Icons.account_balance_wallet_rounded, tint: C.successSoft,
                    labelEn: 'My Wallets', labelAr: 'محافظي',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyWalletsScreen()))),
                _QuickAction(icon: Icons.phone_android_rounded, tint: C.warningSoft,
                    labelEn: 'Recharge', labelAr: 'شحن رصيد',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RechargeScreen()))),
              ]),
            ),

            /* ── recently used payment methods ── */
            const SizedBox(height: 22),
            SectionTitle(App.t('Recently used', 'الأحدث استخدامًا')),
            SizedBox(
              height: 58,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...userCards.take(2).map((c) => _MethodChip(
                        gradient: LinearGradient(colors: [c.bank.c1, c.bank.c2]),
                        short: c.bank.short,
                        label: App.isAr ? '${c.bank.displayAr} ••${c.last4}' : '${c.bank.displayEn} ••${c.last4}',
                      )),
                  _MethodChip(
                    gradient: const LinearGradient(colors: [Color(0xFFE60000), Color(0xFF9E0000)]),
                    short: 'VC',
                    label: App.t('Vodafone Cash · 0100 •• 845', 'فودافون كاش · 0100 •• 845'),
                  ),
                ],
              ),
            ),

            /* ── recent transactions ── */
            const SizedBox(height: 22),
            SectionTitle(App.t('Recent transactions', 'آخر العمليات'),
                actionEn: 'See all', actionAr: 'عرض الكل',
                onAction: () => _toTab(context, 2)),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: D.card(),
              child: Column(children: [
                TxTile(txns[0], onTap: () => _toTab(context, 2)),
                Divider(height: 1, color: C.line, indent: 16, endIndent: 16),
                TxTile(txns[1], onTap: () => _toTab(context, 2)),
                Divider(height: 1, color: C.line, indent: 16, endIndent: 16),
                TxTile(txns[2], onTap: () => _toTab(context, 2)),
              ]),
            ),

            /* ── trust note ── */
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InfoNote(
                Icons.shield_rounded,
                'MobiPay never displays or stores full card numbers — payments run on secure tokens.',
                'لا يعرض MobiPay أرقام البطاقات الكاملة أو يخزنها — تعمل المدفوعات عبر رموز آمنة (Tokens).',
                color: C.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toTab(BuildContext context, int tab) {
    // Profile shell uses IndexedStack; for the prototype, pushed flows simply
    // open the matching standalone screen.
    if (tab == 2) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyCardsScreen()));
    }
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String labelEn, labelAr;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.tint, required this.labelEn, required this.labelAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsetsDirectional.only(end: 10),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: D.card(radius: 16),
          child: Column(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: C.text),
            ),
            const SizedBox(height: 7),
            Text(App.t(labelEn, labelAr),
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: T.caption.copyWith(color: C.sub, fontSize: 10.5)),
          ]),
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final Gradient gradient;
  final String short, label;
  const _MethodChip({required this.gradient, required this.short, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(15), border: Border.all(color: C.line)),
      child: Row(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(9)),
          child: Center(child: Text(short, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800))),
        ),
        const SizedBox(width: 8),
        Text(label, style: T.semi.copyWith(fontSize: 11.5, color: C.text)),
      ]),
    );
  }
}
