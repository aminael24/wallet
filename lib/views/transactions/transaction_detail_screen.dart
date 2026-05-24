import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_formatters.dart';
import '../../utils/app_provider.dart';
import 'add_transaction_screen.dart';

/// ============================================================
/// VIEW : TransactionDetailScreen
/// Détails d'une transaction avec actions modifier/supprimer
/// ============================================================
class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la transaction ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final app = AppProvider.of(context);
    final userId = app.authController.currentUser!.id!;
    final success =
        await app.transactionController.deleteTransaction(transaction.id!, userId);
    await app.budgetController.loadBudgets(userId);

    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction supprimée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == AppConstants.typeIncome;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final catColor = transaction.categoryColorIndex != null
        ? AppColors.categoryColors[
            transaction.categoryColorIndex! % AppColors.categoryColors.length]
        : AppColors.primary;
    final catIcon = transaction.categoryIconCodePoint != null
        ? iconFromCodePoint(transaction.categoryIconCodePoint!)
        : Icons.category;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(transaction: transaction),
                ),
              );
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Icône + montant
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  '${isIncome ? '+' : '-'} ${AppFormatters.formatCurrency(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isIncome ? 'Revenu' : 'Dépense',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Détails
          Card(
            child: Column(
              children: [
                _detailRow(context, 'Titre', transaction.title, Icons.title),
                const Divider(height: 1),
                _detailRow(context, 'Catégorie',
                    transaction.categoryName ?? '-', Icons.category_outlined),
                const Divider(height: 1),
                _detailRow(context, 'Date',
                    AppFormatters.formatLongDate(transaction.date),
                    Icons.calendar_today),
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  const Divider(height: 1),
                  _detailRow(context, 'Note', transaction.note!, Icons.notes),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
      BuildContext ctx, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(ctx).hintColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(ctx).hintColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
