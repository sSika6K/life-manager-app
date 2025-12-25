import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database_helper.dart';
import '../../models/user.dart';
import '../../widgets/stat_card.dart';
import '../../utils/helpers.dart';
import '../finance/finance_dashboard.dart';
import '../fitness/fitness_dashboard.dart';
import '../tasks/tasks_screen.dart';
import '../tasks/shopping_list_screen.dart';
import '../tasks/goals_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final Function(String) onThemeChanged;

  const HomeScreen({
    Key? key,
    required this.userId,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 0;

  // Statistiques
  double _totalExpenses = 0;
  int _unpaidBills = 0;
  int _workoutsThisWeek = 0;
  int _pendingTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  Future<void> _loadUserData() async {
    final user = await DatabaseHelper.instance.getUserById(widget.userId);
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  Future<void> _loadStats() async {
    // Charger les dépenses du mois
    final expenses = await DatabaseHelper.instance.getExpensesByUser(widget.userId);
    final now = DateTime.now();
    final thisMonthExpenses = expenses.where((e) => 
      e.date.year == now.year && e.date.month == now.month
    ).toList();
    
    double totalExpenses = 0;
    for (var expense in thisMonthExpenses) {
      totalExpenses += expense.amount;
    }

    // Charger les factures impayées
    final bills = await DatabaseHelper.instance.getBillsByUser(widget.userId);
    final unpaidBills = bills.where((b) => !b.isPaid).length;

    // Charger les workouts de la semaine
    final workouts = await DatabaseHelper.instance.getWorkoutsByUser(widget.userId);
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final workoutsThisWeek = workouts.where((w) => w.date.isAfter(oneWeekAgo)).length;

    // Charger les tâches en attente
    final tasks = await DatabaseHelper.instance.getTasksByUser(widget.userId);
    final pendingTasks = tasks.where((t) => !t.isCompleted).length;

    setState(() {
      _totalExpenses = totalExpenses;
      _unpaidBills = unpaidBills;
      _workoutsThisWeek = workoutsThisWeek;
      _pendingTasks = pendingTasks;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_theme');

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadStats();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de bienvenue
            Text(
              'Bonjour, ${_currentUser?.username ?? 'Héros'} !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plus Ultra ! ${_getGreeting()}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Cartes de statistiques
            Text(
              'Vue d\'ensemble',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  title: 'Dépenses ce mois',
                  value: Helpers.formatCurrency(_totalExpenses),
                  icon: Icons.euro,
                  color: Colors.red,
                  onTap: () => _onItemTapped(1),
                ),
                StatCard(
                  title: 'Factures à payer',
                  value: '$_unpaidBills',
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                  onTap: () => _onItemTapped(1),
                ),
                StatCard(
                  title: 'Séances cette semaine',
                  value: '$_workoutsThisWeek',
                  icon: Icons.fitness_center,
                  color: Colors.green,
                  onTap: () => _onItemTapped(2),
                ),
                StatCard(
                  title: 'Tâches en cours',
                  value: '$_pendingTasks',
                  icon: Icons.task_alt,
                  color: Colors.blue,
                  onTap: () => _onItemTapped(3),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions rapides
            Text(
              'Actions rapides',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildQuickActionCard(
              'Ajouter une dépense',
              Icons.add_shopping_cart,
              Colors.red,
              () => _onItemTapped(1),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              'Nouvelle séance',
              Icons.fitness_center,
              Colors.green,
              () => _onItemTapped(2),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              'Créer une tâche',
              Icons.add_task,
              Colors.blue,
              () => _onItemTapped(3),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              'Liste de courses',
              Icons.shopping_basket,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShoppingListScreen(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonne journée !';
    if (hour < 18) return 'Bon après-midi !';
    return 'Bonne soirée !';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      _buildDashboard(),
      FinanceDashboard(userId: widget.userId),
      FitnessDashboard(userId: widget.userId),
      TasksScreen(userId: widget.userId),
      SettingsScreen(
        userId: widget.userId,
        currentTheme: _currentUser?.theme ?? 'Deku',
        onThemeChanged: widget.onThemeChanged,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadStats();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données actualisées')),
              );
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Sport',
          ),
          NavigationDestination(
            icon: Icon(Icons.task),
            label: 'Tâches',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
