import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app.dart';
import '../core/style.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'my_cards_screen.dart';
import 'profile_screen.dart';
import 'nfc_pay_screen.dart';
import 'qr_scan_screen.dart';

/// Bottom navigation: Home · Cards · [NFC FAB] · QR · History.
/// Profile is reached from the home header avatar (premium iOS feel).
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  static const _screens = [
    HomeScreen(),
    MyCardsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _go(int i) {
    HapticFeedback.selectionClick();
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: IndexedStack(index: _tab, children: _screens),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const NfcPayScreen())),
          child: Container(
            decoration: BoxDecoration(
              gradient: C.gradPrimaryDeep,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: C.primary.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: const Icon(Icons.contactless_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: C.card,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _NavItem(icon: Icons.home_rounded, activeIcon: Icons.home_rounded,
              labelEn: 'Home', labelAr: 'الرئيسية', active: _tab == 0, onTap: () => _go(0)),
          _NavItem(icon: Icons.credit_card_rounded, activeIcon: Icons.credit_card_rounded,
              labelEn: 'Cards', labelAr: 'البطاقات', active: _tab == 1, onTap: () => _go(1)),
          const SizedBox(width: 56),
          _NavItem(icon: Icons.qr_code_scanner_rounded, activeIcon: Icons.qr_code_scanner_rounded,
              labelEn: 'Scan', labelAr: 'مسح', active: false, onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const QrScanScreen()));
              }),
          _NavItem(icon: Icons.receipt_long_rounded, activeIcon: Icons.receipt_long_rounded,
              labelEn: 'History', labelAr: 'السجل', active: _tab == 2, onTap: () => _go(2)),
        ]),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String labelEn, labelAr;
  final bool active;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.labelEn,
      required this.labelAr,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = active ? C.primary : C.muted;
    return InkResponse(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(active ? activeIcon : icon, size: 23, color: c),
          const SizedBox(height: 3),
          Text(App.t(labelEn, labelAr),
              style: T.caption.copyWith(color: c, fontSize: 10)),
        ]),
      ),
    );
  }
}
