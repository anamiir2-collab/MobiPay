import 'package:flutter/material.dart';

import '../core/app.dart';
import '../core/style.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../widgets/bank_card.dart';
import '../widgets/ui.dart';

class CardDetailScreen extends StatefulWidget {
  final BankCard card;
  const CardDetailScreen({super.key, required this.card});
  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Screen(
      titleEn: 'Card details',
      titleAr: 'تفاصيل البطاقة',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          BankCardWidget(card),
          const SizedBox(height: 14),
          Row(children: [
            if (card.isDefault)
              _chip(App.t('Default payment method', 'طريقة الدفع الافتراضية'), C.primary, Icons.star_rounded),
            if (card.frozen) ...[
              if (card.isDefault) const SizedBox(width: 8),
              _chip(App.t('Frozen', 'مجمّدة'), C.secondary, Icons.ac_unit_rounded),
            ],
            const Spacer(),
            Text(App.t(card.viaNfc ? 'Added via NFC read' : 'Added manually', card.viaNfc ? 'أُضيفت بقراءة NFC' : 'أُضيفت يدويًا'),
                style: T.small.copyWith(color: C.muted, fontSize: 11)),
          ]),

          /* details */
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: D.card(),
            child: Column(children: [
              _row(App.t('Bank', 'البنك'), App.t(card.bank.displayEn, card.bank.displayAr)),
              _divider(),
              _row(App.t('Card number', 'رقم البطاقة'), '•••• •••• •••• ${card.last4}'),
              _divider(),
              _row(App.t('Network', 'الشبكة'), card.brand == PayBrand.visa ? 'Visa' : 'Mastercard'),
              _divider(),
              _row(App.t('Cardholder', 'حامل البطاقة'), card.holder),
              _divider(),
              _row(App.t('Expiry', 'تاريخ الانتهاء'), card.exp),
              _divider(),
              _row(App.t('Status', 'الحالة'), card.frozen ? App.t('Frozen', 'مجمّدة') : App.t('Active', 'نشطة')),
              _divider(),
              _row(App.t('Payment token', 'رمز الدفع'), '${card.token.substring(0, 9)}…${card.token.substring(card.token.length - 4)}'),
            ]),
          ),

          /* actions */
          const SizedBox(height: 18),
          if (!card.isDefault)
            PrimaryButton('Set as default', 'تعيين كافتراضية', onTap: () {
              setState(() {
                for (final c in userCards) {
                  c.isDefault = c == card;
                }
              });
              App.notifyChanged();
            }),
          if (!card.isDefault) const SizedBox(height: 10),
          GhostButton(
            card.frozen ? App.t('Unfreeze card', 'إلغاء التجميد') : App.t('Freeze card', 'تجميد البطاقة'),
            card.frozen ? 'إلغاء التجميد' : 'تجميد البطاقة',
            color: card.frozen ? C.success : C.warning,
            onTap: () => setState(() => card.frozen = !card.frozen),
          ),
          const SizedBox(height: 10),
          GhostButton(App.t('Remove card', 'إزالة البطاقة'), 'إزالة البطاقة',
              color: C.error, onTap: _confirmRemove),

          /* security */
          const SizedBox(height: 16),
          InfoNote(
            Icons.verified_user_rounded,
            'Only the last 4 digits are stored and shown. The full card number is never displayed again, and CVV/PIN are never saved.',
            'يتم تخزين وعرض آخر 4 أرقام فقط. لا يُعرض رقم البطاقة الكامل مرة أخرى، ولا يتم حفظ CVV أو الرقم السري أبدًا.',
            color: C.success,
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label, style: T.caption.copyWith(color: color, fontSize: 10.5)),
      ]),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Expanded(flex: 2, child: Text(label, style: T.small.copyWith(color: C.muted))),
        Expanded(
            flex: 3,
            child: Text(value,
                textAlign: App.dir == TextDirection.rtl ? TextAlign.left : TextAlign.right,
                style: T.semi.copyWith(color: C.text, fontSize: 13.5))),
      ]),
    );
  }

  Widget _divider() => Divider(height: 1, color: C.line);

  void _confirmRemove() {
    showDialog(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(App.t('Remove card?', 'إزالة البطاقة؟'), style: T.h3.copyWith(color: C.text)),
        content: Text(
          App.t('The payment token will be revoked. You can add the card again anytime.',
              'سيتم إلغاء رمز الدفع. يمكنك إضافة البطاقة مرة أخرى في أي وقت.'),
          style: T.body.copyWith(color: C.sub, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: Text(App.t('Cancel', 'إلغاء'))),
          TextButton(
            onPressed: () {
              userCards.remove(widget.card);
              App.notifyChanged();
              Navigator.pop(dctx);
              Navigator.pop(context);
            },
            child: Text(App.t('Remove', 'إزالة'), style: const TextStyle(color: C.error)),
          ),
        ],
      ),
    );
  }
}
