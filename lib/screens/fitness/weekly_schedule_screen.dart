import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/weekly_schedule.dart';
import '../../models/workout_program.dart';
import '../../widgets/custom_card.dart';
import '../../utils/constants.dart';
import 'active_workout_session_screen.dart';

class WeeklyScheduleScreen extends StatefulWidget {
  final int userId;

  const WeeklyScheduleScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  Map<int, List<WeeklySchedule>> _scheduleByDay = {};
  List<WorkoutProgram> _programs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final schedules = await DatabaseHelper.instance.getWeeklySchedule(widget.userId);
    final programs = await DatabaseHelper.instance.getWorkoutProgramsByUser(widget.userId);
    
    // Organiser par jour
    Map<int, List<WeeklySchedule>> scheduleMap = {};
    for (int i = 1; i <= 7; i++) {
      scheduleMap[i] = schedules.where((s) => s.dayOfWeek == i).toList();
    }
    
    setState(() {
      _scheduleByDay = scheduleMap;
      _programs = programs;
      _isLoading = false;
    });
  }

  Future<void> _addProgramToDay(int dayOfWeek) async {
    if (_programs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crée d\'abord un programme dans "Mes programmes"'),
        ),
      );
      return;
    }

    WorkoutProgram? selectedProgram;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Ajouter une séance - ${AppConstants.daysOfWeek[dayOfWeek - 1]}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sélectionne un programme :'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WorkoutProgram>(
                    value: selectedProgram,
                    decoration: const InputDecoration(
                      labelText: 'Programme',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    items: _programs.map((WorkoutProgram program) {
                      return DropdownMenuItem<WorkoutProgram>(
                        value: program,
                        child: Text(program.name),
                      );
                    }).toList(),
                    onChanged: (WorkoutProgram? newValue) {
                      setDialogState(() => selectedProgram = newValue);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedProgram == null) {
                      return;
                    }

                    final schedule = WeeklySchedule(
                      userId: widget.userId,
                      programId: selectedProgram!.id!,
                      dayOfWeek: dayOfWeek,
                    );

                    await DatabaseHelper.instance.addToWeeklySchedule(schedule);
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Séance ajoutée à l\'emploi du temps !')),
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

  Future<void> _deleteSchedule(WeeklySchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Retirer cette séance de l\'emploi du temps ?'),
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

    if (confirm == true && schedule.id != null) {
      await DatabaseHelper.instance.deleteFromWeeklySchedule(schedule.id!);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Séance retirée')),
      );
    }
  }

  Future<void> _startWorkoutSession(WeeklySchedule schedule) async {
    final program = await DatabaseHelper.instance.getWorkoutProgramById(schedule.programId);
    if (program == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutSessionScreen(
          userId: widget.userId,
          program: program,
        ),
      ),
    );
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
        title: const Text('Emploi du temps'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 7,
          itemBuilder: (context, index) {
            final dayOfWeek = index + 1;
            final dayName = AppConstants.daysOfWeek[index];
            final schedulesForDay = _scheduleByDay[dayOfWeek] ?? [];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CustomCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête du jour
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const Spacer(),
                          if (schedulesForDay.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${schedulesForDay.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Séances du jour
                    if (schedulesForDay.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Aucune séance',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _addProgramToDay(dayOfWeek),
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter une séance'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...schedulesForDay.map((schedule) {
                        return FutureBuilder<WorkoutProgram?>(
                          future: DatabaseHelper.instance.getWorkoutProgramById(schedule.programId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const SizedBox.shrink();
                            }

                            final program = snapshot.data!;
                            return Container(
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                program.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                              onPressed: () => _deleteSchedule(schedule),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: program.targetMuscles.map((muscle) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                muscle,
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  InkWell(
                                    onTap: () => _startWorkoutSession(schedule),
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(12),
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.play_circle_filled,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Lancer la séance',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    
                    // Bouton ajouter si des séances existent déjà
                    if (schedulesForDay.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () => _addProgramToDay(dayOfWeek),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Ajouter une autre séance'),
                          ),
                        ),
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
