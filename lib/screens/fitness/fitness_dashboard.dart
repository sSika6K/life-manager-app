import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../widgets/custom_card.dart';
import 'weekly_schedule_screen.dart';
import 'manage_programs_screen.dart';
import 'manage_exercises_screen.dart';
import 'manage_machines_screen.dart';
import 'timer_tools_screen.dart';
import 'workout_list_screen.dart';
import 'progress_tracking_screen.dart';

class FitnessDashboard extends StatefulWidget {
  final int userId;

  const FitnessDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  State<FitnessDashboard> createState() => _FitnessDashboardState();
}

class _FitnessDashboardState extends State<FitnessDashboard> {
  int _programCount = 0;
  int _exerciseCount = 0;
  int _machineCount = 0;
  int _workoutCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    final programs = await DatabaseHelper.instance.getWorkoutProgramsByUser(widget.userId);
    final exercises = await DatabaseHelper.instance.getCustomExercisesByUser(widget.userId);
    final machines = await DatabaseHelper.instance.getMachinesByUser(widget.userId);
    final workouts = await DatabaseHelper.instance.getWorkoutsByUser(widget.userId);
    
    setState(() {
      _programCount = programs.length;
      _exerciseCount = exercises.length;
      _machineCount = machines.length;
      _workoutCount = workouts.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            CustomCard(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Entraînement',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gère tes programmes et séances',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.list_alt,
                    label: 'Programmes',
                    value: _programCount.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.fitness_center,
                    label: 'Exercices',
                    value: _exerciseCount.toString(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.sports_gymnastics,
                    label: 'Machines',
                    value: _machineCount.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.history,
                    label: 'Séances',
                    value: _workoutCount.toString(),
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions principales
            const Text(
              'Actions rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Emploi du temps
            _ActionButton(
              icon: Icons.calendar_today,
              label: 'Emploi du temps',
              subtitle: 'Planifie tes séances',
              color: Colors.blue,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklyScheduleScreen(userId: widget.userId),
                  ),
                );
                _loadStats();
              },
            ),
            const SizedBox(height: 12),

            // Programmes
            _ActionButton(
              icon: Icons.list_alt,
              label: 'Mes programmes',
              subtitle: 'Créer et gérer les programmes',
              color: Colors.green,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageProgramsScreen(userId: widget.userId),
                  ),
                );
                _loadStats();
              },
            ),
            const SizedBox(height: 12),


            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.show_chart,
              label: 'Suivi de progression',
              subtitle: 'Graphiques et statistiques',
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressTrackingScreen(userId: widget.userId),
                  ),
                );
              },
            ),


            // Exercices
            _ActionButton(
              icon: Icons.fitness_center,
              label: 'Mes exercices',
              subtitle: 'Créer et gérer les exercices',
              color: Colors.orange,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageExercisesScreen(userId: widget.userId),
                  ),
                );
                _loadStats();
              },
            ),
            const SizedBox(height: 12),

            // Machines
            _ActionButton(
              icon: Icons.sports_gymnastics,
              label: 'Mes machines',
              subtitle: 'Ajouter des machines avec photos',
              color: Colors.purple,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageMachinesScreen(userId: widget.userId),
                  ),
                );
                _loadStats();
              },
            ),
            const SizedBox(height: 24),

            // Outils
            const Text(
              'Outils',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TimerToolsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.timer),
                    label: const Text('Chrono/Timer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutListScreen(userId: widget.userId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Historique'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
