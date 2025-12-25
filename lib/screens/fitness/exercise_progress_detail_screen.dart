import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/exercise.dart';
import '../../models/set_history.dart';
import '../../widgets/custom_card.dart';

class ExerciseProgressDetailScreen extends StatefulWidget {
  final Exercise exercise;
  final List<SetHistory> history;

  const ExerciseProgressDetailScreen({
    Key? key,
    required this.exercise,
    required this.history,
  }) : super(key: key);

  @override
  State<ExerciseProgressDetailScreen> createState() => _ExerciseProgressDetailScreenState();
}

class _ExerciseProgressDetailScreenState extends State<ExerciseProgressDetailScreen> {
  String _selectedPeriod = '30J';

  List<SetHistory> get _filteredHistory {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedPeriod) {
      case '7J':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case '30J':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case '3M':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      default:
        return widget.history;
    }

    return widget.history.where((h) => h.date.isAfter(cutoffDate)).toList();
  }

  List<FlSpot> _getChartData() {
    final filtered = _filteredHistory;
    if (filtered.isEmpty) return [];

    Map<String, double> dailyMax = {};
    
    for (var set in filtered.reversed) {
      if (set.weight != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(set.date);
        if (!dailyMax.containsKey(dateKey) || set.weight! > dailyMax[dateKey]!) {
          dailyMax[dateKey] = set.weight!;
        }
      }
    }

    final sortedDates = dailyMax.keys.toList()..sort();
    List<FlSpot> spots = [];
    
    for (int i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyMax[sortedDates[i]]!));
    }

    return spots;
  }

  double _getMinWeight() {
    final spots = _getChartData();
    if (spots.isEmpty) return 0;
    return spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5;
  }

  double _getMaxWeight() {
    final spots = _getChartData();
    if (spots.isEmpty) return 100;
    return spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;
  }

  String _getProgressPercentage() {
    final spots = _getChartData();
    if (spots.length < 2) return '+0%';
    
    final first = spots.first.y;
    final last = spots.last.y;
    final progress = ((last - first) / first * 100).toStringAsFixed(1);
    
    return progress.startsWith('-') ? progress : '+$progress';
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();
    final hasData = chartData.isNotEmpty;
    final progressPercentage = _getProgressPercentage();
    final isPositive = !progressPercentage.startsWith('-');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progression',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                            ),
                            Text(
                              progressPercentage,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _PeriodButton(
                  label: '7J',
                  isSelected: _selectedPeriod == '7J',
                  onTap: () => setState(() => _selectedPeriod = '7J'),
                ),
                const SizedBox(width: 8),
                _PeriodButton(
                  label: '30J',
                  isSelected: _selectedPeriod == '30J',
                  onTap: () => setState(() => _selectedPeriod = '30J'),
                ),
                const SizedBox(width: 8),
                _PeriodButton(
                  label: '3M',
                  isSelected: _selectedPeriod == '3M',
                  onTap: () => setState(() => _selectedPeriod = '3M'),
                ),
                const SizedBox(width: 8),
                _PeriodButton(
                  label: 'Tout',
                  isSelected: _selectedPeriod == 'Tout',
                  onTap: () => setState(() => _selectedPeriod = 'Tout'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Évolution du poids',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!hasData)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Pas de données pour cette période'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 10,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 10,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}kg',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                                reservedSize: 40,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: _getMinWeight(),
                          maxY: _getMaxWeight(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData,
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Theme.of(context).colorScheme.primary,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surface,
                              tooltipBorder: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((LineBarSpot touchedSpot) {
                                  return LineTooltipItem(
                                    '${touchedSpot.y.toStringAsFixed(1)} kg',
                                    TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historique détaillé',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(_filteredHistory.take(20).map((set) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${set.setNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMM yyyy').format(set.date),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(set.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (set.weight != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                '${set.weight}kg',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: const Text(
                                'PDC',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          if (set.reps != null)
                            Text(
                              '${set.reps} reps',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
