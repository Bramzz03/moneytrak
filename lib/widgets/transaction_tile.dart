import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme.dart';
import 'category_icon.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  IconData _getCategoryIcon() {
    final all = [...kExpenseCategories, ...kIncomeCategories];
    final match = all.where((c) => c.name == transaction.category).firstOrNull;
    return match?.icon ?? Icons.payment_rounded;
  }

  int _getCategoryColorIndex() {
    final all = [...kExpenseCategories, ...kIncomeCategories];
    final match = all.where((c) => c.name == transaction.category).firstOrNull;
    return match?.colorIndex ?? 8;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(transaction.date);
    final amountColor = transaction.isIncome ? AppColors.income : AppColors.expense;
    final amountPrefix = transaction.isIncome ? '+' : '-';

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.expense),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            CategoryIcon(
              icon: _getCategoryIcon(),
              colorIndex: _getCategoryColorIndex(),
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.label.isNotEmpty
                        ? transaction.label
                        : transaction.category,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.category} • $dateStr',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix${formatter.format(transaction.amount)}',
              style: TextStyle(
                color: amountColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
