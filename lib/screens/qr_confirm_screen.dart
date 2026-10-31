import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/payment_service.dart';
import '../widgets/fx.dart';
import '../widgets/ui.dart';

/// Confirm a QR payment: review merchant → amount → source → pay.
class QrConfirmScreen extends StatefulWidget {
  final Merchant merchant;
  final double presetAmount;
  const QrConfirmScreen({super.key, required this.merchant, this.presetAmount = 312.40});
  @override
  State<QrConfirmScreen> createState() => _QrConfirmScreenState();
}

enum _QrStep { confirm, paying, success }

class _QrConfirmScreenState extends State<QrConfirmScreen> {
  _QrStep _step = _QrStep.confirm;
  PaySource? _source;
  late double _amount = widget.presetAmount;
  String? _ref;

  @override
  void initState() {
    super.initState();
    _source = PaySource.card(userCards.first);
  }

  Future<void> _pay() async {
    setState(() => _step = _QrStep.paying);
    final r = await PaymentService.simulateCharge(
        amount: _amount, method: 'QR — ${_source!.labelEn}');
    if (!mounted) return;
    setState(() {
      _ref = r['ref'];
      _step = _QrStep.success;
    });
    txns.insert(
      0,
      Txn(
        id: 't_${DateTime.now().millisecondsSinceEpoch}',
        type: TxType.qr,
        title: widget.merchant.name,
        method: 'QR — ${_source!.labelEn}',
        category: widget.merchant.categoryEn,
        ref: _ref!,
        amount: -_amount,
        date: DateTime.now(),
        status: TxStatus.success,
      ),
    );
    App.notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.merchant;
    return Screen(
      titleEn: 'Confirm payment',
      titleAr: 'تأكيد الدفع',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_step == _QrStep.success) ...[
            const SizedBox(height: 6),
            const SuccessBurst(size: 116),
            const SizedBox(height: 16),
            Center(child: Text('EGP ${_amount.toStringAsFixed(2)}',
                style: T.display.copyWith(color: C.text, fontSize: 30))),
            Center(child: Text(App.t('Paid to ${m.name}', 'مدفوع إلى ${m.name}'),
                style: T.body.copyWith(color: C.sub))),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: D.card(),
              child: Column(children: [
                _row(App.t('Merchant', 'التاجر'), m.name),
                _div(),
                _row(App.t('Paid with', 'دُفع بواسطة'), App.t(_source!.labelEn, _source!.labelAr)),
                _div(),
                _row(App.t('Date', 'التاريخ'), _now()),
                _div(),
                _row(App.t('Reference', 'المرجع'), _ref ?? ''),
              ]),
            ),
            const SizedBox(height: 14),
            InfoNote(
              Icons.info_outline_rounded,
              'Simulated transaction — no real payment has been made.',
              'عملية محاكاة — لم يتم أي دفع حقيقي.',
              color: C.warning,
            ),
            const SizedBox(height: 16),
            PrimaryButton('Done', 'تم', onTap: () => Navigator.of(context).pop()),
            const SizedBox(height: 10),
            GhostButton(App.t('Share receipt', 'مشاركة الإيصال'), 'مشاركة الإيصال',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(App.t('Receipt shared (demo)', 'تمت مشاركة الإيصال (تجريبي)')),
                    behavior: SnackBarBehavior.floating))),
          ] else ...[
            /* merchant card */
            Container(
              padding: const EdgeInsets.all(16),
              decoration: D.card(),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: m.color, borderRadius: BorderRadius.circular(16)),
                  child: Center(
                      child: Text(m.name.substring(0, 1),
                          style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800))),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.name, style: T.h3.copyWith(color: C.text, fontSize: 16.5)),
                    const SizedBox(height: 3),
                    Text(m.handle, style: T.small.copyWith(color: C.muted)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: C.successSoft, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.verified_rounded, size: 13, color: C.success),
                    const SizedBox(width: 4),
                    Text(App.t('Verified', 'موثّق'), style: T.caption.copyWith(color: C.success, fontSize: 10)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Text(App.t('Amount', 'المبلغ'), style: T.h3.copyWith(color: C.text)),
            const SizedBox(height: 12),
            TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: TextEditingController(text: _amount.toStringAsFixed(2)),
              onChanged: (v) => _amount = double.tryParse(v) ?? 0,
              decoration: D.field(context, '0.00').copyWith(
                prefixText: 'EGP  ',
                prefixStyle: T.semi.copyWith(color: C.sub),
              ),
            ),
            const SizedBox(height: 16),
            Text(App.t('Pay with', 'الدفع بواسطة'), style: T.h3.copyWith(color: C.text)),
            const SizedBox(height: 12),
            SourcePicker(selected: _source, onSelect: (s) => setState(() => _source = s)),
            const SizedBox(height: 22),
            _step == _QrStep.paying
                ? const Center(child: CircularProgressIndicator(color: C.primary))
                : PrimaryButton('Pay EGP ${_amount.toStringAsFixed(2)}',
                    'دفع EGP ${_amount.toStringAsFixed(2)}',
                    onTap: _pay),
            const SizedBox(height: 14),
            InfoNote(
              Icons.info_outline_rounded,
              'Merchant networks are supported only where official Egyptian payment-network APIs are available.',
              'تُدعم شبكات التجّار فقط حيث تتوفر واجهات رسمية لشبكات الدفع المصرية.',
              color: C.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(flex: 2, child: Text(label, style: T.small.copyWith(color: C.muted))),
          Expanded(
              flex: 3,
              child: Text(value,
                  textAlign: App.dir == TextDirection.rtl ? TextAlign.left : TextAlign.right,
                  style: T.semi.copyWith(color: C.text, fontSize: 13))),
        ]),
      );

  Widget _div() => Divider(height: 1, color: C.line);

  String _now() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
