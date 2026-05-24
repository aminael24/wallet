import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/budget_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_formatters.dart';
import '../../utils/app_provider.dart';
import '../../widgets/empty_state.dart';
import 'add_budget_screen.dart';

/// ============================================================
/// VIEW : BudgetsScreen
/// Liste des budgets du mois avec progression
/// ============================================================
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Budget b) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce budget ?'),
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
    await app.budgetController.deleteBudget(b.id!, userId);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppProvider.of(context);
    final budgetCtrl = app.budgetController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
              );
              if (added == true) {
                await budgetCtrl.loadBudgets(app.authController.currentUser!.id!);
              }
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: budgetCtrl,
        builder: (ctx, _) {
          if (budgetCtrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // En-tête : mois + alertes
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(FontAwesomeIcons.calendar,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mois en cours',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              AppFormatters.formatMonthYear(DateTime(
                                  budgetCtrl.selectedYear,
                                  budgetCtrl.selectedMonth)),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (budgetCtrl.exceededCount > 0)
                        _alertChip(
                          '${budgetCtrl.exceededCount} dépassé(s)',
                          AppColors.danger,
                        )
                      else if (budgetCtrl.warningCount > 0)
                        _alertChip(
                          '${budgetCtrl.warningCount} attention',
                          AppColors.warning,
                        ),
                    ],
                  ),
                ),
              ),

              // Liste des budgets
              Expanded(
                child: budgetCtrl.budgets.isEmpty
                    ? EmptyState(
                        icon: FontAwesomeIcons.wallet,
                        title: 'Aucun budget défini',
                        subtitle:
                            'Créez un budget pour mieux suivre vos dépenses',
                        action: ElevatedButton.icon(
                          onPressed: () async {
                            final added =
                                await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                  builder: (_) => const AddBudgetScreen()),
                            );
                            if (added == true) {
                              await budgetCtrl.loadBudgets(
                                  app.authController.currentUser!.id!);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Créer un budget'),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: budgetCtrl.budgets.length,
                        itemBuilder: (ctx, i) =>
                            _buildBudgetCard(context, budgetCtrl.budgets[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _alertChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, Budget b) {
    final color = b.categoryColorIndex != null
        ? AppColors.categoryColors[
            b.categoryColorIndex! % AppColors.categoryColors.length]
        : AppColors.primary;
    final icon = b.categoryIconCodePoint != null
        ? iconFromCodePoint(b.categoryIconCodePoint!)
        : Icons.category;

    final ratio = b.usageRatio.clamp(0.0, 1.0);
    final statusColor = b.isExceeded
        ? AppColors.danger
        : b.isWarning
            ? AppColors.warning
            : AppColors.income;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onLongPress: () => _confirmDelete(context, b),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.categoryName ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${AppFormatters.formatCurrency(b.spentAmount ?? 0)} / ${AppFormatters.formatCurrency(b.limitAmount)}',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(b.usageRatio * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor:
                      Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 8),
              if (b.isExceeded)
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.danger, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Budget dépassé de ${AppFormatters.formatCurrency(-b.remainingAmount)}',
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else if (b.isWarning)
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.warning, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Reste : ${AppFormatters.formatCurrency(b.remainingAmount)}',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Reste : ${AppFormatters.formatCurrency(b.remainingAmount)}',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
