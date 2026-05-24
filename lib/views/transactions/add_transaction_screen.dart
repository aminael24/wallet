import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/category_model.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_formatters.dart';
import '../../utils/app_provider.dart';
import '../../utils/validators.dart';

/// ============================================================
/// VIEW : AddTransactionScreen
/// Création ou modification d'une transaction
/// ============================================================
class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction; // null = création

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _type = AppConstants.typeExpense;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _titleCtrl.text = t.title;
      _amountCtrl.text = t.amount.toString();
      _noteCtrl.text = t.note ?? '';
      _type = t.type;
      _selectedDate = t.date;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categories = AppProvider.of(context).categoryController.categories;
        setState(() {
          _selectedCategory = categories.firstWhere(
            (c) => c.id == t.categoryId,
            orElse: () => categories.first,
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final app = AppProvider.of(context);
    final userId = app.authController.currentUser!.id!;
    final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));

    bool success;
    if (_isEditing) {
      final updated = widget.transaction!.copyWith(
        categoryId: _selectedCategory!.id!,
        amount: amount,
        type: _type,
        title: _titleCtrl.text.trim(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        date: _selectedDate,
      );
      success = await app.transactionController.updateTransaction(updated);
    } else {
      success = await app.transactionController.addTransaction(
        userId: userId,
        categoryId: _selectedCategory!.id!,
        amount: amount,
        type: _type,
        title: _titleCtrl.text.trim(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        date: _selectedDate,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

  if (success) {
      // Refresh budgets aussi (montant dépensé a changé)
      await app.budgetController.loadBudgets(userId);
      if (!mounted) return;

      // 🚨 Vérifier les alertes de budget après ajout d'une dépense
      String? budgetAlert;
      if (_type == AppConstants.typeExpense) {
        // Cherche un budget pour cette catégorie ce mois-ci
        final currentMonth = _selectedDate.month;
        final currentYear = _selectedDate.year;
        final budget = app.budgetController.budgets.firstWhere(
          (b) =>
              b.categoryId == _selectedCategory!.id &&
              b.month == currentMonth &&
              b.year == currentYear,
          orElse: () => app.budgetController.budgets.isEmpty
              ? throw StateError('no_budget')
              : app.budgetController.budgets.first,
        );

        try {
          if (budget.categoryId == _selectedCategory!.id) {
            if (budget.isExceeded) {
              budgetAlert =
                  '🚨 Budget dépassé pour ${_selectedCategory!.name} ! Vous avez dépensé ${budget.spentAmount?.toStringAsFixed(2)} MAD sur ${budget.limitAmount.toStringAsFixed(2)} MAD.';
            } else if (budget.isWarning) {
              budgetAlert =
                  '⚠️ Attention ! Vous avez utilisé ${(budget.usageRatio * 100).toStringAsFixed(0)}% de votre budget ${_selectedCategory!.name}.';
            }
          }
        } catch (_) {
          // pas de budget pour cette catégorie, on ignore
        }
      }

      Navigator.of(context).pop(true);

      // Affiche le message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Transaction mise à jour'
              : 'Transaction ajoutée'),
          backgroundColor: AppColors.income,
          duration: const Duration(seconds: 2),
        ),
      );

      // 🚨 Affiche l'alerte de budget si nécessaire (avec délai)
      if (budgetAlert != null) {
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(budgetAlert!)),
                ],
              ),
              backgroundColor: budgetAlert!.contains('dépassé')
                  ? AppColors.danger
                  : AppColors.warning,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppProvider.of(context).categoryController.categories
        .where((c) => c.type == _type)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier la transaction' : 'Nouvelle transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sélecteur de type (revenu / dépense)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTypeButton(
                    label: 'Dépense',
                    type: AppConstants.typeExpense,
                    color: AppColors.expense,
                  ),
                  _buildTypeButton(
                    label: 'Revenu',
                    type: AppConstants.typeIncome,
                    color: AppColors.income,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Montant
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              validator: Validators.validateAmount,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Montant',
                suffixText: 'MAD',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => Validators.validateRequired(v, 'Le titre'),
              decoration: const InputDecoration(
                labelText: 'Titre',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            // Catégorie
            const Text(
              'Catégorie',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((c) {
                final isSelected = _selectedCategory?.id == c.id;
                final color = AppColors.categoryColors[
                    c.colorIndex % AppColors.categoryColors.length];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          iconFromCodePoint(c.iconCodePoint),
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          c.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(AppFormatters.formatDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),

           TextFormField(
              controller: _noteCtrl,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                hintText: 'Ex: anniversaire, voyage...',
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 32),

            // Bouton enregistrer
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(_isEditing ? 'Mettre à jour' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required String type,
    required Color color,
  }) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = type;
          // Réinitialise la catégorie si elle ne correspond plus au type
          if (_selectedCategory != null && _selectedCategory!.type != type) {
            _selectedCategory = null;
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).hintColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
