import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class GeminiService {
  static const _apiKey = '';
  static const _model = 'openrouter/owl-alpha';
  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static String _buildSummary(List<Transaction> transactions) {
    if (transactions.isEmpty) return 'Tidak ada transaksi bulan ini.';

    double income = 0;
    double expense = 0;
    final Map<String, double> byCategory = {};

    for (final t in transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
      }
    }

    final topCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sb = StringBuffer();
    sb.writeln('Ringkasan keuangan bulan ini:');
    sb.writeln('- Total pemasukan: Rp ${income.toStringAsFixed(0)}');
    sb.writeln('- Total pengeluaran: Rp ${expense.toStringAsFixed(0)}');
    sb.writeln('- Saldo bersih: Rp ${(income - expense).toStringAsFixed(0)}');
    sb.writeln('- Pengeluaran per kategori:');
    for (final e in topCategories.take(5)) {
      sb.writeln('  * ${e.key}: Rp ${e.value.toStringAsFixed(0)}');
    }
    return sb.toString();
  }

  static String _sanitize(String text) {
    String s = text;
    s = s.replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m[1]!);
    s = s.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*', dotAll: true), (m) => m[1]!);
    s = s.replaceAllMapped(RegExp(r'__(.+?)__', dotAll: true), (m) => m[1]!);
    s = s.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m[1]!);
    s = s.replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m[1]!);
    s = s.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    s = s.replaceAll(RegExp(r'```[a-z]*\n?'), '');
    s = s.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m[1]!);
    s = s.replaceAllMapped(RegExp(r'~~(.+?)~~'), (m) => m[1]!);
    s = s.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    s = s.replaceAll(RegExp(r'^\*\s+', multiLine: true), '• ');
    s = s.replaceAll(RegExp(r'^-\s+', multiLine: true), '• ');
    s = s.replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '');
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return s.trim();
  }

  static Future<String> _call(String systemPrompt, String userContent) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userContent},
              ],
              'temperature': 0.7,
              'max_tokens': 512,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = data['choices'][0]['message']['content'] as String;
        return _sanitize(raw);
      } else {
        return 'Gagal mendapatkan respons AI (${response.statusCode}). Coba lagi nanti.';
      }
    } catch (e) {
      return 'Koneksi gagal. Pastikan internet tersedia dan coba lagi.';
    }
  }

  static Future<String> getFinancialAdvice(List<Transaction> transactions) async {
    final summary = _buildSummary(transactions);
    const systemPrompt =
        'Kamu adalah penasihat keuangan pribadi yang bijaksana dan ramah. '
        'Berikan saran keuangan yang spesifik, praktis, dan memotivasi berdasarkan data yang diberikan. '
        'Gunakan bahasa Indonesia yang santai. Maksimal 4 kalimat. Langsung ke inti saran. '
        'Jangan ulangi data yang sudah ada. Fokus pada perbaikan dan peluang.';
    return _call(systemPrompt, summary);
  }

  static Future<String> chatWithAI(
      String userMessage, List<Transaction> recentTransactions) async {
    final summary = _buildSummary(recentTransactions);
    const systemPrompt =
        'Kamu adalah MoneyTrak AI, asisten keuangan pribadi yang cerdas dan ramah. '
        'Kamu memiliki data keuangan pengguna bulan ini. '
        'Jawab pertanyaan dengan bahasa Indonesia yang santai, informatif, dan praktis. '
        'Berikan saran yang spesifik berdasarkan data yang ada.';
    return _call(systemPrompt, 'Data keuangan pengguna:\n$summary\n\nPertanyaan: $userMessage');
  }
}
