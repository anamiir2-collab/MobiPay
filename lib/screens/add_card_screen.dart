import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/payment_service.dart';
import '../widgets/bank_card.dart';
import '../widgets/fx.dart';
import '../widgets/ui.dart';

/// Add a bank card (spec §2 — the flagship flow).
///  Tab A — NFC READ: hold the physical card near the phone. Reads PAN/
///          expiry/name via reader mode; CVV must be typed manually (it is
///          NOT readable over NFC) and is only forwarded to the issuer.
///  Tab B — MANUAL ENTRY: typed details with live realistic card preview.
/// After verification only last4 + token are kept (PCI DSS).
class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});
  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

enum _Tab { nfc, manual }
enum _NfcState { idle, reading, read }

class _AddCardScreenState extends State<AddCardScreen> {
  _Tab _tab = _Tab.nfc;
  _NfcState _nfc = _NfcState.idle;
  NfcReadResult? _read;
  BankBrand _readBank = banks[0];
  final _cvvNfc = TextEditingController();

  // manual entry
  final _num = TextEditingController();
  final _holder = TextEditingController();
  final _exp = TextEditingController();
  final _cvv = TextEditingController();
  BankBrand _manualBank = banks[0];

  @override
  void dispose() {
    _cvvNfc.dispose();
    _num.dispose();
    _holder.dispose();
    _exp.dispose();
    _cvv.dispose();
    super.dispose();
  }

  BankCard get _readPreview => BankCard(
        id: 'tmp',
        bank: _readBank,
        brand: brandForPan(_read!.panBin + '0000' + _read!.last4),
        last4: _read!.last4,
        holder: _read!.holder,
        exp: _read!.exp,
        token: 'pending',
      );

  BankCard get _manualPreview {
    final digits = _num.text.replaceAll(' ', '');
    return BankCard(
      id: 'tmp',
      bank: _manualBank,
      brand: brandForPan(digits.isEmpty ? '4' : digits),
      last4: digits.length >= 4 ? digits.substring(digits.length - 4) : '0000',
      holder: _holder.text.isEmpty ? 'YOUR NAME' : _holder.text.toUpperCase(),
      exp: _exp.text.isEmpty ? 'MM/YY' : _exp.text,
      token: 'pending',
    );
  }

  void _guessBankFromPan(String digits) {
    if (digits.length >= 4) {
      final id = binTable[digits.substring(0, 4)];
      if (id != null) _manualBank = bankById(id);
    }
  }

