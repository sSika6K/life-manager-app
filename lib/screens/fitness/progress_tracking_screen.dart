import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/exercise.dart';
import '../../models/set_history.dart';
import '../../widgets/custom_card.dart';
import 'exercise_progress_detail_screen.dart';

class ProgressTrackingScreen extends StatefulWidget {
  final int userId;

  const ProgressTrackingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  List<Exercise> _exercises = [];
  Map<int, List<SetHistory>> _exerciseHistory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final exercises = await DatabaseHelper.instance.getCustomExercisesByUser(widget.userId);
    
    // Charger l'historique pour chaque exercice
    Map<int, List<SetHistory>> history = {};
    for (var exercise in exercises) {
      if (exercise.id != null) {
        final sets = await DatabaseHelper.instance.getSetHistoryByExercise(
          exercise.id!,
          limit: 50, // Dernières 50 séries
        );
        if (sets.isNotEmpty) {
          history[exercise.id!] = sets;
        }
      }
    }
    
    // Filtrer uniquement les exercices avec historique
    final exercisesWithHistory = exercises.where((e) => 
      e.id != null && history.containsKey(e.id!)
    ).toList();
    
    setState(() {
      _exercises = exercisesWithHistory;
      _exerciseHistory = history;
      _isLoading = false;
    });
  }

  double? _getLastWeight(int exerciseId) {
    final history = _exerciseHistory[exerciseId];
    if (history == null || history.isEmpty) return null;
    return history.first.weight;
  }

  double? _getMaxWeight(int exerciseId) {
    final history = _exerciseHistory[exerciseId];
    if (history == null || history.isEmpty) return null;
    
    double? max;
    for (var set in history) {
      if (set.weight != null) {
        if (max == null || set.weight! > max) {
          max = set.weight;
        }
      }
    }
    return max;
  }

  int _getTotalSets(int exerciseId) {
    final history = _exerciseHistory[exerciseId];
    return history?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de progression'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune donnée',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Commence une séance pour voir ta progression',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      final lastWeight = _getLastWeight(exercise.id!);
                      final maxWeight = _getMaxWeight(exercise.id!);
                      final totalSets = _getTotalSets(exercise.id!);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseProgressDetailScreen(
                                  exercise: exercise,
                                  history: _exerciseHistory[exercise.id!]!,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.trending_up,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (exercise.targetMuscle != null)
                                          Text(
                                            exercise.targetMuscle!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatBox(
                                      label: 'Dernier',
                                      value: lastWeight != null 
                                          ? '${lastWeight}kg' 
                                          : 'PDC',
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatBox(
                                      label: 'Record',
                                      value: maxWeight != null 
                                          ? '${maxWeight}kg' 
                                          : 'PDC',
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatBox(
                                      label: 'Séries',
                                      value: totalSets.toString(),
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
