import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_provider.dart';
import '../transactions/transactions_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../budgets/budgets_screen.dart';
import '../statistics/statistics_screen.dart';
import 'home_screen.dart';

/// ============================================================
/// VIEW : MainScreen
/// Écran principal avec navigation par onglets
/// ============================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionsScreen(),
    SizedBox.shrink(), // placeholder for FAB action
    BudgetsScreen(),
    StatisticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final app = AppProvider.of(context);
    final userId = app.authController.currentUser?.id;
    if (userId == null) return;
    await app.categoryController.loadCategories(userId);
    await app.transactionController.loadTransactions(userId);
    await app.budgetController.loadBudgets(userId);
  }

  void _onTabSelected(int index) {
    if (index == 2) {
      _openAddTransaction();
      return;
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _openAddTransaction() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (added == true && mounted) {
      _loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: const CircleBorder(),
        onPressed: _openAddTransaction,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      height: 60,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, FontAwesomeIcons.house, 'Accueil'),
          _buildNavItem(1, FontAwesomeIcons.listUl, 'Trans.'),
          const SizedBox(width: 40),
          _buildNavItem(3, FontAwesomeIcons.wallet, 'Budgets'),
          _buildNavItem(4, FontAwesomeIcons.chartPie, 'Stats'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : Theme.of(context).hintColor;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}