  Future<void> _startRead() async {
    HapticFeedback.mediumImpact();
    setState(() => _nfc = _NfcState.reading);
    final r = await PaymentService.simulateCardRead();
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _read = r;
      _readBank = bankGuessForBin(r.panBin);
      _nfc = _NfcState.read;
    });
  }

  Future<void> _saveRead() async {
    if (_cvvNfc.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(App.t('Enter the CVV to verify with your bank', 'أدخل رمز CVV للتحقق من بنكك')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: C.error));
      return;
    }
    _showProcessing();
    final token = await PaymentService.tokenize(last4: _read!.last4);
    if (!mounted) return;
    Navigator.of(context).pop(); // processing
    userCards.add(BankCard(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      bank: _readBank,
      brand: _readPreview.brand,
      last4: _read!.last4,
      holder: _read!.holder,
      exp: _read!.exp,
      token: token,
      viaNfc: true,
    ));
    App.notifyChanged();
    _showAdded(token);
  }

  Future<void> _saveManual() async {
    final digits = _num.text.replaceAll(' ', '');
    if (digits.length < 16 || _holder.text.isEmpty || _exp.text.length < 5 || _cvv.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(App.t('Complete all card details', 'أكمل جميع بيانات البطاقة')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: C.error));
      return;
    }
    _showProcessing();
    final last4 = digits.substring(digits.length - 4);
    final token = await PaymentService.tokenize(last4: last4);
    if (!mounted) return;
    Navigator.of(context).pop();
    userCards.add(BankCard(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      bank: _manualBank,
      brand: brandForPan(digits),
      last4: last4,
      holder: _holder.text.toUpperCase(),
      exp: _exp.text,
      token: token,
    ));
    App.notifyChanged();
    _showAdded(token);
  }

  void _showProcessing() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: C.primary),
            const SizedBox(height: 16),
            Text(App.t('Verifying with issuer…', 'جارٍ التحقق مع البنك…'), style: T.semi.copyWith(color: C.text)),
            const SizedBox(height: 6),
            Text(App.t('Tokenizing card (PCI DSS)', 'ترميز البطاقة (PCI DSS)'), style: T.small.copyWith(color: C.muted)),
          ]),
        ),
      ),
    );
  }

  void _showAdded(String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => Dialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SuccessBurst(size: 96),
            const SizedBox(height: 14),
            Text(App.t('Card added securely', 'تمت إضافة البطاقة بأمان'), style: T.h3.copyWith(color: C.text)),
            const SizedBox(height: 6),
            Text(
              App.t('Token $token — the full number is never stored.', 'الرمز $token — لن يُخزَّن رقم البطاقة الكامل أبدًا.'),
              textAlign: TextAlign.center,
              style: T.small.copyWith(color: C.muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            PrimaryButton('Done', 'تم', onTap: () {
              Navigator.of(dctx).pop();
              Navigator.of(context).pop();
            }),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickBank({required bool forRead}) async {
    await showSheet(
      context,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(App.t('Choose the card design', 'اختر تصميم البطاقة'), style: T.h3.copyWith(color: C.text)),
        ),
        ...banks.map((b) => InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  if (forRead) {
                    _readBank = b;
                  } else {
                    _manualBank = b;
                  }
                });
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [b.c1, b.c2]),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(child: Text(b.short, style: TextStyle(color: b.accent, fontWeight: FontWeight.w800, fontSize: 9))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(App.t(b.displayEn, b.displayAr), style: T.semi.copyWith(color: C.text, fontSize: 14))),
                  if ((forRead ? _readBank : _manualBank) == b)
                    const Icon(Icons.check_circle_rounded, color: C.primary, size: 20),
                ]),
              ),
            )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      titleEn: 'Add card',
      titleAr: 'إضافة بطاقة',
      body: Column(children: [
        /* segmented control */
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: C.alt, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              _seg(_Tab.nfc, Icons.nfc_rounded, App.t('NFC read', 'قراءة NFC')),
              _seg(_Tab.manual, Icons.edit_rounded, App.t('Manual entry', 'إدخال يدوي')),
            ]),
          ),
        ),
        Expanded(
          child: _tab == _Tab.nfc ? _nfcBody() : _manualBody(),
        ),
      ]),
    );
  }

  Widget _seg(_Tab t, IconData icon, String label) {
    final sel = _tab == t;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _tab = t);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          decoration: BoxDecoration(
            color: sel ? C.card : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: sel ? C.shadowSm : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 17, color: sel ? C.primary : C.muted),
            const SizedBox(width: 7),
            Text(label, style: T.semi.copyWith(color: sel ? C.text : C.muted, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  /* ─────────────── NFC tab ─────────────── */

  Widget _nfcBody() {
    if (_nfc == _NfcState.read) return _readForm();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 14),
        Center(child: NfcPulse(size: 160, animate: _nfc == _NfcState.reading)),
        const SizedBox(height: 26),
        Center(
          child: Text(
            _nfc == _NfcState.idle
                ? App.t('Hold your card near the top of the phone', 'قرّب البطاقة من أعلى الهاتف')
                : App.t('Reading card…', 'جارٍ قراءة البطاقة…'),
            textAlign: TextAlign.center,
            style: T.h3.copyWith(color: C.text, fontSize: 17),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            App.t('ISO 14443 / EMV — reads number, name and expiry only',
                'ISO 14443 / EMV — يقرأ الرقم والاسم وتاريخ الانتهاء فقط'),
            textAlign: TextAlign.center,
            style: T.small.copyWith(color: C.muted),
          ),
        ),
        const SizedBox(height: 22),
        if (_nfc == _NfcState.reading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(minHeight: 5, color: C.primary, backgroundColor: C.line),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: PrimaryButton('Start reading', 'ابدأ القراءة', onTap: _startRead),
          ),
        const SizedBox(height: 24),
        InfoNote(
          Icons.shield_rounded,
          'CVV cannot be read over NFC. You will type it once for issuer verification — it is never stored.',
          'لا يمكن قراءة CVV عبر NFC. ستدخله مرة واحدة للتحقق من البنك — ولا يتم تخزينه أبدًا.',
          color: C.warning,
        ),
      ],
    );
  }

  Widget _readForm() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        BankCardWidget(_readPreview),
        const SizedBox(height: 16),
        Text(App.t('Card read — verify & save', 'تمت قراءة البطاقة — تحقق واحفظ'),
            style: T.h3.copyWith(color: C.text)),
        const SizedBox(height: 14),
        _row(App.t('Card number', 'رقم البطاقة'), '•••• •••• •••• ${_read!.last4}  (read via NFC)'),
        _row(App.t('Cardholder', 'حامل البطاقة'), _read!.holder),
        _row(App.t('Expiry', 'تاريخ الانتهاء'), _read!.exp),
        const SizedBox(height: 12),
        TextField(
          controller: _cvvNfc,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: D.field(context, App.t('CVV (type manually)', 'CVV (أدخله يدويًا)')),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickBank(forRead: true),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.input, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.line)),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [_readBank.c1, _readBank.c2]), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(_readBank.short, style: TextStyle(color: _readBank.accent, fontSize: 9, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(App.t(_readBank.displayEn, _readBank.displayAr), style: T.semi.copyWith(color: C.text, fontSize: 13))),
              Text(App.t('Change design', 'تغيير التصميم'), style: T.small.copyWith(color: C.primary)),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton('Save card', 'حفظ البطاقة', onTap: _saveRead),
        const SizedBox(height: 12),
        InfoNote(
          Icons.token_rounded,
          'Only the last 4 digits and a payment token are stored. The full PAN is discarded after verification.',
          'يتم تخزين آخر 4 أرقام ورمز الدفع فقط. يتم تجاهل الرقم الكامل بعد التحقق.',
        ),
      ],
    );
  }

  /* ─────────────── Manual tab ─────────────── */

  Widget _manualBody() {
    final digits = _num.text.replaceAll(' ', '');
    final ready = digits.length >= 12;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (ready) ...[
          BankCardWidget(_manualPreview),
          const SizedBox(height: 14),
        ],
        TextField(
          controller: _num,
          keyboardType: TextInputType.number,
          maxLength: 19,
          onChanged: (v) {
            _guessBankFromPan(v.replaceAll(' ', ''));
            setState(() {});
          },
          decoration: D.field(context, App.t('Card number', 'رقم البطاقة')).copyWith(counterText: ''),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _holder,
          onChanged: (_) => setState(() {}),
          decoration: D.field(context, App.t('Cardholder name', 'اسم حامل البطاقة')),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _exp,
              keyboardType: TextInputType.datetime,
              maxLength: 5,
              decoration: D.field(context, 'MM/YY').copyWith(counterText: ''),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _cvv,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: D.field(context, 'CVV').copyWith(counterText: ''),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _pickBank(forRead: false),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.input, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.line)),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [_manualBank.c1, _manualBank.c2]), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(_manualBank.short, style: TextStyle(color: _manualBank.accent, fontSize: 9, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(App.t(_manualBank.displayEn, _manualBank.displayAr), style: T.semi.copyWith(color: C.text, fontSize: 13))),
              Text(App.t('Change design', 'تغيير التصميم'), style: T.small.copyWith(color: C.primary)),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton('Save card', 'حفظ البطاقة', onTap: _saveManual),
        const SizedBox(height: 12),
        InfoNote(
          Icons.lock_rounded,
          'Card data goes directly to the PCI DSS-compliant provider. MobiPay only receives a token.',
          'تُرسل بيانات البطاقة مباشرة إلى مزود متوافق مع PCI DSS. لا يتلقى MobiPay سوى رمز الدفع.',
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(children: [
        SizedBox(width: 110, child: Text(label, style: T.small.copyWith(color: C.muted))),
        Expanded(child: Text(value, style: T.semi.copyWith(color: C.text, fontSize: 13))),
      ]),
    );
  }
}
