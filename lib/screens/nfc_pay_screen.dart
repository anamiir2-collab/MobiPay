import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/payment_service.dart';
import '../widgets/fx.dart';
import '../widgets/ui.dart';

/// NFC tap-to-pay (spec §4).
/// ⚠️ SIMULATED: real tap-to-pay requires Android HCE + issuer tokenization
/// (Visa VTS / Mastercard MDES) + network certification. See README §NFC.
class NfcPayScreen extends StatefulWidget {
  const NfcPayScreen({super.key});
  @override
  State<NfcPayScreen> createState() => _NfcPayScreenState();
}

enum _Step { source, ready, success, declined }

class _NfcPayScreenState extends State<NfcPayScreen> {
  _Step _step = _Step.source;
  PaySource? _source;
  bool _nfcOk = true;
  bool _busy = false;
  late double _amount = demoTerminal['amount'] as double;

  @override
  void initState() {
    super.initState();
    PaymentService.nfcAvailable().then((v) {
      if (mounted) setState(() => _nfcOk = v);
    });
  }

  Future<void> _tap() async {
    setState(() => _busy = true);
    HapticFeedback.heavyImpact();
    final ok = await PaymentService.simulateTerminalTap();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = ok ? _Step.success : _Step.declined;
    });
  }

  void _finish(double amount, String ref) {
    txns.insert(
      0,
      Txn(
        id: 't_${DateTime.now().millisecondsSinceEpoch}',
        type: TxType.nfc,
        title: demoTerminal['merchant'] as String,
        method: 'NFC — ${_source!.labelEn}',
        category: App.t('Contactless payment', 'دفع بالتقريب'),
        ref: ref,
        amount: -amount,
        date: DateTime.now(),
        status: TxStatus.success,
      ),
    );
    App.notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      titleEn: 'Pay with NFC',
      titleAr: 'ادفع باللمس',
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!_nfcOk)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InfoNote(
                    Icons.nfc_rounded,
                    'NFC is not available on this device.',
                    'NFC غير متوفر على هذا الجهاز.',
                    color: C.error,
                  ),
                ),
              if (_step == _Step.source) _sourceStep(),
              if (_step == _Step.ready) _readyStep(),
              if (_step == _Step.success) _successStep(),
              if (_step == _Step.declined) _declinedStep(),
            ],
          ),
          const PositionedDirectional(top: 0, end: 20, child: DemoBadge()),
        ],
      ),
    );
  }

  /* ── step 1: choose source & amount ── */

  Widget _sourceStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(App.t('1 · Choose payment source', '١ · اختر طريقة الدفع'), style: T.h3.copyWith(color: C.text)),
      const SizedBox(height: 12),
      SourcePicker(
        selected: _source,
        onSelect: (s) => setState(() => _source = s),
      ),
      const SizedBox(height: 20),
      Text(App.t('2 · Amount (usually set by the terminal)', '٢ · المبلغ (يحدده الطرفية عادةً)'),
          style: T.h3.copyWith(color: C.text)),
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
      const SizedBox(height: 22),
      PrimaryButton('Confirm & continue', 'تأكيد والمتابعة',
          enabled: _source != null,
          onTap: () => setState(() => _step = _Step.ready)),
      const SizedBox(height: 14),
      InfoNote(
        Icons.nfc_rounded,
        'Real tap-to-pay needs Android HCE with bank-issued payment tokens (VTS/MDES) and network certification. This demo simulates the terminal side.',
        'الدفع الحقيقي باللمس يحتاج HCE على أندرويد مع رموز دفع صادرة من البنك (VTS/MDES) واعتماد من الشبكات. هذا العرض يحاكي الطرفية.',
        color: C.warning,
      ),
    ]);
  }

  /* ── step 2: hold near terminal ── */

  Widget _readyStep() {
    return Column(children: [
      const SizedBox(height: 8),
      NfcPulse(size: 170, animate: !_busy),
      const SizedBox(height: 26),
      Text(
        _busy ? App.t('Processing…', 'جارٍ المعالجة…') : App.t('Hold your phone near the terminal', 'قرّب هاتفك من الطرفية'),
        style: T.h2.copyWith(color: C.text, fontSize: 19),
      ),
      const SizedBox(height: 8),
      Text(
        '${demoTerminal['merchant']} · ${demoTerminal['terminal']}',
        style: T.small.copyWith(color: C.muted),
      ),
      const SizedBox(height: 20),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: D.card(),
        child: Row(children: [
          _SourceAvatar(s: _source!),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(App.t(_source!.labelEn, _source!.labelAr),
                  style: T.semi.copyWith(color: C.text, fontSize: 13.5)),
              Text(App.t('Selected payment method', 'طريقة الدفع المحددة'),
                  style: T.small.copyWith(color: C.muted, fontSize: 11)),
            ]),
          ),
          Text('EGP ${_amount.toStringAsFixed(2)}',
              style: T.h3.copyWith(color: C.primary, fontSize: 16)),
        ]),
      ),
      const SizedBox(height: 24),
      _busy
          ? const Center(child: CircularProgressIndicator(color: C.primary))
          : PrimaryButton('Simulate terminal tap', 'محاكاة اللمس على الطرفية', onTap: _tap),
      const SizedBox(height: 10),
      GhostButton('Back', 'رجوع', onTap: () => setState(() => _step = _Step.source)),
    ]);
  }

  /* ── step 3: success ── */

  Widget _successStep() {
    final ref = 'MP-2026-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    _finish(_amount, ref);
    return Column(children: [
      const SizedBox(height: 10),
      const SuccessBurst(size: 120),
      const SizedBox(height: 18),
      Text('EGP ${_amount.toStringAsFixed(2)}', style: T.display.copyWith(color: C.text, fontSize: 30)),
      const SizedBox(height: 4),
      Text(App.t('Paid with contactless', 'تم الدفع بالتقريب'), style: T.body.copyWith(color: C.sub)),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: D.card(),
        child: Column(children: [
          _row(App.t('Merchant', 'التاجر'), demoTerminal['merchant'] as String),
          _divider(),
          _row(App.t('Paid with', 'دُفع بواسطة'), App.t(_source!.labelEn, _source!.labelAr)),
          _divider(),
          _row(App.t('Date', 'التاريخ'), _fullDate(DateTime.now())),
          _divider(),
          _row(App.t('Reference', 'المرجع'), ref),
        ]),
      ),
      const SizedBox(height: 14),
      InfoNote(
        Icons.info_outline_rounded,
        'Simulated transaction — no real payment has been made or confirmed by any provider.',
        'عملية محاكاة — لم يتم أي دفع حقيقي ولا تأكيد من أي مزوّد.',
        color: C.warning,
      ),
      const SizedBox(height: 14),
      PrimaryButton('Done', 'تم', onTap: () => Navigator.of(context).pop()),
    ]);
  }

  /* ── declined ── */

  Widget _declinedStep() {
    return Column(children: [
      const SizedBox(height: 18),
      Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(color: C.errorSoft, shape: BoxShape.circle),
        child: Icon(Icons.close_rounded, color: C.error, size: 44),
      ),
      const SizedBox(height: 18),
      Text(App.t('Transaction declined', 'تم رفض العملية'), style: T.h2.copyWith(color: C.text)),
      const SizedBox(height: 8),
      Text(App.t('The terminal could not authorize this card. Try another payment source.',
          'لم تتمكن الطرفية من اعتماد البطاقة. جرّب طريقة دفع أخرى.'),
          textAlign: TextAlign.center,
          style: T.body.copyWith(color: C.sub, height: 1.5)),
      const SizedBox(height: 24),
      PrimaryButton('Retry', 'إعادة المحاولة', onTap: () => setState(() => _step = _Step.ready)),
      const SizedBox(height: 10),
      GhostButton('Change payment source', 'تغيير طريقة الدفع',
          onTap: () => setState(() => _step = _Step.source)),
    ]);
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

  Widget _divider() => Divider(height: 1, color: C.line);

  String _fullDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _SourceAvatar extends StatelessWidget {
  final PaySource s;
  const _SourceAvatar({required this.s});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [s.color, s.color.withOpacity(0.72)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(s.short, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
    );
  }
}
