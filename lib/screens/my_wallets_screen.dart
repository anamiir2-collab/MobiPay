import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../widgets/ui.dart';
import '../widgets/wallet_card.dart';
import 'add_wallet_screen.dart';

class MyWalletsScreen extends StatefulWidget {
  const MyWalletsScreen({super.key});
  @override
  State<MyWalletsScreen> createState() => _MyWalletsScreenState();
}

class _MyWalletsScreenState extends State<MyWalletsScreen> {
  @override
  Widget build(BuildContext context) {
    return Screen(
      titleEn: 'My Wallets',
      titleAr: 'محافظي الإلكترونية',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(App.t('Egyptian mobile wallets linked to MobiPay', 'المحافظ المصرية المرتبطة بـ MobiPay'),
              style: T.small.copyWith(color: C.muted)),
          const SizedBox(height: 14),
          ...userWallets.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WalletCardWidget(
                  w,
                  selected: w.isDefault,
                  onTap: () {
                    setState(() {
                      for (final x in userWallets) {
                        x.isDefault = x == w;
                      }
                    });
                    App.notifyChanged();
                  },
                  onRemove: () => _confirmRemove(w),
                ),
              )),
          const SizedBox(height: 6),
          PrimaryButton('Add wallet', 'إضافة محفظة', onTap: _add),
          const SizedBox(height: 18),
          InfoNote(
            Icons.info_outline_rounded,
            'Adding a wallet does NOT enable NFC payments — wallet payments and QR workflows work only through the provider\'s official API integration.',
            'إضافة المحفظة لا تُفعّل الدفع عبر NFC — تعمل مدفوعات المحافظ ورموز QR فقط من خلال تكامل واجهات المزوّد الرسمية.',
            color: C.warning,
          ),
          const SizedBox(height: 12),
          InfoNote(
            Icons.shield_rounded,
            'Only the masked wallet number is stored on the device.',
            'يتم تخزين رقم المحفظة مُقنَّعًا فقط على الجهاز.',
            color: C.success,
          ),
        ],
      ),
    );
  }

  void _add() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddWalletScreen()));
    if (mounted) setState(() {});
  }

  void _confirmRemove(EWallet w) {
    showDialog(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(App.t('Unlink wallet?', 'إلغاء ربط المحفظة؟'), style: T.h3.copyWith(color: C.text)),
        content: Text(App.t('${w.provider.nameEn} · ${w.masked} will be removed from MobiPay.',
            'سيتم إزالة ${w.provider.nameAr} · ${w.masked} من MobiPay.'),
            style: T.body.copyWith(color: C.sub, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: Text(App.t('Cancel', 'إلغاء'))),
          TextButton(
            onPressed: () {
              setState(() => userWallets.remove(w));
              App.notifyChanged();
              Navigator.pop(dctx);
            },
            child: Text(App.t('Remove', 'إزالة'), style: const TextStyle(color: C.error)),
          ),
        ],
      ),
    );
  }
}
