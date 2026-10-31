import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../widgets/ui.dart';
import 'my_cards_screen.dart';
import 'my_wallets_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _bio = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
          children: [
            Text(App.t('Profile & Settings', 'الملف الشخصي والإعدادات'),
                style: T.h1.copyWith(color: C.text)),
            const SizedBox(height: 14),

            /* user card */
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(gradient: C.gradPrimaryDeep, borderRadius: BorderRadius.circular(22), boxShadow: C.shadowMd),
              child: Row(children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                  child: const Center(child: Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(App.t(demoUser['name']!, demoUser['nameAr']!),
                        style: T.h3.copyWith(color: Colors.white, fontSize: 17)),
                    const SizedBox(height: 3),
                    Text('${demoUser['phone']} · ${demoUser['handle']}',
                        style: T.small.copyWith(color: Colors.white.withOpacity(0.75))),
                  ]),
                ),
              ]),
            ),

            /* payment methods */
            const SizedBox(height: 18),
            _header(App.t('Payment methods', 'طرق الدفع')),
            _card([
              _row(Icons.credit_card_rounded, App.t('My Cards', 'بطاقاتي'),
                  '${userCards.length} ${App.t('linked', 'مرتبطة')}',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyCardsScreen()))),
              _divider(),
              _row(Icons.account_balance_wallet_rounded, App.t('My Wallets', 'محافظي الإلكترونية'),
                  '${userWallets.length} ${App.t('linked', 'مرتبطة')}',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyWalletsScreen()))),
            ]),

            /* preferences */
            const SizedBox(height: 16),
            _header(App.t('Preferences', 'التفضيلات')),
            _card([
              _row(Icons.language_rounded, App.t('Language', 'اللغة'),
                  App.isAr ? 'العربية' : 'English', _switchLang),
              _divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Icon(Icons.dark_mode_rounded, size: 21, color: C.sub),
                  const SizedBox(width: 12),
                  Expanded(child: Text(App.t('Dark mode', 'الوضع الليلي'), style: T.semi.copyWith(color: C.text, fontSize: 14))),
                  Switch(
                    value: App.isDark,
                    activeColor: C.primary,
                    onChanged: (v) => setState(() => App.dark.value = v),
                  ),
                ]),
              ),
              _divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Icon(Icons.face_retouching_natural_rounded, size: 21, color: C.sub),
                  const SizedBox(width: 12),
                  Expanded(child: Text(App.t('Biometric unlock', 'الدخول بالبصمة'), style: T.semi.copyWith(color: C.text, fontSize: 14))),
                  Switch(value: _bio, activeColor: C.primary, onChanged: (v) => setState(() => _bio = v)),
                ]),
              ),
            ]),

            /* support */
            const SizedBox(height: 16),
            _header(App.t('Support', 'الدعم')),
            _card([
              _row(Icons.report_problem_rounded, App.t('Report a problem', 'الإبلاغ عن مشكلة'), '', () {}),
              _divider(),
              _row(Icons.description_rounded, App.t('Terms & privacy', 'الشروط والخصوصية'), '', () {}),
              _divider(),
              _row(Icons.info_outline_rounded, App.t('About MobiPay', 'عن MobiPay'), 'v2.0.0', () {}),
            ]),

            const SizedBox(height: 20),
            GhostButton(App.t('Log out', 'تسجيل الخروج'), 'تسجيل الخروج',
                color: C.error, onTap: () {}),
            const SizedBox(height: 14),
            InfoNote(
              Icons.shield_rounded,
              'MobiPay is a unified payment app. Features requiring bank/provider APIs or regulatory approval are clearly marked in the app and README.',
              'MobiPay تطبيق دفع موحّد. الميزات التي تتطلب واجهات بنكية/مزوّدين أو موافقات تنظيمية مُعلَّمة بوضوح في التطبيق وملف README.',
            ),
          ],
        ),
      ),
    );
  }

  void _switchLang() {
    App.toggleLocale();
    setState(() {});
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        child: Text(t, style: T.caption.copyWith(color: C.muted, letterSpacing: 1)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: D.card(),
        child: Column(children: children),
      );

  Widget _divider() => Divider(height: 1, color: C.line, indent: 52);

  Widget _row(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(children: [
          Icon(icon, size: 21, color: C.sub),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: T.semi.copyWith(color: C.text, fontSize: 14))),
          if (value.isNotEmpty)
            Text(value, style: T.small.copyWith(color: C.muted, fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 19, color: C.muted),
        ]),
      ),
    );
  }
}
