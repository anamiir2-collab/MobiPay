import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../widgets/bank_card.dart';
import '../widgets/ui.dart';
import '../widgets/wallet_card.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';
import 'my_wallets_screen.dart';

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});
  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 2),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(App.t('My Cards', 'بطاقاتي'), style: T.h1.copyWith(color: C.text)),
                    Text(App.t('Your Egyptian bank cards', 'بطاقات البنوك المصرية الخاصة بك'),
                        style: T.small.copyWith(color: C.muted)),
                  ]),
                ),
                const DemoBadge(),
              ]),
            ),

            /* ── card carousel ── */
            if (userCards.isNotEmpty) ...[
              SizedBox(
                height: 254,
                child: PageView.builder(
                  itemCount: userCards.length,
                  viewportFraction: 0.88,
                  onPageChanged: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _page = i);
                  },
                  controller: PageController(viewportFraction: 0.88, initialPage: _page),
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    child: GestureDetector(
                      onTap: () => _openDetail(userCards[i]),
                      child: BankCardWidget(userCards[i]),
                    ),
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < userCards.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    width: i == _page ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page ? C.primary : C.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ]),
              /* quick actions for the visible card */
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  Expanded(
                    child: GhostButton('Details', 'التفاصيل',
                        onTap: () => _openDetail(userCards[_page.clamp(0, userCards.length - 1)]))),
                  const SizedBox(width: 10),
                  Expanded(child: GhostButton('Freeze', 'تجميد', onTap: () => _toggleFreeze(userCards[_page.clamp(0, userCards.length - 1)]))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GhostButton(
                      userCards[_page.clamp(0, userCards.length - 1)].isDefault
                          ? App.t('Default ✓', 'افتراضية ✓')
                          : App.t('Set default', 'تعيين افتراضية'),
                      userCards[_page.clamp(0, userCards.length - 1)].isDefault
                          ? 'افتراضية ✓'
                          : 'تعيين افتراضية',
                      color: userCards[_page.clamp(0, userCards.length - 1)].isDefault ? C.success : null,
                      onTap: () => _setDefault(userCards[_page.clamp(0, userCards.length - 1)]),
                    ),
                  ),
                ]),
              ),
            ],

            /* ── all cards list ── */
            const SizedBox(height: 20),
            SectionTitle(App.t('All payment methods', 'كل طرق الدفع')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                ...userCards.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: BankCardRow(c, onTap: () => _openDetail(c)),
                    )),
                ...userWallets.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WalletCardWidget(w),
                    )),
                _AddTile(
                  icon: Icons.add_card_rounded,
                  labelEn: 'Add new card',
                  labelAr: 'إضافة بطاقة جديدة',
                  onTap: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const AddCardScreen()));
                    if (mounted) setState(() {});
                  },
                ),
                const SizedBox(height: 10),
                _AddTile(
                  icon: Icons.account_balance_wallet_rounded,
                  labelEn: 'Add e-wallet',
                  labelAr: 'إضافة محفظة إلكترونية',
                  onTap: () async {
                    await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const MyWalletsScreen()));
                    if (mounted) setState(() {});
                  },
                ),
              ]),
            ),

            /* ── security note ── */
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InfoNote(
                Icons.lock_rounded,
                'Card details are captured by a PCI DSS-compliant provider. MobiPay keeps only the last 4 digits and a payment token.',
                'تُلتقط بيانات البطاقة عبر مزود متوافق مع PCI DSS. يحتفظ MobiPay فقط بآخر 4 أرقام وبرمز دفع (Token).',
                color: C.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BankCard card) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CardDetailScreen(card: card)));
    if (mounted) setState(() {});
  }

  void _toggleFreeze(BankCard card) {
    HapticFeedback.mediumImpact();
    setState(() => card.frozen = !card.frozen);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(card.frozen
          ? App.t('${card.bank.displayEn} ••${card.last4} frozen', 'تم تجميد ••${card.last4}')
          : App.t('Card unfrozen', 'تم إلغاء التجميد')),
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.text,
    ));
  }

  void _setDefault(BankCard card) {
    if (card.isDefault) return;
    HapticFeedback.selectionClick();
    setState(() {
      for (final c in userCards) {
        c.isDefault = c == card;
      }
    });
    App.notifyChanged();
  }
}

class _AddTile extends StatelessWidget {
  final IconData icon;
  final String labelEn, labelAr;
  final VoidCallback onTap;
  const _AddTile({required this.icon, required this.labelEn, required this.labelAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorder(color: C.muted.withOpacity(0.55), radius: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 20, color: C.primary),
            const SizedBox(width: 8),
            Text(App.t(labelEn, labelAr), style: T.semi.copyWith(color: C.primary, fontSize: 13.5)),
          ]),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorder({required this.color, required this.radius});
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final next = (d + 6).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, next), Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.4);
        d = next + 5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder old) => old.color != color;
}
