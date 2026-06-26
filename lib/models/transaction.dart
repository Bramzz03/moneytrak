import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String type; // 'income' | 'expense'
  final double amount;
  final String category;
  final String label;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.label,
    required this.date,
  });

  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'amount': amount,
        'category': category,
        'label': label,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromMap(Map map) => Transaction(
        id: map['id'] as String,
        type: map['type'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        label: map['label'] as String,
        date: DateTime.parse(map['date'] as String),
      );
}

class TransactionCategory {
  final String name;
  final IconData icon;
  final int colorIndex;
  final bool isIncomeOnly;

  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.colorIndex,
    this.isIncomeOnly = false,
  });
}

const List<TransactionCategory> kExpenseCategories = [
  TransactionCategory(name: 'Makanan', icon: Icons.restaurant_rounded, colorIndex: 0),
  TransactionCategory(name: 'Transport', icon: Icons.directions_car_rounded, colorIndex: 1),
  TransactionCategory(name: 'Belanja', icon: Icons.shopping_bag_rounded, colorIndex: 2),
  TransactionCategory(name: 'Hiburan', icon: Icons.movie_rounded, colorIndex: 3),
  TransactionCategory(name: 'Tagihan', icon: Icons.receipt_long_rounded, colorIndex: 4),
  TransactionCategory(name: 'Kesehatan', icon: Icons.favorite_rounded, colorIndex: 5),
  TransactionCategory(name: 'Pendidikan', icon: Icons.school_rounded, colorIndex: 6),
  TransactionCategory(name: 'Lainnya', icon: Icons.category_rounded, colorIndex: 8),
];

const List<TransactionCategory> kIncomeCategories = [
  TransactionCategory(name: 'Gaji', icon: Icons.work_rounded, colorIndex: 7, isIncomeOnly: true),
  TransactionCategory(name: 'Freelance', icon: Icons.laptop_rounded, colorIndex: 1, isIncomeOnly: true),
  TransactionCategory(name: 'Investasi', icon: Icons.trending_up_rounded, colorIndex: 5, isIncomeOnly: true),
  TransactionCategory(name: 'Hadiah', icon: Icons.card_giftcard_rounded, colorIndex: 2, isIncomeOnly: true),
  TransactionCategory(name: 'Lainnya', icon: Icons.attach_money_rounded, colorIndex: 8, isIncomeOnly: true),
];
