import 'package:flutter/material.dart';

import '../models/models.dart';

/* ------------------------------------------------------------------ */
/* ALL DATA BELOW IS MOCK DATA FOR THE PROTOTYPE ONLY.                 */
/* Banks, wallet providers and operators are real Egyptian brands used */
/* for realism. Every amount/transaction is illustrative — nothing     */
/* here is a real payment (spec: never claim simulated txns are real). */
/* ------------------------------------------------------------------ */

const demoUser = {
  'name': 'Omar Khaled',
  'nameAr': 'عمر خالد',
  'phone': '0100 234 5678',
  'handle': '@omarkhaled',
};

/// Egyptian banks (spec §2) with approximated card-visual identities.
const banks = <BankBrand>[
  BankBrand('bm',   'Banque Misr',                       'بنك مصر',                    'BM',
      Color(0xFF00563F), Color(0xFF077A50), Color(0xFFE0BE6E)),
  BankBrand('nbe',  'National Bank of Egypt',            'البنك الأهلي المصري',        'NBE',
      Color(0xFF12233F), Color(0xFF27476E), Color(0xFFD9B45B)),
  BankBrand('cib',  'CIB',                               'البنك التجاري الدولي',       'CIB',
      Color(0xFF0A1F3C), Color(0xFF15507E), Color(0xFFE3B04B)),
  BankBrand('qnb',  'QNB Alahli',                        'QNB الأهلي',                 'QNB',
      Color(0xFF5E1330), Color(0xFF8C2150), Color(0xFFE3B25F)),
  BankBrand('bdc',  'Banque du Caire',                   'بنك القاهرة',                'BDC',
      Color(0xFF0A3D91), Color(0xFF1668C4), Color(0xFFF0C36A)),
  BankBrand('alex', 'AlexBank',                          'بنك الإسكندرية',             'AB',
      Color(0xFF0E4C6E), Color(0xFF17698F), Color(0xFF9FCFE8)),
  BankBrand('aaib', 'AAIB',                              'بنك العرب الأفريقي الدولي',  'AAIB',
      Color(0xFF0F1B3D), Color(0xFF20355F), Color(0xFFF2994A)),
  BankBrand('hdb',  'Housing & Development Bank',        'بنك التنمية الإسكانية',      'HDB',
      Color(0xFF0C4E86), Color(0xFF1173B4), Color(0xFFF2A54A)),
  BankBrand('fib',  'Faisal Islamic Bank',               'بنك فيصل الإسلامي',          'FIB',
      Color(0xFF05543A), Color(0xFF0B7A52), Color(0xFFD9C08A)),
  BankBrand('adib', 'ADIB Egypt',                        'بنك أبوظبي الإسلامي',        'ADIB',
      Color(0xFF0B4038), Color(0xFF116553), Color(0xFFD9B45B)),
];

BankBrand bankById(String id) => banks.firstWhere((b) => b.id == id,
    orElse: () => banks.first);

/// BIN → bank routing for the demo (production: PSP BIN table).
BankBrand bankGuessForBin(String pan) {
  if (pan.startsWith('4539')) return bankById('cib');
  if (pan.startsWith('5412')) return bankById('nbe');
  if (pan.startsWith('4659')) return bankById('bm');
  return bankById('bm');
}

PayBrand brandForPan(String pan) => pan.startsWith('5') ? PayBrand.mastercard : PayBrand.visa;

/// Demo BIN table so the manual-entry preview picks the right design.
const binTable = <String, String>{
  '4659': 'bm', '4539': 'cib', '5412': 'nbe', '5288': 'qnb',
  '4587': 'bdc', '4522': 'alex', '4812': 'aaib', '4462': 'hdb',
  '5210': 'fib', '5981': 'adib',
};

final List<BankCard> userCards = [
  BankCard(
    id: 'card_bm_visa',
    bank: bankById('bm'),
    brand: PayBrand.visa,
    last4: '4582', // matches the spec example: Banque Misr Visa •••• 4582
    holder: 'OMAR KHALED',
    exp: '09/27',
    token: 'tok_bm_9f3e21c7',
    isDefault: true,
  ),
  BankCard(
    id: 'card_cib_mc',
    bank: bankById('cib'),
    brand: PayBrand.mastercard,
    last4: '7316',
    holder: 'OMAR KHALED',
    exp: '07/28',
    token: 'tok_cib_41b8ae02',
    viaNfc: true,
  ),
  BankCard(
    id: 'card_nbe_visa',
    bank: bankById('nbe'),
    brand: PayBrand.visa,
    last4: '2314',
    holder: 'OMAR KHALED',
    exp: '04/26',
    token: 'tok_nbe_5d90cf18',
  ),
];

const walletProviders = <WalletProvider>[
  WalletProvider('vf', 'Vodafone Cash', 'فودافون كاش', Color(0xFFE60000), Color(0xFF9E0000)),
  WalletProvider('og', 'Orange Cash', 'أورنج كاش', Color(0xFFFF7900), Color(0xFFD95F00)),
  WalletProvider('et', 'e& cash', 'اتصالات كاش', Color(0xFF7CB92C), Color(0xFF5C8F1D)),
  WalletProvider('we', 'WE Pay', 'WE باي', Color(0xFFEC008C), Color(0xFF9A1877)),
];

