import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/payment_service.dart';
import '../widgets/fx.dart';
import '../widgets/ui.dart';

/// Mobile balance recharge (spec §7) — the ONLY retained bill service.
/// Scratch cards, bundles, internet packages and utility bills were
/// REMOVED in v2 per product decision.
class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});
  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

enum _RStep { form, paying, success }

class _RechargeScreenState extends State<RechargeScreen> {
  _RStep _step = _RStep.form;
  Operator? _op;
  double? _amount;
  final _amountCtrl = TextEditingController();
  final _phone = TextEditingController();
  PaySource? _source;
  String? _ref;

  @override
  void initState() {
    super.initState();
    _source = PaySource.card(userCards.first);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _phone.dispose();
    super.dispose();
  }

  Operator get _detected {
    if (_op != null) return _op!;
    if (_phone.text.replaceAll(' ', '').length >= 3) return operatorForPhone(_phone.text);
    return operators.first;
  }

  bool get _ready =>
      _phone.text.replaceAll(' ', '').length == 11 && (_amount ?? 0) > 0 && _source != null;

  Future<void> _confirm() async {
    setState(() => _step = _RStep.paying);
    final ref = await PaymentService.simulateRecharge();
    if (!mounted) return;
    setState(() {
      _ref = ref;
      _step = _RStep.success;
    });
    txns.insert(
      0,
      Txn(
        id: 't_${DateTime.now().millisecondsSinceEpoch}',
        type: TxType.recharge,
        title: App.t('${_detected.nameEn} top-up — ${_phone.text}', 'شحن ${_detected.nameAr} — ${_phone.text}'),
        method: _source!.labelEn,
        category: App.t('Mobile', 'موبايل'),
        ref: ref,
        amount: -_amount!,
        date: DateTime.now(),
        status: TxStatus.success,
      ),
    );
    App.notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      titleEn: 'Mobile recharge',
      titleAr: 'شحن رصيد الموبايل',
      actions: const [Padding(padding: EdgeInsetsDirectional.only(end: 12), child: DemoBadge())],
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_step == _RStep.success) ..._success()
          else ...[
            /* 1 · operator */
            _stepTitle('1', App.t('Select operator', 'اختر المشغّل')),
            Row(children: [
              ...operators.map((o) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _op = o),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        margin: const EdgeInsetsDirectional.only(end: 9),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _detected == o ? o.color.withOpacity(0.1) : C.card,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _detected == o ? o.color : C.line, width: _detected == o ? 1.7 : 1),
                        ),
                        child: Column(children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(color: o.color, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                o.id == 'et' ? 'e&' : o.nameEn.substring(0, 1),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(App.t(o.nameEn, o.nameAr),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: T.caption.copyWith(color: C.text, fontSize: 10)),
                        ]),
                      ),
                    ),
                  )),
            ]),
            const SizedBox(height: 16),

            /* 2 · phone */
            _stepTitle('2', App.t('Phone number', 'رقم الموبايل')),
            TextField(
              keyboardType: TextInputType.phone,
              maxLength: 11,
              controller: _phone,
              onChanged: (_) => setState(() {}),
              decoration: D.field(context, '01x xxx xxxx').copyWith(counterText: ''),
            ),
            const SizedBox(height: 14),

            /* 3 · amount */
            _stepTitle('3', App.t('Recharge amount', 'قيمة الشحن')),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                ...rechargeAmounts.map((a) => _amountChip(a.toDouble())),
                SizedBox(
                  width: 96,
                  height: 40,
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => _amount = double.tryParse(v)),
                    textAlign: TextAlign.center,
                    style: T.semi.copyWith(fontSize: 13, color: C.text),
                    decoration: InputDecoration(
                      hintText: App.t('Custom', 'مبلغ آخر'),
                      filled: true,
                      fillColor: (_amount != null && !rechargeAmounts.contains(_amount)) ? C.primarySoft : C.card,
                      hintStyle: T.small.copyWith(color: C.muted, fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: C.line)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.primary)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /* 4 · payment method */
            _stepTitle('4', App.t('Payment method', 'طريقة الدفع')),
            const SizedBox(height: 10),
            SourcePicker(selected: _source, onSelect: (s) => setState(() => _source = s)),
            const SizedBox(height: 20),

            /* summary */
            Container(
              padding: const EdgeInsets.all(15),
              decoration: D.card(),
              child: Column(children: [
                _row(App.t('Operator', 'المشغّل'), App.t(_detected.nameEn, _detected.nameAr)),
                _div(),
                _row(App.t('Number', 'الرقم'), _phone.text.isEmpty ? '—' : _phone.text),
                _div(),
                _row(App.t('Amount', 'المبلغ'), _amount == null ? '—' : 'EGP ${_amount!.toStringAsFixed(2)}'),
                _div(),
                _row(App.t('Fees', 'الرسوم'), App.t('EGP 0.00', 'EGP 0.00')),
                _div(),
                Row(children: [
                  Expanded(child: Text(App.t('Total', 'الإجمالي'), style: T.semi.copyWith(color: C.text))),
                  Text(_amount == null ? '—' : 'EGP ${_amount!.toStringAsFixed(2)}',
                      style: T.h3.copyWith(color: C.primary, fontSize: 15)),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            _step == _RStep.paying
                ? const Center(child: CircularProgressIndicator(color: C.primary))
                : PrimaryButton('Recharge EGP ${(_amount ?? 0).toStringAsFixed(0)}',
                    'شحن EGP ${(_amount ?? 0).toStringAsFixed(0)}',
                    enabled: _ready, onTap: _confirm),
            const SizedBox(height: 14),
            InfoNote(
              Icons.api_rounded,
              'Recharges require official operator API integration (Vodafone, Orange, e&, WE). Bundles and scratch cards are not part of MobiPay.',
              'الشحن يتطلب تكامل واجهات المشغّلين الرسمية (فودافون، أورنج، اتصالات، WE). الباقات وكروت الشحن ليست جزءًا من MobiPay.',
              color: C.warning,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _success() => [
        const SizedBox(height: 8),
        const SuccessBurst(size: 116),
        const SizedBox(height: 16),
        Center(child: Text('EGP ${_amount!.toStringAsFixed(2)}',
            style: T.display.copyWith(color: C.text, fontSize: 30))),
        Center(
          child: Text(
            App.t('Balance recharged to ${_phone.text}', 'تم شحن الرصيد إلى ${_phone.text}'),
            style: T.body.copyWith(color: C.sub),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: D.card(),
          child: Column(children: [
            _row(App.t('Operator', 'المشغّل'), App.t(_detected.nameEn, _detected.nameAr)),
            _div(),
            _row(App.t('Paid with', 'دُفع بواسطة'), App.t(_source!.labelEn, _source!.labelAr)),
            _div(),
            _row(App.t('Reference', 'المرجع'), _ref ?? ''),
          ]),
        ),
        const SizedBox(height: 14),
        InfoNote(
          Icons.info_outline_rounded,
          'Simulated recharge — no real balance has been added.',
          'شحن تجريبي — لم يُضف رصيد حقيقي.',
          color: C.warning,
        ),
        const SizedBox(height: 16),
        PrimaryButton('Done', 'تم', onTap: () => Navigator.of(context).pop()),
      ];

  Widget _stepTitle(String n, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(gradient: C.gradPrimary, shape: BoxShape.circle),
            child: Center(child: Text(n, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 9),
          Text(label, style: T.h3.copyWith(color: C.text, fontSize: 15.5)),
        ]),
      );

  Widget _amountChip(double v) {
    final sel = _amount == v;
    return GestureDetector(
      onTap: () {
        _amountCtrl.clear();
        setState(() => _amount = v);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? C.primary : C.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: sel ? C.primary : C.line),
        ),
        child: Text('EGP $v', style: T.semi.copyWith(color: sel ? Colors.white : C.text, fontSize: 13)),
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
}
