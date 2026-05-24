import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_formatters.dart';
import '../../utils/app_provider.dart';
import '../../controllers/transaction_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_list_item.dart';
import '../profile/profile_screen.dart';
import '../transactions/transaction_detail_screen.dart';

/// ============================================================
/// VIEW : HomeScreen
/// Dashboard avec : solde, revenus/dépenses du mois, dernières transactions
/// ============================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppProvider.of(context);
    final user = app.authController.currentUser;
    final txCtrl = app.transactionController;
    final themeCtrl = app.themeController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
        ),
        actions: [
          ListenableBuilder(
            listenable: themeCtrl,
            builder: (ctx, _) {
              return IconButton(
                icon: Icon(themeCtrl.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined),
                onPressed: themeCtrl.toggleTheme,
                tooltip: 'Changer de thème',
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => txCtrl.loadTransactions(user!.id!),
        child: ListenableBuilder(
          listenable: txCtrl,
          builder: (ctx, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Salutation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.fullName.split(' ').first ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Carte du solde
                _buildBalanceCard(context, txCtrl),

                const SizedBox(height: 16),

                // Revenu / Dépense
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMiniCard(
                          context,
                          icon: FontAwesomeIcons.arrowDown,
                          title: 'Revenus du mois',
                          amount: txCtrl.monthlyIncome,
                          gradient: AppColors.incomeGradient,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMiniCard(
                          context,
                          icon: FontAwesomeIcons.arrowUp,
                          title: 'Dépenses du mois',
                          amount: txCtrl.monthlyExpense,
                          gradient: AppColors.expenseGradient,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section dernières transactions
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dernières transactions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Liste des 5 dernières transactions
                if (txCtrl.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Aucune transaction',
                      subtitle:
                          'Ajoutez votre première transaction en cliquant sur le bouton +',
                    ),
                  )
                else
                  ...txCtrl.transactions.take(5).map(
                        (t) => TransactionListItem(
                          transaction: t,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailScreen(transaction: t),
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 80), // Espace pour le FAB
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext ctx, TransactionController txCtrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solde total',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  FontAwesomeIcons.wallet,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppFormatters.formatCurrency(txCtrl.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                txCtrl.monthlyBalance >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${txCtrl.monthlyBalance >= 0 ? '+' : ''}${AppFormatters.formatCurrency(txCtrl.monthlyBalance)} ce mois',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildMiniCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double amount,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.formatCompactCurrency(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour ☀️';
    if (h < 18) return 'Bon après-midi 👋';
    return 'Bonsoir 🌙';
  }
}
