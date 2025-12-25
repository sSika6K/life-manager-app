import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/expense.dart';
import '../../models/bill.dart';
import '../../models/subscription.dart';
import '../../widgets/custom_card.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import 'add_expense_screen.dart';
import 'bills_screen.dart';
import 'subscriptions_screen.dart';

class FinanceDashboard extends StatefulWidget {
  final int userId;

  const FinanceDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  List<Expense> _expenses = [];
  List<Bill> _bills = [];
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  double _totalExpenses = 0;
  double _totalBills = 0;
  double _totalSubscriptions = 0;
  Map<String, double> _categoryExpenses = {};

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  Future<void> _loadFinanceData() async {
    setState(() => _isLoading = true);

    final expenses = await DatabaseHelper.instance.getExpensesByUser(widget.userId);
    final bills = await DatabaseHelper.instance.getBillsByUser(widget.userId);
    final subscriptions = await DatabaseHelper.instance.getSubscriptionsByUser(widget.userId);

    // Filtrer les dépenses du mois en cours
    final now = DateTime.now();
    final thisMonthExpenses = expenses.where((e) =>
        e.date.year == now.year && e.date.month == now.month).toList();

    // Calculer le total des dépenses
    double totalExpenses = 0;
    Map<String, double> categoryExpenses = {};
    
    for (var expense in thisMonthExpenses) {
      totalExpenses += expense.amount;
      categoryExpenses[expense.category] = 
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }

    // Calculer le total des factures impayées
    double totalBills = 0;
    for (var bill in bills) {
      if (!bill.isPaid) {
        totalBills += bill.amount;
      }
    }

    // Calculer le total des abonnements mensuels
    double totalSubscriptions = 0;
    for (var sub in subscriptions) {
      if (sub.isActive) {
        totalSubscriptions += Helpers.calculateMonthlyCost(sub.amount, sub.frequency);
      }
    }

    setState(() {
      _expenses = thisMonthExpenses;
      _bills = bills;
      _subscriptions = subscriptions;
      _totalExpenses = totalExpenses;
      _totalBills = totalBills;
      _totalSubscriptions = totalSubscriptions;
      _categoryExpenses = categoryExpenses;
      _isLoading = false;
    });
  }

  void _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadFinanceData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dépense supprimée')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadFinanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Résumé financier
            Text(
              'Résumé du mois',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Dépenses',
                    Helpers.formatCurrency(_totalExpenses),
                    Icons.shopping_cart,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Factures',
                    Helpers.formatCurrency(_totalBills),
                    Icons.receipt,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              'Abonnements mensuels',
              Helpers.formatCurrency(_totalSubscriptions),
              Icons.subscriptions,
              Colors.purple,
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpenseScreen(userId: widget.userId),
                        ),
                      );
                      _loadFinanceData();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Dépense'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillsScreen(userId: widget.userId),
                        ),
                      );
                      _loadFinanceData();
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Factures'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubscriptionsScreen(userId: widget.userId),
                    ),
                  );
                  _loadFinanceData();
                },
                icon: const Icon(Icons.card_membership),
                label: const Text('Abonnements'),
              ),
            ),
            const SizedBox(height: 24),

            // Dépenses par catégorie
            if (_categoryExpenses.isNotEmpty) ...[
              Text(
                'Dépenses par catégorie',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._categoryExpenses.entries.map((entry) {
                final percentage = (_totalExpenses > 0)
                    ? (entry.value / _totalExpenses * 100).toStringAsFixed(0)
                    : '0';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              Helpers.formatCurrency(entry.value),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: entry.value / _totalExpenses,
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percentage% du total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],

            // Dernières dépenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dernières dépenses',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_expenses.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Afficher toutes les dépenses
                    },
                    child: const Text('Tout voir'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_expenses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune dépense ce mois-ci',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._expenses.take(5).map((expense) {
                return Dismissible(
                  key: Key(expense.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmer'),
                          content: const Text('Supprimer cette dépense ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    _deleteExpense(expense.id!);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.shopping_bag,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${expense.category} • ${Helpers.formatDate(expense.date)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            Helpers.formatCurrency(expense.amount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
