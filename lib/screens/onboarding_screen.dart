import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../widgets/fx.dart';
import 'unlock_screen.dart';

class _Page {
  final Widget visual;
  final String titleEn, titleAr, bodyEn, bodyAr;
  const _Page(this.visual, this.titleEn, this.titleAr, this.bodyEn, this.bodyAr);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _i = 0;

  late final List<_Page> _pages = [
    _Page(
      const NfcPulse(size: 170),
      'Tap to pay, everywhere',
      'ادفع باللمس في كل مكان',
      'Use your phone as a card at any contactless terminal — no cash, no queue.',
      'استخدم هاتفك كبطاقة عند أي نقطة دفع بالتقريب — بدون نقود ولا طوابير.',
    ),
    _Page(
      Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(34), boxShadow: C.shadowMd),
        child: Icon(Icons.qr_code_2_rounded, size: 110, color: C.primary),
      ),
      'Scan & pay in seconds',
      'امسح وادفع في ثوانٍ',
      'Scan merchant QR codes or show yours to receive payments instantly.',
      'امسح رمز QR للتاجر أو اعرض رمزك لاستلام المدفوعات فورًا.',
    ),
    _Page(
      SizedBox(
        width: 190,
        height: 170,
        child: Stack(children: [
          Positioned(top: 0, left: 30, child: Transform.rotate(angle: -0.09, child: _miniCard(C.secondary))),
          Positioned(top: 26, left: 6, child: Transform.rotate(angle: 0.07, child: _miniCard(C.primary))),
        ]),
      ),
      'All your payment methods',
      'كل بطاقاتك ومحافظك',
      'Egyptian bank cards and mobile wallets in one app — choose how to pay.',
      'بطاقات البنوك المصرية والمحافظ الإلكترونية في تطبيق واحد — اختر كيف تدفع.',
    ),
  ];

  static Widget _miniCard(Color c) => Container(
        width: 150,
        height: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c, c.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: C.shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Icon(Icons.contactless_rounded, color: Colors.white70, size: 18),
            Text('••••  •• 4582', style: T.semi.copyWith(color: Colors.white, fontSize: 12, letterSpacing: 1.4)),
          ]),
        ),
      );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.selectionClick();
    if (_i < _pages.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UnlockScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _i == _pages.length - 1;
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (_) => const UnlockScreen())),
                child: Text(App.t('Skip', 'تخطي'), style: T.semi.copyWith(color: C.muted)),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (context, i) {
                final p = _pages[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: p.visual),
                      const SizedBox(height: 40),
                      Text(App.t(p.titleEn, p.titleAr),
                          textAlign: TextAlign.center, style: T.h1.copyWith(color: C.text)),
                      const SizedBox(height: 12),
                      Text(App.t(p.bodyEn, p.bodyAr),
                          textAlign: TextAlign.center,
                          style: T.body.copyWith(color: C.sub, height: 1.55)),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _i ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _i ? C.primary : C.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(gradient: C.gradPrimary, borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _next,
                    child: Center(
                      child: Text(last ? App.t('Get started', 'ابدأ الآن') : App.t('Next', 'التالي'),
                          style: T.button.copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
