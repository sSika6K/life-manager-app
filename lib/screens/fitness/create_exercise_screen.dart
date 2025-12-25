import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/exercise.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';

class CreateExerciseScreen extends StatefulWidget {
  final int userId;

  const CreateExerciseScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _durationController = TextEditingController();
  final _restController = TextEditingController(text: '60');
  
  String _selectedCategory = AppConstants.exerciseCategories[0];
  bool _isLoading = false;
  bool _isDurationBased = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _restController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final exercise = Exercise(
        userId: widget.userId,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        sets: int.tryParse(_setsController.text),
        reps: _isDurationBased ? null : int.tryParse(_repsController.text),
        durationSeconds: _isDurationBased ? int.tryParse(_durationController.text) : null,
        restSeconds: int.tryParse(_restController.text),
      );

      await DatabaseHelper.instance.createCustomExercise(exercise);

      if (!mounted) return;
      
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercice créé avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un exercice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de l\'exercice',
                  prefixIcon: const Icon(Icons.fitness_center),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Catégorie
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: AppConstants.exerciseCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedCategory = newValue);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Switch durée ou répétitions
              SwitchListTile(
                title: const Text('Basé sur la durée (ex: planche)'),
                subtitle: Text(_isDurationBased 
                    ? 'Exercice avec durée en secondes' 
                    : 'Exercice avec répétitions'),
                value: _isDurationBased,
                onChanged: (bool value) {
                  setState(() => _isDurationBased = value);
                },
              ),
              const SizedBox(height: 16),

              // Séries
              TextFormField(
                controller: _setsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nombre de séries',
                  prefixIcon: const Icon(Icons.repeat),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Entrez le nombre de séries';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Répétitions OU Durée
              if (!_isDurationBased)
                TextFormField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Répétitions par série',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entrez le nombre de répétitions';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Nombre invalide';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Durée par série (secondes)',
                    prefixIcon: const Icon(Icons.timer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Entrez la durée';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Durée invalide';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),

              // Temps de repos
              TextFormField(
                controller: _restController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Temps de repos (secondes)',
                  prefixIcon: const Icon(Icons.hourglass_empty),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Temps de repos entre chaque série',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Entrez le temps de repos';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Temps invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Bouton créer
              CustomButton(
                text: 'Créer l\'exercice',
                onPressed: _saveExercise,
                isLoading: _isLoading,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
