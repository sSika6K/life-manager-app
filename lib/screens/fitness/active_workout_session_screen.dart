import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../database/database_helper.dart';
import '../../models/workout_program.dart';
import '../../models/program_exercise.dart';
import '../../models/exercise.dart';
import '../../models/workout.dart';
import '../../models/set_history.dart';
import '../../models/active_session.dart';
import '../../widgets/custom_card.dart';

class ActiveWorkoutSessionScreen extends StatefulWidget {
  final int userId;
  final WorkoutProgram program;

  const ActiveWorkoutSessionScreen({
    Key? key,
    required this.userId,
    required this.program,
  }) : super(key: key);

  @override
  State<ActiveWorkoutSessionScreen> createState() => _ActiveWorkoutSessionScreenState();
}

class _ActiveWorkoutSessionScreenState extends State<ActiveWorkoutSessionScreen> with WidgetsBindingObserver {
  List<ProgramExercise> _programExercises = [];
  Map<int, Exercise> _exercisesCache = {};
  Map<int, int> _remainingSets = {};
  Map<int, double?> _lastWeights = {};
  
  bool _isLoading = true;
  bool _isResting = false;
  int _restTimeRemaining = 0;
  Timer? _restTimer;
  
  int? _selectedExerciseId;
  int? _activeSessionId;
  DateTime? _sessionStartTime;
  final DateTime _sessionDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restTimer?.cancel();
    _saveSessionState(); // Sauvegarder avant de quitter
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveSessionState();
    }
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    
    // Vérifier s'il y a une session active existante
    final existingSession = await DatabaseHelper.instance.getActiveSession(widget.userId);
    
    final programExercises = await DatabaseHelper.instance.getProgramExercises(widget.program.id!);
    
    // Charger tous les exercices
    for (var pe in programExercises) {
      final exercise = await DatabaseHelper.instance.getExerciseById(pe.exerciseId);
      if (exercise != null) {
        _exercisesCache[pe.exerciseId] = exercise;
      }
    }
    
    if (existingSession != null && existingSession.programId == widget.program.id) {
      // Reprendre la session existante
      _remainingSets = existingSession.remainingSets;
      _selectedExerciseId = existingSession.selectedExerciseId;
      _sessionStartTime = existingSession.startTime;
      _activeSessionId = existingSession.id;
      _isResting = existingSession.isResting;
      _restTimeRemaining = existingSession.restTimeRemaining;
      
      // Reprendre le timer si nécessaire
      if (_isResting && _restTimeRemaining > 0) {
        _startRest(_restTimeRemaining);
      }
    } else {
      // Nouvelle session
      for (var pe in programExercises) {
        _remainingSets[pe.exerciseId] = pe.sets;
      }
      _sessionStartTime = DateTime.now();
      
      // Créer la session active dans la DB
      final activeSession = ActiveSession(
        userId: widget.userId,
        programId: widget.program.id!,
        startTime: _sessionStartTime!,
        remainingSets: _remainingSets,
      );
      final created = await DatabaseHelper.instance.createActiveSession(activeSession);
      _activeSessionId = created.id;
    }
    
    // Charger les derniers poids utilisés
    _lastWeights = await DatabaseHelper.instance.getLastWeightsForProgram(widget.program.id!);
    
    setState(() {
      _programExercises = programExercises;
      _isLoading = false;
    });
  }

  Future<void> _saveSessionState() async {
    if (_activeSessionId == null) return;
    
    final session = ActiveSession(
      id: _activeSessionId,
      userId: widget.userId,
      programId: widget.program.id!,
      startTime: _sessionStartTime!,
      remainingSets: _remainingSets,
      selectedExerciseId: _selectedExerciseId,
      isResting: _isResting,
      restTimeRemaining: _restTimeRemaining,
    );
    
    await DatabaseHelper.instance.updateActiveSession(session);
  }

  void _selectExercise(int exerciseId) {
    setState(() {
      _selectedExerciseId = exerciseId;
    });
    _saveSessionState();
  }

  void _showWeightDialog(ProgramExercise programExercise, int setNumber) {
    final exercise = _exercisesCache[programExercise.exerciseId];
    if (exercise == null) return;

    final weightController = TextEditingController(
      text: _lastWeights[programExercise.exerciseId]?.toString() ?? '',
    );
    final repsController = TextEditingController(
      text: programExercise.reps?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Série $setNumber/${programExercise.sets}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Poids (kg)',
                    hintText: _lastWeights[programExercise.exerciseId] != null
                        ? 'Dernier: ${_lastWeights[programExercise.exerciseId]} kg'
                        : 'Laisse vide si poids du corps',
                    prefixIcon: const Icon(Icons.fitness_center),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (programExercise.reps != null)
                  TextFormField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Répétitions effectuées *',
                      hintText: 'Objectif: ${programExercise.reps}',
                      prefixIcon: const Icon(Icons.numbers),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final weight = weightController.text.isNotEmpty
                    ? double.tryParse(weightController.text)
                    : null;
                final reps = repsController.text.isNotEmpty
                    ? int.tryParse(repsController.text)
                    : programExercise.reps;

                final setHistory = SetHistory(
                  userId: widget.userId,
                  exerciseId: programExercise.exerciseId,
                  programId: widget.program.id!,
                  date: _sessionDate,
                  setNumber: setNumber,
                  weight: weight,
                  reps: reps,
                  durationSeconds: programExercise.durationSeconds,
                );

                await DatabaseHelper.instance.createSetHistory(setHistory);

                if (weight != null) {
                  setState(() {
                    _lastWeights[programExercise.exerciseId] = weight;
                  });
                }

                Navigator.pop(context);
                
                final remaining = _remainingSets[programExercise.exerciseId]!;
                if (remaining > 1) {
                  setState(() {
                    _remainingSets[programExercise.exerciseId] = remaining - 1;
                  });
                  await _saveSessionState();
                  _startRest(programExercise.restSeconds);
                } else {
                  setState(() {
                    _remainingSets[programExercise.exerciseId] = 0;
                    _selectedExerciseId = null;
                  });
                  await _saveSessionState();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${exercise.name} terminé ! ✅'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  void _startRest(int seconds) {
    setState(() {
      _isResting = true;
      _restTimeRemaining = seconds;
    });

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_restTimeRemaining > 0) {
            _restTimeRemaining--;
          } else {
            _isResting = false;
            timer.cancel();
          }
        });
        _saveSessionState();
      } else {
        timer.cancel();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restTimeRemaining = 0;
    });
    _saveSessionState();
  }

  Future<void> _completeSet(ProgramExercise programExercise) async {
    final remaining = _remainingSets[programExercise.exerciseId]!;
    final setNumber = programExercise.sets - remaining + 1;
    _showWeightDialog(programExercise, setNumber);
  }

  bool _isSessionComplete() {
    return _remainingSets.values.every((sets) => sets == 0);
  }

  Future<void> _finishSession() async {
    final duration = DateTime.now().difference(_sessionStartTime!).inMinutes;
    
    final workout = Workout(
      userId: widget.userId,
      name: widget.program.name,
      description: 'Programme: ${widget.program.name}',
      date: DateTime.now(),
      durationMinutes: duration,
      notes: 'Séance complétée',
    );
    
    await DatabaseHelper.instance.createWorkout(workout);
    await DatabaseHelper.instance.deleteActiveSession(widget.userId);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Séance terminée !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Durée: $duration minutes',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Excellent travail ! 💪'),
            const SizedBox(height: 16),
            const Text(
              'Tes performances ont été enregistrées',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  String _formatRestTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
    return '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.name),
        actions: [
          if (_isSessionComplete())
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _finishSession,
              tooltip: 'Terminer la séance',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isResting)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                children: [
                  Text(
                    'REPOS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatRestTime(_restTimeRemaining),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _skipRest,
                    child: Text(
                      'Passer',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${_programExercises.length}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      'Exercices',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 2,
                  height: 40,
                  color: Theme.of(context).colorScheme.outline,
                ),
                Column(
                  children: [
                    Text(
                      '${_remainingSets.values.where((s) => s == 0).length}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      'Terminés',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _programExercises.length,
              itemBuilder: (context, index) {
                final programExercise = _programExercises[index];
                final exercise = _exercisesCache[programExercise.exerciseId];
                final remainingSets = _remainingSets[programExercise.exerciseId] ?? 0;
                final isCompleted = remainingSets == 0;
                final isSelected = _selectedExerciseId == programExercise.exerciseId;
                final lastWeight = _lastWeights[programExercise.exerciseId];

                if (exercise == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomCard(
                    onTap: isCompleted || _isResting
                        ? null
                        : () => _selectExercise(programExercise.exerciseId),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green
                                    : isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                                    : Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
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
                                    exercise.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
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
                                  if (isSelected && lastWeight != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.orange),
                                      ),
                                      child: Text(
                                        'Dernière fois: ${lastWeight}kg',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.repeat,
                              label: '${programExercise.sets} séries',
                            ),
                            const SizedBox(width: 8),
                            if (programExercise.reps != null)
                              _InfoChip(
                                icon: Icons.numbers,
                                label: '${programExercise.reps} reps',
                              ),
                            if (programExercise.durationSeconds != null)
                              _InfoChip(
                                icon: Icons.timer,
                                label: '${programExercise.durationSeconds}s',
                              ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.hourglass_empty,
                              label: '${programExercise.restSeconds}s',
                            ),
                          ],
                        ),
                        
                        if (!isCompleted && isSelected) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$remainingSets',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'série${remainingSets > 1 ? 's' : ''} restante${remainingSets > 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _isResting
                                    ? null
                                    : () => _completeSet(programExercise),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Icon(Icons.check, size: 28),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

// Boutons de fin de séance
Padding(
  padding: const EdgeInsets.all(16),
  child: _isSessionComplete()
      ? ElevatedButton.icon(
          onPressed: _finishSession,
          icon: const Icon(Icons.check_circle),
          label: const Text('Terminer la séance'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            minimumSize: const Size(double.infinity, 56),
          ),
        )
      : OutlinedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Terminer la séance ?'),
                content: const Text(
                  'Tu n\'as pas terminé tous les exercices. Veux-tu quand même terminer la séance ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Continuer'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Terminer quand même'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              _finishSession();
            }
          },
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('Terminer maintenant'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: Colors.orange, width: 2),
            foregroundColor: Colors.orange,
          ),
        ),
),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
