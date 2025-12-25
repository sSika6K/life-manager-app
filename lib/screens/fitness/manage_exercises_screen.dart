import 'package:flutter/material.dart';
import 'dart:io';
import '../../database/database_helper.dart';
import '../../models/exercise.dart';
import '../../models/machine.dart';
import '../../widgets/custom_card.dart';
import '../../utils/constants.dart';

class ManageExercisesScreen extends StatefulWidget {
  final int userId;

  const ManageExercisesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ManageExercisesScreen> createState() => _ManageExercisesScreenState();
}

class _ManageExercisesScreenState extends State<ManageExercisesScreen> {
  List<Exercise> _exercises = [];
  List<Machine> _machines = [];
  bool _isLoading = true;
  String? _filterMuscle;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final exercises = await DatabaseHelper.instance.getCustomExercisesByUser(widget.userId);
    final machines = await DatabaseHelper.instance.getMachinesByUser(widget.userId);
    setState(() {
      _exercises = exercises;
      _machines = machines;
      _isLoading = false;
    });
  }

  List<Exercise> get _filteredExercises {
    if (_filterMuscle == null) return _exercises;
    return _exercises.where((e) => e.targetMuscle == _filterMuscle).toList();
  }

  Future<void> _showAddEditExerciseDialog({Exercise? exercise}) async {
    final nameController = TextEditingController(text: exercise?.name ?? '');
    final descriptionController = TextEditingController(text: exercise?.description ?? '');
    String? selectedMuscle = exercise?.targetMuscle;
    int? selectedMachineId = exercise?.machineId;
    final isEditing = exercise != null;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Modifier l\'exercice' : 'Nouvel exercice'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'exercice *',
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMuscle,
                      decoration: const InputDecoration(
                        labelText: 'Muscle ciblé',
                        prefixIcon: Icon(Icons.accessibility_new),
                      ),
                      items: AppConstants.muscleGroups.map((String muscle) {
                        return DropdownMenuItem<String>(
                          value: muscle,
                          child: Text(muscle),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() => selectedMuscle = newValue);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedMachineId,
                      decoration: const InputDecoration(
                        labelText: 'Machine (optionnel)',
                        prefixIcon: Icon(Icons.sports_gymnastics),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Aucune machine'),
                        ),
                        ..._machines.map((Machine machine) {
                          return DropdownMenuItem<int>(
                            value: machine.id,
                            child: Text(machine.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (int? newValue) {
                        setDialogState(() => selectedMachineId = newValue);
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
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Le nom est obligatoire')),
                      );
                      return;
                    }

                    final newExercise = Exercise(
                      id: exercise?.id,
                      userId: widget.userId,
                      name: nameController.text.trim(),
                      category: 'Personnalisé',
                      description: descriptionController.text.trim().isEmpty 
                          ? 'Aucune description' 
                          : descriptionController.text.trim(),
                      targetMuscle: selectedMuscle,
                      machineId: selectedMachineId,
                    );

                    if (isEditing) {
                      await DatabaseHelper.instance.updateExercise(newExercise);
                    } else {
                      await DatabaseHelper.instance.createCustomExercise(newExercise);
                    }
                    
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Exercice modifié !' : 'Exercice créé !')),
                    );
                  },
                  child: Text(isEditing ? 'Modifier' : 'Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text('Supprimer "${exercise.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && exercise.id != null) {
      await DatabaseHelper.instance.deleteExercise(exercise.id!);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercice supprimé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes exercices'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String? value) {
              setState(() => _filterMuscle = value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: null,
                  child: Text('Tous les muscles'),
                ),
                ...AppConstants.muscleGroups.map((String muscle) {
                  return PopupMenuItem<String>(
                    value: muscle,
                    child: Text(muscle),
                  );
                }).toList(),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exercises.isEmpty
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
                        'Commence par créer tes exercices',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditExerciseDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Créer un exercice'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_filterMuscle != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.filter_list,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Filtre: $_filterMuscle',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => setState(() => _filterMuscle = null),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CustomCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            exercise.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showAddEditExerciseDialog(exercise: exercise),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteExercise(exercise),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (exercise.description != 'Aucune description')
                                      Text(
                                        exercise.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (exercise.targetMuscle != null)
                                          Chip(
                                            label: Text(exercise.targetMuscle!),
                                            avatar: const Icon(Icons.accessibility_new, size: 16),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                          ),
                                        if (exercise.machineId != null)
                                          FutureBuilder<Machine?>(
                                            future: DatabaseHelper.instance
                                                .getMachineById(exercise.machineId!),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData && snapshot.data != null) {
                                                return Chip(
                                                  label: Text(snapshot.data!.name),
                                                  avatar: const Icon(Icons.sports_gymnastics, size: 16),
                                                  backgroundColor: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer,
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
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
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditExerciseDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
