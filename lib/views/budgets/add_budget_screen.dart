import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/category_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_formatters.dart';
import '../../utils/app_provider.dart';
import '../../utils/validators.dart';

/// ============================================================
/// VIEW : AddBudgetScreen
/// Création d'un nouveau budget mensuel
/// ============================================================
class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  Category? _selectedCategory;
  DateTime _selectedMonth = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: 'Sélectionnez un mois',
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
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

    final success = await app.budgetController.addBudget(
      userId: userId,
      categoryId: _selectedCategory!.id!,
      limitAmount: amount,
      month: _selectedMonth.month,
      year: _selectedMonth.year,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget créé'),
          backgroundColor: AppColors.income,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories =
        AppProvider.of(context).categoryController.expenseCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Montant limite
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              validator: Validators.validateAmount,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Limite mensuelle',
                suffixText: 'MAD',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Catégorie (dépenses uniquement)
            const Text(
              'Catégorie de dépense',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: expenseCategories.map((c) {
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

            const SizedBox(height: 24),

            // Mois cible
            InkWell(
              onTap: _pickMonth,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Mois cible',
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                ),
                child: Text(AppFormatters.formatMonthYear(_selectedMonth)),
              ),
            ),

            const SizedBox(height: 32),

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
                  : const Text('Créer le budget'),
            ),
          ],
        ),
      ),
    );
  }
}
