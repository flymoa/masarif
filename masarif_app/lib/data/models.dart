import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TxType { expense, income }

TxType _type(Object? v) => v == 'income' ? TxType.income : TxType.expense;

class Txn {
  Txn({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note = '',
    this.deleted = false,
    this.updatedAt,
  });

  final String id;
  final TxType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String note;
  final bool deleted;
  final DateTime? updatedAt;

  double get signed => type == TxType.income ? amount : -amount;

  factory Txn.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Txn(
      id: d.id,
      type: _type(m['type']),
      amount: (m['amount'] as num).toDouble(),
      categoryId: m['categoryId'] as String? ?? 'other_exp',
      date: (m['date'] as Timestamp).toDate(),
      note: m['note'] as String? ?? '',
      deleted: m['deleted'] as bool? ?? false,
      updatedAt: (m['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'amount': amount,
        'categoryId': categoryId,
        'date': Timestamp.fromDate(date),
        'note': note,
        'deleted': deleted,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Icones li l user y9der ykhtar (key → icon). "netflix" o "spotify" kayrsmo b widget khass.
const catIcons = <String>{'resto', 'cart', 'coffee', 'car', 'home', 'bolt', 'pharma', 'play', 'netflix', 'spotify', 'sport', 'gift', 'phone', 'book', 'work', 'wallet', 'box'};

/// Smiyat 9dam → jdad (bach data l9dima tb9a khddama).
const _iconAlias = {'food': 'resto', 'bulb': 'bolt', 'health': 'pharma'};
const _colorAlias = {'orange': 'terra', 'blue': 'forest', 'purple': 'plum', 'gray': 'stone', 'red': 'terra'};

/// Alwan "terre" mtwa7din m3a l theme: [fg light, bg light, fg dark, bg dark]
const catPalette = <String, List<int>>{
  'brown': [0xFF6B4423, 0xFFEFE4D8, 0xFFD9A577, 0xFF33261B],
  'forest': [0xFF0F3B2C, 0xFFE3ECE6, 0xFF7FD3A4, 0xFF1C3A2E],
  'green': [0xFF1F8A57, 0xFFE3F1EA, 0xFF5FC48E, 0xFF173A2A],
  'sage': [0xFF4F7A63, 0xFFE6EEE9, 0xFFA9C9B6, 0xFF203029],
  'gold': [0xFF9A6D12, 0xFFF6EDD5, 0xFFE9C46A, 0xFF352B12],
  'terra': [0xFFA0471F, 0xFFF5E6DE, 0xFFF0A070, 0xFF3A2518],
  'plum': [0xFF5B4A7A, 0xFFECE7F3, 0xFFC3A0F0, 0xFF2A2438],
  'stone': [0xFF6E6658, 0xFFECEAE4, 0xFFC9C5BC, 0xFF2A2926],
};
class Cat {
  const Cat({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String icon;
  final String color;
  final TxType type;
  final bool isDefault;

  String get iconKey => _iconAlias[icon] ?? icon;
  String get colorKey => catPalette.containsKey(color) ? color : (_colorAlias[color] ?? 'stone');
  String get iconData => catIcons.contains(iconKey) ? iconKey : 'box';

  Color fg(Brightness b) => Color(catPalette[colorKey]![b == Brightness.light ? 0 : 2]);
  Color bg(Brightness b) => Color(catPalette[colorKey]![b == Brightness.light ? 1 : 3]);

  factory Cat.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Cat(
      id: d.id,
      name: m['name'] as String? ?? '',
      icon: m['icon'] as String? ?? 'box',
      color: m['color'] as String? ?? 'stone',
      type: _type(m['type']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'icon': icon,
        'color': color,
        'type': type.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Categories jahza (PDR + Tqdya, Se77a, Tfaraj).
const defaultCats = <Cat>[
  Cat(id: 'food', name: 'Makla', icon: 'resto', color: 'terra', type: TxType.expense, isDefault: true),
  Cat(id: 'groceries', name: 'Tqdya', icon: 'cart', color: 'terra', type: TxType.expense, isDefault: true),
  Cat(id: 'transport', name: 'Na9l', icon: 'car', color: 'forest', type: TxType.expense, isDefault: true),
  Cat(id: 'rent', name: 'Lekra', icon: 'home', color: 'forest', type: TxType.expense, isDefault: true),
  Cat(id: 'bills', name: 'Fawatir', icon: 'bolt', color: 'gold', type: TxType.expense, isDefault: true),
  Cat(id: 'health', name: 'Se77a', icon: 'pharma', color: 'green', type: TxType.expense, isDefault: true),
  Cat(id: 'fun', name: 'Tfaraj', icon: 'play', color: 'plum', type: TxType.expense, isDefault: true),
  Cat(id: 'other_exp', name: 'Okhra', icon: 'box', color: 'stone', type: TxType.expense, isDefault: true),
  Cat(id: 'salary', name: 'Salaire', icon: 'work', color: 'forest', type: TxType.income, isDefault: true),
  Cat(id: 'other_inc', name: 'Okhra', icon: 'wallet', color: 'green', type: TxType.income, isDefault: true),
];

enum MoveType { put, take }

class SavingMove {
  SavingMove({required this.id, required this.type, required this.amount, required this.date, this.source = 'manual', this.month});

  final String id;
  final MoveType type;
  final double amount;
  final DateTime date;
  final String source; // 'manual' | 'month_left'
  final String? month; // "2026-10" ila source = month_left

  double get signed => type == MoveType.put ? amount : -amount;

  factory SavingMove.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return SavingMove(
      id: d.id,
      type: m['type'] == 'take' ? MoveType.take : MoveType.put,
      amount: (m['amount'] as num).toDouble(),
      date: (m['date'] as Timestamp).toDate(),
      source: m['source'] as String? ?? 'manual',
      month: m['month'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'source': source,
        'month': month,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class UserProfile {
  UserProfile({this.name = '', this.email = '', this.goal, this.autoSavings = false, this.hiddenCats = const [], this.lastPromptMonth, this.theme = 'system', this.photo, this.notifsReadAt});

  /// Tswira dyal l profil (JPEG sghir b base64, kaytsjel f Firestore — bla Storage).
  final String? photo;
  final DateTime? notifsReadAt;

  /// 'light' | 'dark' | 'system'
  final String theme;

  final String name;
  final String email;
  final double? goal;
  final bool autoSavings;
  final List<String> hiddenCats;
  final String? lastPromptMonth;

  factory UserProfile.fromMap(Map<String, dynamic>? m) => UserProfile(
        name: m?['name'] as String? ?? '',
        email: m?['email'] as String? ?? '',
        goal: (m?['savingsGoal'] as num?)?.toDouble(),
        autoSavings: m?['autoSavings'] as bool? ?? false,
        hiddenCats: List<String>.from(m?['hiddenCats'] as List? ?? const []),
        lastPromptMonth: m?['lastPromptMonth'] as String?,
        theme: m?['theme'] as String? ?? 'system',
        photo: m?['photo'] as String?,
        notifsReadAt: (m?['notifsReadAt'] as Timestamp?)?.toDate(),
      );
}
