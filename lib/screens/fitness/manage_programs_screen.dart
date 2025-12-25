import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/workout_program.dart';
import '../../models/program_exercise.dart';
import '../../models/exercise.dart';
import '../../widgets/custom_card.dart';
import '../../utils/constants.dart';
import 'program_detail_screen.dart';

class ManageProgramsScreen extends StatefulWidget {
  final int userId;

  const ManageProgramsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ManageProgramsScreen> createState() => _ManageProgramsScreenState();
}

class _ManageProgramsScreenState extends State<ManageProgramsScreen> {
  List<WorkoutProgram> _programs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    setState(() => _isLoading = true);
    final programs = await DatabaseHelper.instance.getWorkoutProgramsByUser(widget.userId);
    setState(() {
      _programs = programs;
      _isLoading = false;
    });
  }

  Future<void> _showCreateProgramDialog() async {
    final nameController = TextEditingController();
    List<String> selectedMuscles = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nouveau programme'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du programme',
                        hintText: 'Ex: PUSH, PULL, LEGS...',
                        prefixIcon: Icon(Icons.list_alt),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Muscles ciblés :',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.muscleGroups.map((muscle) {
                        final isSelected = selectedMuscles.contains(muscle);
                        return FilterChip(
                          label: Text(muscle),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedMuscles.add(muscle);
                              } else {
                                selectedMuscles.remove(muscle);
                              }
                            });
                          },
                        );
                      }).toList(),
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
                      return;
                    }
                    if (selectedMuscles.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sélectionne au moins un muscle')),
                      );
                      return;
                    }

                    final program = WorkoutProgram(
                      userId: widget.userId,
                      name: nameController.text.trim().toUpperCase(),
                      targetMuscles: selectedMuscles,
                    );

                    final createdProgram = await DatabaseHelper.instance.createWorkoutProgram(program);
                    Navigator.pop(context);
                    
                    // Ouvrir directement l'écran de détail pour ajouter des exercices
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgramDetailScreen(
                          userId: widget.userId,
                          programId: createdProgram.id!,
                        ),
                      ),
                    );
                    
                    _loadPrograms();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Programme créé !')),
                    );
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteProgram(WorkoutProgram program) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text('Supprimer le programme "${program.name}" ?'),
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

    if (confirm == true && program.id != null) {
      await DatabaseHelper.instance.deleteWorkoutProgram(program.id!);
      _loadPrograms();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Programme supprimé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes programmes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _programs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun programme',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crée ton premier programme d\'entraînement',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showCreateProgramDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Créer un programme'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPrograms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _programs.length,
                    itemBuilder: (context, index) {
                      final program = _programs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgramDetailScreen(
                                  userId: widget.userId,
                                  programId: program.id!,
                                ),
                              ),
                            );
                            _loadPrograms();
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
                                      Icons.fitness_center,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      program.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteProgram(program),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: program.targetMuscles.map((muscle) {
                                  return Chip(
                                    label: Text(
                                      muscle,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                              FutureBuilder<List<ProgramExercise>>(
                                future: DatabaseHelper.instance.getProgramExercises(program.id!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final exerciseCount = snapshot.data!.length;
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.format_list_numbered,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$exerciseCount exercice${exerciseCount > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.chevron_right, color: Colors.grey),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProgramDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
