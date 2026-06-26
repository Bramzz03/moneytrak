import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _selectedMonth;
  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _transactions = StorageService.getTransactionsByMonth(
        _selectedMonth.year,
        _selectedMonth.month,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  List<DateTime> _getMonthOptions() {
    final now = DateTime.now();
    return List.generate(12, (i) => DateTime(now.year, now.month - i, 1));
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final income = _transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final expense = _transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('RIWAYAT TRANSAKSI'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildMonthPicker(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBar(formatter, income, expense),
          Expanded(
            child: _transactions.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                    itemCount: _transactions.length,
                    itemBuilder: (context, i) => TransactionTile(
                      transaction: _transactions[i],
                      onDelete: () async {
                        await StorageService.deleteTransaction(_transactions[i].id);
                        _loadData();
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    final months = _getMonthOptions();
    return GestureDetector(
      onTap: () => _showMonthPicker(months),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('MMM yyyy', 'id_ID').format(_selectedMonth),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(List<DateTime> months) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Pilih Bulan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              children: months.map((m) => ListTile(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedMonth = m);
                  _loadData();
                },
                title: Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(m),
                  style: TextStyle(
                    color: m.month == _selectedMonth.month && m.year == _selectedMonth.year
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: m.month == _selectedMonth.month && m.year == _selectedMonth.year
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                trailing: m.month == _selectedMonth.month && m.year == _selectedMonth.year
                    ? const Icon(Icons.check, color: AppColors.primary, size: 18)
                    : null,
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar(NumberFormat formatter, double income, double expense) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pemasukan', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text(
                  formatter.format(income),
                  style: const TextStyle(color: AppColors.income, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: AppColors.cardBorder),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Pengeluaran', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text(
                  formatter.format(expense),
                  style: const TextStyle(color: AppColors.expense, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 60, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada transaksi\ndi bulan ini',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
