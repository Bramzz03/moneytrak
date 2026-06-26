import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class StorageService {
  static const _boxName = 'transactions';
  static const _chatBoxName = 'chat_history';
  static late Box _box;
  static late Box _chatBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _chatBox = await Hive.openBox(_chatBoxName);
  }

  static Future<void> saveTransaction(Transaction tx) async {
    await _box.put(tx.id, tx.toMap());
  }

  static Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  static List<Transaction> getAllTransactions() {
    return _box.values
        .map((v) => Transaction.fromMap(Map<String, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<Transaction> getTransactionsByMonth(int year, int month) {
    return getAllTransactions()
        .where((t) => t.date.year == year && t.date.month == month)
        .toList();
  }

  static double getTotalBalance() {
    final all = getAllTransactions();
    double total = 0;
    for (final t in all) {
      total += t.isIncome ? t.amount : -t.amount;
    }
    return total;
  }

  static double getMonthlyIncome(int year, int month) {
    return getTransactionsByMonth(year, month)
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  static double getMonthlyExpense(int year, int month) {
    return getTransactionsByMonth(year, month)
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  static List<Map<String, dynamic>> getChatMessages() {
    final raw = _chatBox.get('messages', defaultValue: <dynamic>[]) as List;
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> saveChatMessages(List<Map<String, dynamic>> messages) async {
    await _chatBox.put('messages', messages);
  }

  static Future<void> clearChat() async {
    await _chatBox.delete('messages');
  }

  static Map<String, double> getExpenseByCategory(int year, int month) {
    final expenses = getTransactionsByMonth(year, month).where((t) => !t.isIncome);
    final Map<String, double> result = {};
    for (final t in expenses) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }
}
