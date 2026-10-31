import 'package:flutter/material.dart';

/// Payment network brand of a card.
enum PayBrand { visa, mastercard }

/// An Egyptian bank whose real card artwork the wallet reproduces.
/// Colors are close approximations of each bank's visual identity for the
/// prototype; production should ship official SVG logos in assets/banks/.
class BankBrand {
  final String id;
  final String displayEn; // e.g. "Banque Misr"
  final String displayAr; // e.g. "بنك مصر"
  final String short; // emblem letters, e.g. "BM"
  final Color c1, c2, accent;
  const BankBrand(this.id, this.displayEn, this.displayAr, this.short,
      this.c1, this.c2, this.accent);
}

/// A tokenized bank card.
/// SECURITY (spec §2): only [last4] is ever persisted/displayed after
/// verification. Full PAN is discarded, CVV/PIN are never stored, and
/// [token] (from the PSP) stands in for the card number everywhere.
class BankCard {
  final String id;
  final BankBrand bank;
  final PayBrand brand;
  final String last4;
  final String holder;
  final String exp; // MM/yy
  final String token;
  final bool viaNfc; // added through NFC card reading
  bool isDefault;
  bool frozen;
  BankCard({
    required this.id,
    required this.bank,
    required this.brand,
    required this.last4,
    required this.holder,
    required this.exp,
    required this.token,
    this.isDefault = false,
    this.frozen = false,
    this.viaNfc = false,
  });
}

/// Egyptian mobile-money wallet providers (spec §3).
class WalletProvider {
  final String id;
  final String nameEn, nameAr;
  final Color c1, c2;
  const WalletProvider(this.id, this.nameEn, this.nameAr, this.c1, this.c2);
}

/// A linked wallet. Only the masked number is kept.
class EWallet {
  final String id;
  final WalletProvider provider;
  final String masked; // e.g. "0100 •• 845"
  bool isDefault;
  EWallet({required this.id, required this.provider, required this.masked, this.isDefault = false});
}

enum TxType { nfc, qr, card, wallet, recharge }
enum TxStatus { success, pending, failed }

/// Unified transaction (spec §8).
class Txn {
  final String id;
  final TxType type;
  final String title;
  final String method; // human-readable payment method, masked
  final String category;
  final String ref; // reference number when available
  final double amount; // negative = money out
  final DateTime date;
  final TxStatus status;
  const Txn({
    required this.id,
    required this.type,
    required this.title,
    required this.method,
    required this.category,
    required this.ref,
    required this.amount,
    required this.date,
    required this.status,
  });
}

/// Mobile operator for balance recharge (spec §7).
class Operator {
  final String id;
  final String nameEn, nameAr, prefix;
  final Color color;
  const Operator(this.id, this.nameEn, this.nameAr, this.prefix, this.color);
}

class Merchant {
  final String name, handle, categoryEn, categoryAr;
  final Color color;
  const Merchant(this.name, this.handle, this.categoryEn, this.categoryAr, this.color);
}
