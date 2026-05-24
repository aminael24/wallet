import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_formatters.dart';
import '../../utils/app_provider.dart';
import '../../widgets/empty_state.dart';

/// ============================================================
/// VIEW : StatisticsScreen
/// Graphiques : camembert (dépenses par catégorie) + barres (évolution)
/// ============================================================
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();
  List<Map<String, dynamic>> _expensesByCategory = [];
  List<Map<String, dynamic>> _monthlyEvolution = [];
  bool _loading = false;
  int? _touchedPieIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final app = AppProvider.of(context);
    final userId = app.authController.currentUser!.id!;
    final pie = await app.transactionController.getExpensesByCategory(
      userId,
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final evo = await app.transactionController.getMonthlyEvolution(userId);
    if (!mounted) return;
    setState(() {
      _expensesByCategory = pie;
      _monthlyEvolution = evo;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  // Sélecteur de mois
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _changeMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              AppFormatters.formatMonthYear(_selectedMonth),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _selectedMonth.year ==
                                      DateTime.now().year &&
                                  _selectedMonth.month >=
                                      DateTime.now().month
                              ? null
                              : () => _changeMonth(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),

                  // Graphique camembert (dépenses par catégorie)
                  _buildSectionTitle('Dépenses par catégorie'),
                  _buildPieChartSection(),

                  const SizedBox(height: 24),

                  // Graphique barres (évolution 6 mois)
                  _buildSectionTitle('Évolution des 6 derniers mois'),
                  _buildBarChartSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPieChartSection() {
    if (_expensesByCategory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: EmptyState(
          icon: FontAwesomeIcons.chartPie,
          title: 'Pas de dépenses ce mois',
          subtitle: 'Les graphiques apparaîtront ici',
        ),
      );
    }

    final total = _expensesByCategory.fold<double>(
        0, (sum, item) => sum + (item['total'] as num).toDouble());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total : ${AppFormatters.formatCurrency(total)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback:
                        (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedPieIndex = -1;
                          return;
                        }
                        _touchedPieIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: _buildPieSections(total),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Légende
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _expensesByCategory.asMap().entries.map((e) {
                final item = e.value;
                final color = AppColors.categoryColors[
                    (item['color_index'] as int) %
                        AppColors.categoryColors.length];
                final pct = total > 0
                    ? ((item['total'] as num) / total * 100).toStringAsFixed(1)
                    : '0.0';
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item['category_name']} ($pct%)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(double total) {
    return _expensesByCategory.asMap().entries.map((e) {
      final i = e.key;
      final item = e.value;
      final isTouched = i == _touchedPieIndex;
      final radius = isTouched ? 70.0 : 60.0;
      final amount = (item['total'] as num).toDouble();
      final percent = total > 0 ? (amount / total * 100) : 0.0;
      final color = AppColors.categoryColors[
          (item['color_index'] as int) % AppColors.categoryColors.length];

      return PieChartSectionData(
        color: color,
        value: amount,
        title: '${percent.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildBarChartSection() {
    if (_monthlyEvolution.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = _monthlyEvolution.fold<double>(0, (max, item) {
      final inc = (item['income'] as num).toDouble();
      final exp = (item['expense'] as num).toDouble();
      final m = inc > exp ? inc : exp;
      return m > max ? m : max;
    });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(AppColors.income, 'Revenus'),
                const SizedBox(width: 24),
                _legendDot(AppColors.expense, 'Dépenses'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY > 0 ? maxY * 1.2 : 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          AppFormatters.formatCompactCurrency(rod.toY),
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= _monthlyEvolution.length) {
                            return const SizedBox.shrink();
                          }
                          final m = _monthlyEvolution[idx]['month'] as int;
                          const months = [
                            '',
                            'Jan',
                            'Fév',
                            'Mar',
                            'Avr',
                            'Mai',
                            'Juin',
                            'Juil',
                            'Aoû',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Déc'
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              months[m],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: _monthlyEvolution.asMap().entries.map((e) {
                    final i = e.key;
                    final m = e.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (m['income'] as num).toDouble(),
                          color: AppColors.income,
                          width: 8,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: (m['expense'] as num).toDouble(),
                          color: AppColors.expense,
                          width: 8,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
