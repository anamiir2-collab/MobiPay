import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../widgets/fx.dart';
import '../widgets/qr_painter.dart';
import '../widgets/ui.dart';

/// Personal payment QR (receive side).
/// The drawn pattern is a VISUAL PLACEHOLDER — real receiving QR needs an
/// EMVCo/InstaPay payload from the PSP (see README §QR).
class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      titleEn: 'My QR',
      titleAr: 'رمزي الشخصي',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 262,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(26), boxShadow: C.shadowMd),
              child: Column(children: [
                Container(
                  width: 210,
                  height: 210,
                  color: Colors.white,
                  child: CustomPaint(painter: DemoQrPainter(seed: demoUser['handle']!)),
                ),
                const SizedBox(height: 16),
                Text(App.t(demoUser['name']!, demoUser['nameAr']!), style: T.h3.copyWith(color: C.text, fontSize: 17)),
                const SizedBox(height: 4),
                Text('${demoUser['handle']} · 0100 •• •• 678', style: T.small.copyWith(color: C.muted)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: C.primarySoft, borderRadius: BorderRadius.circular(20)),
                  child: Text('MobiPay', style: T.caption.copyWith(color: C.primary)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton('Share QR', 'مشاركة الرمز',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(App.t('QR shared (demo)', 'تمت مشاركة الرمز (تجريبي)')),
                  behavior: SnackBarBehavior.floating))),
          const SizedBox(height: 10),
          GhostButton('Save to gallery', 'حفظ في المعرض',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(App.t('Saved (demo)', 'تم الحفظ (تجريبي)')),
                  behavior: SnackBarBehavior.floating))),
          const SizedBox(height: 16),
          InfoNote(
            Icons.qr_code_2_rounded,
            'Demo pattern only — a real scannable InstaPay/EMVCo QR requires an official provider payload.',
            'نمط تجريبي فقط — رمز InstaPay/EMVCo حقيقي قابل للمسح يتطلب حمولة رسمية من المزوّد.',
            color: C.warning,
          ),
        ],
      ),
    );
  }
}
