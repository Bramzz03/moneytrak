import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/gemini_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';
import '../widgets/donut_chart.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'Pengguna';
  String _aiAdvice = '';
  bool _loadingAI = false;
  List<Transaction> _recentTransactions = [];
  double _totalBalance = 0;
  double _monthIncome = 0;
  double _monthExpense = 0;
  Map<String, double> _categoryData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final name = await SettingsService.getName();
    setState(() {
      _userName = name;
      _totalBalance = StorageService.getTotalBalance();
      _monthIncome = StorageService.getMonthlyIncome(now.year, now.month);
      _monthExpense = StorageService.getMonthlyExpense(now.year, now.month);
      _categoryData = StorageService.getExpenseByCategory(now.year, now.month);
      _recentTransactions = StorageService.getAllTransactions().take(3).toList();
    });
  }

  Future<void> _fetchAIAdvice() async {
    if (_loadingAI) return;
    setState(() => _loadingAI = true);
    final now = DateTime.now();
    final txs = StorageService.getTransactionsByMonth(now.year, now.month);
    final advice = await GeminiService.getFinancialAdvice(txs);
    setState(() {
      _aiAdvice = advice;
      _loadingAI = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final greeting = _getGreeting();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.card,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(greeting),
                    const SizedBox(height: 24),
                    _buildBalanceCard(formatter),
                    const SizedBox(height: 16),
                    _buildAIAdvisorCard(),
                    const SizedBox(height: 16),
                    _buildChartCard(),
                    const SizedBox(height: 16),
                    if (_recentTransactions.isNotEmpty) ...[
                      _buildSectionHeader('Transaksi Terbaru'),
                      const SizedBox(height: 12),
                      ..._recentTransactions.map((t) => TransactionTile(
                            transaction: t,
                            onDelete: () async {
                              await StorageService.deleteTransaction(t.id);
                              _loadData();
                            },
                          )),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String greeting) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              _userName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF00D46A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text('W', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(NumberFormat formatter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A6B6B), Color(0xFF0E4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL SALDO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(_totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildBalanceStat(
                '↑ ${formatter.format(_monthIncome)}',
                'Pemasukan',
                AppColors.income,
              ),
              const SizedBox(width: 24),
              _buildBalanceStat(
                '↓ ${formatter.format(_monthExpense)}',
                'Pengeluaran',
                AppColors.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildAIAdvisorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Financial Advisor',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Powered by Gemini',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _fetchAIAdvice,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'Refresh',
                    style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loadingAI)
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            )
          else if (_aiAdvice.isEmpty)
            GestureDetector(
              onTap: _fetchAIAdvice,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app_outlined, color: AppColors.accent.withValues(alpha: 0.7), size: 18),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Ketuk "Refresh" untuk mendapat saran keuangan AI',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              _aiAdvice,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pengeluaran Bulan Ini',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: DonutChart(data: _categoryData),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }
}
