import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/workout_program.dart';
import '../../models/program_exercise.dart';
import '../../models/exercise.dart';
import '../../widgets/custom_card.dart';

class ProgramDetailScreen extends StatefulWidget {
  final int userId;
  final int programId;

  const ProgramDetailScreen({
    Key? key,
    required this.userId,
    required this.programId,
  }) : super(key: key);

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  WorkoutProgram? _program;
  List<ProgramExercise> _programExercises = [];
  List<Exercise> _availableExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final program = await DatabaseHelper.instance.getWorkoutProgramById(widget.programId);
    final programExercises = await DatabaseHelper.instance.getProgramExercises(widget.programId);
    final exercises = await DatabaseHelper.instance.getCustomExercisesByUser(widget.userId);
    
    setState(() {
      _program = program;
      _programExercises = programExercises;
      _availableExercises = exercises;
      _isLoading = false;
    });
  }

  Future<void> _showAddExerciseDialog() async {
    if (_availableExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crée d\'abord des exercices dans "Mes exercices"'),
        ),
      );
      return;
    }

    Exercise? selectedExercise;
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final restController = TextEditingController(text: '90');
    bool isDurationBased = false;
    final durationController = TextEditingController(text: '30');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ajouter un exercice'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Exercise>(
                      value: selectedExercise,
                      decoration: const InputDecoration(
                        labelText: 'Exercice',
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      items: _availableExercises.map((Exercise exercise) {
                        return DropdownMenuItem<Exercise>(
                          value: exercise,
                          child: Text(exercise.name),
                        );
                      }).toList(),
                      onChanged: (Exercise? newValue) {
                        setDialogState(() => selectedExercise = newValue);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de séries',
                        prefixIcon: Icon(Icons.repeat),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Basé sur la durée'),
                      subtitle: Text(isDurationBased ? 'Durée en secondes' : 'Répétitions'),
                      value: isDurationBased,
                      onChanged: (bool value) {
                        setDialogState(() => isDurationBased = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    if (isDurationBased)
                      TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Durée par série (secondes)',
                          prefixIcon: Icon(Icons.timer),
                        ),
                      )
                    else
                      TextField(
                        controller: repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Répétitions par série',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: restController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Temps de repos (secondes)',
                        prefixIcon: Icon(Icons.hourglass_empty),
                        helperText: 'Temps entre chaque série',
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
                ElevatedButton(
                  onPressed: () async {
                    if (selectedExercise == null) {
                      return;
                    }

                    final programExercise = ProgramExercise(
                      programId: widget.programId,
                      exerciseId: selectedExercise!.id!,
                      orderIndex: _programExercises.length,
                      sets: int.tryParse(setsController.text) ?? 3,
                      reps: isDurationBased ? null : int.tryParse(repsController.text),
                      durationSeconds: isDurationBased ? int.tryParse(durationController.text) : null,
                      restSeconds: int.tryParse(restController.text) ?? 90,
                    );

                    await DatabaseHelper.instance.addExerciseToProgram(programExercise);
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exercice ajouté au programme !')),
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

  Future<void> _deleteProgramExercise(ProgramExercise programExercise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Retirer cet exercice du programme ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Retirer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && programExercise.id != null) {
      await DatabaseHelper.instance.deleteProgramExercise(programExercise.id!);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercice retiré')),
      );
    }
  }

  Future<void> _reorderExercise(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = _programExercises.removeAt(oldIndex);
    _programExercises.insert(newIndex, item);

    // Mettre à jour l'ordre dans la BDD
    for (int i = 0; i < _programExercises.length; i++) {
      final updated = ProgramExercise(
        id: _programExercises[i].id,
        programId: _programExercises[i].programId,
        exerciseId: _programExercises[i].exerciseId,
        orderIndex: i,
        sets: _programExercises[i].sets,
        reps: _programExercises[i].reps,
        durationSeconds: _programExercises[i].durationSeconds,
        restSeconds: _programExercises[i].restSeconds,
      );
      await DatabaseHelper.instance.updateProgramExercise(updated);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _program == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_program!.name),
      ),
      body: Column(
        children: [
          // En-tête du programme
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muscles ciblés',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _program!.targetMuscles.map((muscle) {
                    return Chip(
                      label: Text(muscle, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Liste des exercices
          Expanded(
            child: _programExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun exercice',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoute des exercices à ce programme',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _programExercises.length,
                    onReorder: _reorderExercise,
                    itemBuilder: (context, index) {
                      final programExercise = _programExercises[index];
                      return FutureBuilder<Exercise?>(
                        key: ValueKey(programExercise.id),
                        future: DatabaseHelper.instance.getExerciseById(programExercise.exerciseId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const SizedBox.shrink();
                          }

                          final exercise = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
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
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteProgramExercise(programExercise),
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
                                        label: '${programExercise.restSeconds}s repos',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExerciseDialog,
        child: const Icon(Icons.add),
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
