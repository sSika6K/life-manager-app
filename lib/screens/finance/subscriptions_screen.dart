import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/subscription.dart';
import '../../widgets/custom_card.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class SubscriptionsScreen extends StatefulWidget {
  final int userId;

  const SubscriptionsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _isLoading = true);
    final subs = await DatabaseHelper.instance.getSubscriptionsByUser(widget.userId);
    setState(() {
      _subscriptions = subs;
      _isLoading = false;
    });
  }

  Future<void> _deleteSubscription(int id) async {
    await DatabaseHelper.instance.deleteSubscription(id);
    _loadSubscriptions();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abonnement supprimé')),
    );
  }

  void _showAddSubscriptionDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedFrequency = AppConstants.subscriptionFrequencies[0];
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nouvel abonnement'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom (ex: Netflix)',
                        prefixIcon: Icon(Icons.subscriptions),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Montant (€)',
                        prefixIcon: Icon(Icons.euro),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Fréquence',
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      items: AppConstants.subscriptionFrequencies.map((String freq) {
                        return DropdownMenuItem<String>(
                          value: freq,
                          child: Text(freq),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() => selectedFrequency = newValue);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de début',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(Helpers.formatDate(selectedDate)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || amountController.text.isEmpty) {
                      return;
                    }

                    final subscription = Subscription(
                      userId: widget.userId,
                      name: nameController.text.trim(),
                      amount: double.parse(amountController.text),
                      frequency: selectedFrequency,
                      startDate: selectedDate,
                    );

                    await DatabaseHelper.instance.createSubscription(subscription);
                    Navigator.pop(context);
                    _loadSubscriptions();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abonnement ajouté')),
                    );
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculateTotalMonthlyCost() {
    double total = 0;
    for (var sub in _subscriptions) {
      if (sub.isActive) {
        total += Helpers.calculateMonthlyCost(sub.amount, sub.frequency);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activeSubs = _subscriptions.where((s) => s.isActive).toList();
    final totalMonthlyCost = _calculateTotalMonthlyCost();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSubscriptionDialog,
          ),
        ],
      ),
      body: _subscriptions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_membership_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun abonnement',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddSubscriptionDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un abonnement'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSubscriptions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Résumé du coût mensuel
                  CustomCard(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Column(
                      children: [
                        Text(
                          'Coût mensuel total',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Helpers.formatCurrency(totalMonthlyCost),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${activeSubs.length} abonnement${activeSubs.length > 1 ? 's' : ''} actif${activeSubs.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Mes abonnements',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ..._subscriptions.map((sub) => _buildSubscriptionCard(sub)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubscriptionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription sub) {
    final monthlyCost = Helpers.calculateMonthlyCost(sub.amount, sub.frequency);

    return Dismissible(
      key: Key(sub.id.toString()),
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
              content: const Text('Supprimer cet abonnement ?'),
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
        _deleteSubscription(sub.id!);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${Helpers.formatCurrency(sub.amount)} / ${sub.frequency}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sub.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sub.isActive ? 'Actif' : 'Inactif',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coût mensuel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        Helpers.formatCurrency(monthlyCost),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Début',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        Helpers.formatDate(sub.startDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
