import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../widgets/fx.dart';
import '../widgets/ui.dart';
import '../widgets/wallet_card.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});
  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  WalletProvider? _provider;
  final _phone = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  bool get _ready => _provider != null && _phone.text.replaceAll(' ', '').length == 11;

  Future<void> _link() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    final digits = _phone.text.replaceAll(' ', '');
    final masked = '${digits.substring(0, 4)} •• ${digits.substring(7)}';
    userWallets.add(EWallet(
      id: 'w_${DateTime.now().millisecondsSinceEpoch}',
      provider: _provider!,
      masked: masked,
    ));
    App.notifyChanged();
    setState(() => _busy = false);
    showDialog(
      context: context,
      builder: (dctx) => Dialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SuccessBurst(size: 96),
            const SizedBox(height: 14),
            Text(App.t('Wallet linked', 'تم ربط المحفظة'), style: T.h3.copyWith(color: C.text)),
            const SizedBox(height: 6),
            Text(
              App.t('${_provider!.nameEn} · $masked',
                  '${_provider!.nameAr} · $masked'),
              style: T.small.copyWith(color: C.muted),
            ),
            const SizedBox(height: 12),
            InfoNote(
              Icons.api_rounded,
              'Demo links instantly. Production requires the provider\'s official OTP/API confirmation.',
              'الربط فوري في العرض التجريبي. في الإنتاج يتطلب تأكيد OTP/واجهة برمجة المزوّد الرسمية.',
              color: C.warning,
            ),
            const SizedBox(height: 16),
            PrimaryButton('Done', 'تم', onTap: () {
              Navigator.of(dctx).pop();
              Navigator.of(context).pop();
            }),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      titleEn: 'Add e-wallet',
      titleAr: 'إضافة محفظة',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(App.t('Select the wallet provider', 'اختر مزوّد المحفظة'),
              style: T.h3.copyWith(color: C.text)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: walletProviders
                .map((p) => ProviderTile(p,
                    selected: _provider == p,
                    onTap: () {
                      _phone.text = p.id == 'vf'
                          ? '010'
                          : p.id == 'og'
                              ? '012'
                              : p.id == 'et'
                                  ? '011'
                                  : '015';
                      setState(() => _provider = p);
                    }))
                .toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            onChanged: (_) => setState(() {}),
            decoration: D.field(context, App.t('Wallet mobile number', 'رقم موبايل المحفظة'))
                .copyWith(counterText: ''),
          ),
          const SizedBox(height: 18),
          if (_provider != null) ...[
            WalletCardWidget(
              EWallet(id: 'preview', provider: _provider!, masked: _previewMasked()),
            ),
            const SizedBox(height: 18),
          ],
          PrimaryButton('Link wallet', 'ربط المحفظة', onTap: _ready && !_busy ? _link : null, enabled: _ready && !_busy),
          const SizedBox(height: 14),
          InfoNote(
            Icons.info_outline_rounded,
            'Wallet payments & QR workflows are supported only where the provider officially integrates with MobiPay.',
            'تُدعم مدفوعات المحافظ ورموز QR فقط حيث يتوفر تكامل رسمي بين المزوّد و MobiPay.',
            color: C.warning,
          ),
        ],
      ),
    );
  }

  String _previewMasked() {
    final d = _phone.text.replaceAll(' ', '');
    if (d.length < 8) return '•••• •• •••';
    return '${d.substring(0, 4)} •• ${d.substring(7)}';
  }
}