WalletProvider providerById(String id) => walletProviders.firstWhere((p) => p.id == id);

final List<EWallet> userWallets = [
  EWallet(id: 'w_vf', provider: providerById('vf'), masked: '0100 •• 845', isDefault: true),
  EWallet(id: 'w_og', provider: providerById('og'), masked: '0122 •• 690'),
  EWallet(id: 'w_et', provider: providerById('et'), masked: '0111 •• 273'),
  EWallet(id: 'w_we', provider: providerById('we'), masked: '0151 •• 118'),
];

const operators = <Operator>[
  Operator('vf', 'Vodafone', 'فودافون', '010', Color(0xFFE60000)),
  Operator('og', 'Orange', 'أورنج', '012', Color(0xFFFF7900)),
  Operator('et', 'e& Egypt', 'اتصالات', '011', Color(0xFF7CB92C)),
  Operator('we', 'WE', 'مصر للاتصالات', '015', Color(0xFFEC008C)),
];

Operator operatorForPhone(String phone) {
  final p = phone.replaceAll(' ', '');
  return operators.firstWhere(
      (o) => p.startsWith(o.prefix),
      orElse: () => operators.first);
}

const rechargeAmounts = [10, 20, 50, 100, 200];

const qrMerchants = <Merchant>[
  Merchant('Metro Market', '@metromarket', 'Groceries', 'بقالة', Color(0xFF27AE60)),
  Merchant('Coffee Corner', '@coffeecorner.eg', 'Food & Drink', 'مقاهي', Color(0xFF8B5A2B)),
  Merchant('Cilantro', '@cilantro.eg', 'Food & Drink', 'مقاهي', Color(0xFF6C3CE0)),
  Merchant('El Abd Patisserie', '@elabd', 'Bakery', 'مخبوزات', Color(0xFFF2994A)),
  Merchant('Carrefour Egypt', '@carrefour.eg', 'Groceries', 'بقالة', Color(0xFF2D9CDB)),
  Merchant('Breadfast', '@breadfast', 'Groceries', 'بقالة', Color(0xFFEB5757)),
];

DateTime _d(int daysAgo, int h, int m) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - daysAgo, h, m);
}

final List<Txn> txns = [
  Txn(id: 't1', type: TxType.nfc, title: 'Coffee Corner', method: 'NFC — Banque Misr Visa ••4582', category: 'Food & Drink', ref: 'MP-2026-381902', amount: -85.00, date: _d(0, 9, 24), status: TxStatus.success),
  Txn(id: 't2', type: TxType.qr, title: 'Metro Market', method: 'QR — Vodafone Cash 0100 •• 845', category: 'Groceries', ref: 'MP-2026-381774', amount: -312.40, date: _d(0, 8, 2), status: TxStatus.success),
  Txn(id: 't3', type: TxType.recharge, title: 'Vodafone top-up — 0100 234 5678', method: 'Orange Cash 0122 •• 690', category: 'Mobile', ref: 'MP-2026-380650', amount: -100.00, date: _d(1, 19, 40), status: TxStatus.success),
  Txn(id: 't4', type: TxType.card, title: 'Carrefour Egypt', method: 'Card — CIB Mastercard ••7316', category: 'Groceries', ref: 'MP-2026-380211', amount: -1249.00, date: _d(1, 14, 12), status: TxStatus.success),
  Txn(id: 't5', type: TxType.wallet, title: 'Airtime — e& cash', method: 'e& cash 0111 •• 273', category: 'Mobile', ref: 'MP-2026-379511', amount: -60.00, date: _d(2, 20, 10), status: TxStatus.success),
  Txn(id: 't6', type: TxType.nfc, title: 'El Abd Patisserie', method: 'NFC — CIB Mastercard ••7316', category: 'Food & Drink', ref: 'MP-2026-377902', amount: -146.75, date: _d(3, 17, 55), status: TxStatus.pending),
  Txn(id: 't7', type: TxType.qr, title: 'Cilantro', method: 'QR — Banque Misr Visa ••4582', category: 'Food & Drink', ref: 'MP-2026-376221', amount: -178.50, date: _d(4, 15, 20), status: TxStatus.failed),
  Txn(id: 't8', type: TxType.card, title: 'Breadfast', method: 'Card — NBE Visa ••2314', category: 'Groceries', ref: 'MP-2026-375114', amount: -250.00, date: _d(5, 11, 5), status: TxStatus.success),
  Txn(id: 't9', type: TxType.wallet, title: 'Top-up — WE Pay wallet', method: 'NBE Visa ••2314', category: 'Top-up', ref: 'MP-2026-373980', amount: 500.00, date: _d(6, 10, 0), status: TxStatus.success),
  Txn(id: 't10', type: TxType.nfc, title: 'Metro Market', method: 'NFC — Banque Misr Visa ••4582', category: 'Groceries', ref: 'MP-2026-370915', amount: -64.25, date: _d(7, 18, 30), status: TxStatus.failed),
];

/// Mock terminal heard over NFC during the tap-to-pay demo.
const demoTerminal = {'merchant': 'Coffee Corner', 'terminal': 'TT-12 · Cairo', 'amount': 85.00};
