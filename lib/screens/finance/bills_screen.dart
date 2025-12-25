import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/bill.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class BillsScreen extends StatefulWidget {
  final int userId;

  const BillsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  List<Bill> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    final bills = await DatabaseHelper.instance.getBillsByUser(widget.userId);
    setState(() {
      _bills = bills;
      _isLoading = false;
    });
  }

  Future<void> _togglePaid(Bill bill) async {
    final updatedBill = bill.copyWith(isPaid: !bill.isPaid);
    await DatabaseHelper.instance.updateBill(updatedBill);
    _loadBills();
  }

  Future<void> _deleteBill(int id) async {
    await DatabaseHelper.instance.deleteBill(id);
    _loadBills();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facture supprimée')),
    );
  }

  void _showAddBillDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = AppConstants.billCategories[0];
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nouvelle facture'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.receipt),
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
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.billCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() => selectedCategory = newValue);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date d\'échéance',
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

                    final bill = Bill(
                      userId: widget.userId,
                      name: nameController.text.trim(),
                      amount: double.parse(amountController.text),
                      category: selectedCategory,
                      dueDate: selectedDate,
                    );

                    await DatabaseHelper.instance.createBill(bill);
                    Navigator.pop(context);
                    _loadBills();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Facture ajoutée')),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final unpaidBills = _bills.where((b) => !b.isPaid).toList();
    final paidBills = _bills.where((b) => b.isPaid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Factures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBillDialog,
          ),
        ],
      ),
      body: _bills.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune facture',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddBillDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une facture'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadBills,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (unpaidBills.isNotEmpty) ...[
                    const Text(
                      'À payer',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...unpaidBills.map((bill) => _buildBillCard(bill)),
                    const SizedBox(height: 24),
                  ],
                  if (paidBills.isNotEmpty) ...[
                    const Text(
                      'Payées',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...paidBills.map((bill) => _buildBillCard(bill)),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBillDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBillCard(Bill bill) {
    final daysUntil = Helpers.daysUntil(bill.dueDate);
    final isOverdue = Helpers.isPastDue(bill.dueDate) && !bill.isPaid;

    return Dismissible(
      key: Key(bill.id.toString()),
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
              content: const Text('Supprimer cette facture ?'),
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
        _deleteBill(bill.id!);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: CustomCard(
          child: Row(
            children: [
              Checkbox(
                value: bill.isPaid,
                onChanged: (bool? value) {
                  _togglePaid(bill);
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bill.category} • ${Helpers.formatDate(bill.dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (isOverdue)
                      Text(
                        'EN RETARD !',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (!bill.isPaid && daysUntil <= 7)
                      Text(
                        'Dans $daysUntil jour${daysUntil > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                Helpers.formatCurrency(bill.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: bill.isPaid ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
