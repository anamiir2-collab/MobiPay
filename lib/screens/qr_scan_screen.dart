import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../widgets/fx.dart';
import '../widgets/ui.dart';
import 'my_qr_screen.dart';
import 'qr_confirm_screen.dart';

/// Merchant QR scanner.
/// DEMO: auto-"detects" a mock merchant after a short delay.
/// Real scanning uses mobile_scanner (camera) — see README §QR.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});
  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 3400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => QrConfirmScreen(merchant: qrMerchants[0])));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F16),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 20, 0),
            child: Row(children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
              const Spacer(),
              const DemoBadge(),
              const SizedBox(width: 10),
              Text(App.t('Scan merchant QR', 'امسح رمز التاجر'),
                  style: T.h3.copyWith(color: Colors.white, fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 26),
          Center(
            child: SizedBox(
              width: 248,
              height: 248,
              child: Stack(children: [
                Container(
                  margin: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const ClipRRect(child: LaserLine()),
                ),
                // corner accents
                ..._corners(),
              ]),
            ),
          ),
          const SizedBox(height: 26),
          Text(App.t('Align the merchant QR inside the frame', 'اضبط رمز QR للتاجر داخل الإطار'),
              style: T.body.copyWith(color: Colors.white.withOpacity(0.75))),
          const SizedBox(height: 8),
          Text(App.t('Demo — detects automatically after a moment', 'تجريبي — يتم التعرف تلقائيًا بعد لحظات'),
              style: T.small.copyWith(color: Colors.white38)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              _circleBtn(Icons.flash_off_rounded, App.t('Torch', 'الفلاش')),
              const SizedBox(width: 12),
              Expanded(
                child: GhostButton('Show my QR', 'عرض رمزي',
                    color: Colors.white,
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const MyQrScreen()))),
              ),
            ]),
          ),
          const SizedBox(height: 22),
        ]),
      ),
    );
  }

  List<Widget> _corners() => [
        _c(Alignment.topLeft, true, true),
        _c(Alignment.topRight, false, true),
        _c(Alignment.bottomLeft, true, false),
        _c(Alignment.bottomRight, false, false),
      ];

  Widget _c(Alignment a, bool left, bool top) {
    return Align(
      alignment: a,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: C.secondary, width: left ? 3.4 : 0),
            right: BorderSide(color: C.secondary, width: left ? 0 : 3.4),
            top: BorderSide(color: C.secondary, width: top ? 3.4 : 0),
            bottom: BorderSide(color: C.secondary, width: top ? 0 : 3.4),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, String tooltip) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white70, size: 22),
    );
  }
}
