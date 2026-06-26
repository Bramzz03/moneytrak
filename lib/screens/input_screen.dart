import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  TransactionCategory? _selectedCategory;
  final _amountController = TextEditingController();
  final _labelController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() => _selectedCategory = null));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  bool get _isExpense => _tabController.index == 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_selectedCategory == null) {
      _showError('Pilih kategori terlebih dahulu');
      return;
    }
    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Masukkan jumlah yang valid');
      return;
    }

    setState(() => _saving = true);
    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _isExpense ? 'expense' : 'income',
      amount: amount,
      category: _selectedCategory!.name,
      label: _labelController.text.trim(),
      date: _selectedDate,
    );

    await StorageService.saveTransaction(tx);
    setState(() => _saving = false);

    if (mounted) {
      _showSuccess();
      _reset();
    }
  }

  void _reset() {
    _amountController.clear();
    _labelController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategory = null;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Transaksi berhasil disimpan!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('TAMBAH TRANSAKSI'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _isExpense ? AppColors.expense : AppColors.income,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Pengeluaran'),
                Tab(text: 'Pemasukan'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(isExpense: true),
          _buildForm(isExpense: false),
        ],
      ),
    );
  }

  Widget _buildForm({required bool isExpense}) {
    final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final categories = isExpense ? kExpenseCategories : kIncomeCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildFieldLabel('Tanggal'),
          const SizedBox(height: 8),
          _buildTapField(
            icon: Icons.calendar_today_outlined,
            value: dateStr,
            onTap: _pickDate,
          ),
          const SizedBox(height: 18),
          _buildFieldLabel('Kategori'),
          const SizedBox(height: 10),
          _buildCategoryGrid(categories),
          const SizedBox(height: 18),
          _buildFieldLabel('Jumlah (Rp)'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                hintText: '0',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
              onChanged: (v) {
                final digits = v.replaceAll('.', '');
                final n = int.tryParse(digits);
                if (n != null) {
                  final formatted = formatter.format(n);
                  _amountController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 18),
          _buildFieldLabel('Keterangan (opsional)'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TextField(
              controller: _labelController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Type in custom label',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: isExpense ? AppColors.expense : AppColors.income,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isExpense ? 'SIMPAN PENGELUARAN' : 'SIMPAN PEMASUKAN',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTapField({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<TransactionCategory> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = _selectedCategory?.name == cat.name;
        final color = AppColors.categoryColors[cat.colorIndex % AppColors.categoryColors.length];

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : AppColors.cardBorder,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, color: isSelected ? color : AppColors.textMuted, size: 24),
                const SizedBox(height: 4),
                Text(
                  cat.name,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
