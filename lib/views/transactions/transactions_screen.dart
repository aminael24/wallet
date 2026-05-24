import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_list_item.dart';
import 'transaction_detail_screen.dart';

/// ============================================================
/// VIEW : TransactionsScreen
/// Liste complète des transactions avec filtre par type
/// ============================================================
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txCtrl = AppProvider.of(context).transactionController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Revenus'),
            Tab(text: 'Dépenses'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: txCtrl,
        builder: (ctx, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(txCtrl.getFilteredTransactions(null)),
              _buildList(txCtrl.getFilteredTransactions(AppConstants.typeIncome)),
              _buildList(txCtrl.getFilteredTransactions(AppConstants.typeExpense)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List items) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Aucune transaction',
        subtitle: 'Ajoutez votre première transaction',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final t = items[i];
        return TransactionListItem(
          transaction: t,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transaction: t),
            ),
          ),
        );
      },
    );
  }
}
