import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/app_formatters.dart';

/// Widget : tuile représentant une transaction dans la liste
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == AppConstants.typeIncome;
    final color = transaction.categoryColorIndex != null
        ? AppColors.categoryColors[
            transaction.categoryColorIndex! % AppColors.categoryColors.length]
        : AppColors.primary;
    final icon = transaction.categoryIconCodePoint != null
        ? iconFromCodePoint(transaction.categoryIconCodePoint!)
        : Icons.category;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icône catégorie
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              // Titre + catégorie + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          transaction.categoryName ?? '',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '•',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppFormatters.formatRelativeDate(transaction.date),
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Montant
              Text(
                '${isIncome ? '+' : '-'} ${AppFormatters.formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
