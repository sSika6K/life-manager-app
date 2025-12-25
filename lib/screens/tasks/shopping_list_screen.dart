import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/shopping_item.dart';
import '../../widgets/custom_card.dart';
import '../../utils/constants.dart';

class ShoppingListScreen extends StatefulWidget {
  final int userId;

  const ShoppingListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await DatabaseHelper.instance.getShoppingItemsByUser(widget.userId);
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _toggleItemPurchased(ShoppingItem item) async {
    final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
    await DatabaseHelper.instance.updateShoppingItem(updatedItem);
    _loadItems();
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteShoppingItem(id);
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Article supprimé')),
    );
  }

  Future<void> _clearPurchasedItems() async {
    final purchasedItems = _items.where((item) => item.isPurchased).toList();
    for (var item in purchasedItems) {
      await DatabaseHelper.instance.deleteShoppingItem(item.id!);
    }
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${purchasedItems.length} article(s) supprimé(s)')),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedCategory = AppConstants.shoppingCategories[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nouvel article'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'article',
                        prefixIcon: Icon(Icons.shopping_basket),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.shoppingCategories.map((String category) {
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
                    if (nameController.text.isEmpty) {
                      return;
                    }

                    final item = ShoppingItem(
                      userId: widget.userId,
                      name: nameController.text.trim(),
                      category: selectedCategory,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                    );

                    await DatabaseHelper.instance.createShoppingItem(item);
                    Navigator.pop(context);
                    _loadItems();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Article ajouté')),
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

    final notPurchased = _items.where((item) => !item.isPurchased).toList();
    final purchased = _items.where((item) => item.isPurchased).toList();

    // Grouper par catégorie
    Map<String, List<ShoppingItem>> itemsByCategory = {};
    for (var item in notPurchased) {
      if (!itemsByCategory.containsKey(item.category)) {
        itemsByCategory[item.category] = [];
      }
      itemsByCategory[item.category]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste de courses'),
        actions: [
          if (purchased.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Effacer les articles achetés',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmer'),
                      content: Text('Supprimer ${purchased.length} article(s) acheté(s) ?'),
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
                if (confirm == true) {
                  _clearPurchasedItems();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Liste de courses vide',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddItemDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un article'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Résumé
                  CustomCard(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${notPurchased.length}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'À acheter',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 2,
                          height: 40,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.3),
                        ),
                        Column(
                          children: [
                            Text(
                              '${purchased.length}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Achetés',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Articles à acheter (par catégorie)
                  if (notPurchased.isNotEmpty) ...[
                    const Text(
                      'À acheter',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...itemsByCategory.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          ...entry.value.map((item) => _buildShoppingItem(item)),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ],

                  // Articles achetés
                  if (purchased.isNotEmpty) ...[
                    const Text(
                      'Achetés',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...purchased.map((item) => _buildShoppingItem(item)),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShoppingItem(ShoppingItem item) {
    return Dismissible(
      key: Key(item.id.toString()),
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
      onDismissed: (direction) {
        _deleteItem(item.id!);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: CustomCard(
          child: Row(
            children: [
              Checkbox(
                value: item.isPurchased,
                onChanged: (bool? value) {
                  _toggleItemPurchased(item);
                },
              ),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                    color: item.isPurchased
                        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                        : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'x${item.quantity}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
