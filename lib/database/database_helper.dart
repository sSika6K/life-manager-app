import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/bill.dart';
import '../models/subscription.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/task.dart';
import '../models/shopping_item.dart';
import '../models/goal.dart';
import '../models/machine.dart';
import '../models/workout_program.dart';
import '../models/program_exercise.dart';
import '../models/weekly_schedule.dart';
import '../models/active_session.dart';
import '../models/set_history.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('life_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Table Users
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType,
        password $textType,
        email TEXT,
        theme TEXT DEFAULT 'Deku',
        created_at $textType
      )
    ''');

    // Table Expenses
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        user_id $intType,
        category $textType,
        amount $realType,
        description $textType,
        date $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Bills
    await db.execute('''
      CREATE TABLE bills (
        id $idType,
        user_id $intType,
        name $textType,
        amount $realType,
        due_date $textType,
        is_paid INTEGER DEFAULT 0,
        category $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Subscriptions
    await db.execute('''
      CREATE TABLE subscriptions (
        id $idType,
        user_id $intType,
        name $textType,
        amount $realType,
        frequency $textType,
        start_date $textType,
        end_date TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Machines (NOUVEAU)
    await db.execute('''
      CREATE TABLE machines (
        id $idType,
        user_id $intType,
        name $textType,
        image_path TEXT,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Exercises (MODIFIÉE)
    await db.execute('''
      CREATE TABLE exercises (
        id $idType,
        user_id INTEGER,
        name $textType,
        category $textType,
        description $textType,
        target_muscle TEXT,
        machine_id INTEGER,
        sets INTEGER,
        reps INTEGER,
        duration_seconds INTEGER,
        rest_seconds INTEGER DEFAULT 60,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (machine_id) REFERENCES machines (id) ON DELETE SET NULL
      )
    ''');

    // Table Workout Programs (NOUVEAU)
    await db.execute('''
      CREATE TABLE workout_programs (
        id $idType,
        user_id $intType,
        name $textType,
        target_muscles $textType,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Program Exercises (NOUVEAU)
    await db.execute('''
      CREATE TABLE program_exercises (
        id $idType,
        program_id $intType,
        exercise_id $intType,
        order_index $intType,
        sets $intType,
        reps INTEGER,
        duration_seconds INTEGER,
        rest_seconds INTEGER DEFAULT 90,
        FOREIGN KEY (program_id) REFERENCES workout_programs (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    // Table Weekly Schedule (NOUVEAU)
    await db.execute('''
      CREATE TABLE weekly_schedule (
        id $idType,
        user_id $intType,
        program_id $intType,
        day_of_week $intType,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (program_id) REFERENCES workout_programs (id) ON DELETE CASCADE
      )
    ''');

    // Table Active Sessions
    await db.execute('''
      CREATE TABLE active_sessions (
        id $idType,
        user_id $intType,
        program_id $intType,
        start_time $textType,
        remaining_sets TEXT,
        selected_exercise_id INTEGER,
        is_resting INTEGER DEFAULT 0,
        rest_time_remaining INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (program_id) REFERENCES workout_programs (id) ON DELETE CASCADE
      )
    ''');

    // Table Workouts (ancienne - on garde pour l'historique)
    await db.execute('''
      CREATE TABLE workouts (
        id $idType,
        user_id $intType,
        name $textType,
        description $textType,
        date $textType,
        duration_minutes $intType,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

        // Table Set History (NOUVEAU - pour le suivi des poids)
    await db.execute('''
      CREATE TABLE set_history (
        id $idType,
        user_id $intType,
        exercise_id $intType,
        program_id $intType,
        date $textType,
        set_number $intType,
        weight REAL,
        reps INTEGER,
        duration_seconds INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE,
        FOREIGN KEY (program_id) REFERENCES workout_programs (id) ON DELETE CASCADE
      )
    ''');


    // Table Tasks
    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        user_id $intType,
        title $textType,
        description TEXT,
        due_date TEXT,
        priority TEXT DEFAULT 'normal',
        is_completed INTEGER DEFAULT 0,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Shopping Items
    await db.execute('''
      CREATE TABLE shopping_items (
        id $idType,
        user_id $intType,
        name $textType,
        category $textType,
        quantity INTEGER DEFAULT 1,
        is_purchased INTEGER DEFAULT 0,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Goals
    await db.execute('''
      CREATE TABLE goals (
        id $idType,
        user_id $intType,
        title $textType,
        description $textType,
        target_date $textType,
        category $textType,
        is_completed INTEGER DEFAULT 0,
        progress INTEGER DEFAULT 0,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Table Reminders
    await db.execute('''
      CREATE TABLE reminders (
        id $idType,
        user_id $intType,
        title $textType,
        description TEXT,
        reminder_time $textType,
        is_recurring INTEGER DEFAULT 0,
        recurring_pattern TEXT,
        is_active INTEGER DEFAULT 1,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Insérer des exercices par défaut
    await _insertDefaultExercises(db);
  }

  Future<void> _insertDefaultExercises(Database db) async {
    // On n'insère plus d'exercices par défaut, l'utilisateur créera les siens
  }

  // ============ USERS ============
  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert('users', user.toMap());
    return User(
      id: id,
      username: user.username,
      password: user.password,
      email: user.email,
      theme: user.theme,
    );
  }

  Future<User?> getUser(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ============ EXPENSES ============
  Future<Expense> createExpense(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap());
    return Expense(
      id: id,
      userId: expense.userId,
      category: expense.category,
      amount: expense.amount,
      description: expense.description,
      date: expense.date,
    );
  }

  Future<List<Expense>> getExpensesByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ============ BILLS ============
  Future<Bill> createBill(Bill bill) async {
    final db = await instance.database;
    final id = await db.insert('bills', bill.toMap());
    return Bill(
      id: id,
      userId: bill.userId,
      name: bill.name,
      amount: bill.amount,
      dueDate: bill.dueDate,
      isPaid: bill.isPaid,
      category: bill.category,
    );
  }

  Future<List<Bill>> getBillsByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'bills',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'due_date ASC',
    );
    return result.map((map) => Bill.fromMap(map)).toList();
  }

  Future<int> updateBill(Bill bill) async {
    final db = await instance.database;
    return db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final db = await instance.database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  // ============ SUBSCRIPTIONS ============
  Future<Subscription> createSubscription(Subscription subscription) async {
    final db = await instance.database;
    final id = await db.insert('subscriptions', subscription.toMap());
    return Subscription(
      id: id,
      userId: subscription.userId,
      name: subscription.name,
      amount: subscription.amount,
      frequency: subscription.frequency,
      startDate: subscription.startDate,
      endDate: subscription.endDate,
      isActive: subscription.isActive,
    );
  }

  Future<List<Subscription>> getSubscriptionsByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'subscriptions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'start_date DESC',
    );
    return result.map((map) => Subscription.fromMap(map)).toList();
  }

  Future<int> updateSubscription(Subscription subscription) async {
    final db = await instance.database;
    return db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<int> deleteSubscription(int id) async {
    final db = await instance.database;
    return await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }

  // ============ WORKOUTS ============
  Future<Workout> createWorkout(Workout workout) async {
    final db = await instance.database;
    final id = await db.insert('workouts', workout.toMap());
    return Workout(
      id: id,
      userId: workout.userId,
      name: workout.name,
      description: workout.description,
      date: workout.date,
      durationMinutes: workout.durationMinutes,
      notes: workout.notes,
    );
  }

  Future<List<Workout>> getWorkoutsByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'workouts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map((map) => Workout.fromMap(map)).toList();
  }

  Future<int> deleteWorkout(int id) async {
    final db = await instance.database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // ============ CUSTOM EXERCISES ============
  Future<Exercise> createCustomExercise(Exercise exercise) async {
    final db = await instance.database;
    final id = await db.insert('exercises', exercise.toMap());
    return Exercise(
      id: id,
      userId: exercise.userId,
      name: exercise.name,
      category: exercise.category,
      description: exercise.description,
      targetMuscle: exercise.targetMuscle,
      machineId: exercise.machineId,
      sets: exercise.sets,
      reps: exercise.reps,
      durationSeconds: exercise.durationSeconds,
      restSeconds: exercise.restSeconds,
    );
  }

  Future<int> updateExercise(Exercise exercise) async {
  final db = await instance.database;
  return db.update(
    'exercises',
    exercise.toMap(),
    where: 'id = ?',
    whereArgs: [exercise.id],
  );
  }


  Future<List<Exercise>> getCustomExercisesByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'exercises',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'category ASC, name ASC',
    );
    return result.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<Exercise?> getExerciseById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Exercise.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteExercise(int id) async {
    final db = await instance.database;
    return await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  // ============ TASKS ============
  Future<Task> createTask(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return Task(
      id: id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: task.isCompleted,
    );
  }

  Future<List<Task>> getTasksByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ============ SHOPPING ITEMS ============
  Future<ShoppingItem> createShoppingItem(ShoppingItem item) async {
    final db = await instance.database;
    final id = await db.insert('shopping_items', item.toMap());
    return ShoppingItem(
      id: id,
      userId: item.userId,
      name: item.name,
      category: item.category,
      quantity: item.quantity,
      isPurchased: item.isPurchased,
    );
  }

  Future<List<ShoppingItem>> getShoppingItemsByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'shopping_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => ShoppingItem.fromMap(map)).toList();
  }

  Future<int> updateShoppingItem(ShoppingItem item) async {
    final db = await instance.database;
    return db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteShoppingItem(int id) async {
    final db = await instance.database;
    return await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
  }

  // ============ GOALS ============
  Future<Goal> createGoal(Goal goal) async {
    final db = await instance.database;
    final id = await db.insert('goals', goal.toMap());
    return Goal(
      id: id,
      userId: goal.userId,
      title: goal.title,
      description: goal.description,
      targetDate: goal.targetDate,
      category: goal.category,
      isCompleted: goal.isCompleted,
      progress: goal.progress,
    );
  }

  Future<List<Goal>> getGoalsByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Goal.fromMap(map)).toList();
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await instance.database;
    return db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // ============ MACHINES ============
  Future<Machine> createMachine(Machine machine) async {
    final db = await instance.database;
    final id = await db.insert('machines', machine.toMap());
    return Machine(
      id: id,
      userId: machine.userId,
      name: machine.name,
      imagePath: machine.imagePath,
    );
  }

  Future<List<Machine>> getMachinesByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'machines',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return result.map((map) => Machine.fromMap(map)).toList();
  }

  Future<Machine?> getMachineById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'machines',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Machine.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteMachine(int id) async {
    final db = await instance.database;
    return await db.delete('machines', where: 'id = ?', whereArgs: [id]);
  }

  // ============ WORKOUT PROGRAMS ============
  Future<WorkoutProgram> createWorkoutProgram(WorkoutProgram program) async {
    final db = await instance.database;
    final id = await db.insert('workout_programs', program.toMap());
    return WorkoutProgram(
      id: id,
      userId: program.userId,
      name: program.name,
      targetMuscles: program.targetMuscles,
    );
  }

  Future<List<WorkoutProgram>> getWorkoutProgramsByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'workout_programs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => WorkoutProgram.fromMap(map)).toList();
  }

  Future<WorkoutProgram?> getWorkoutProgramById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'workout_programs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return WorkoutProgram.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteWorkoutProgram(int id) async {
    final db = await instance.database;
    return await db.delete('workout_programs', where: 'id = ?', whereArgs: [id]);
  }

  // ============ PROGRAM EXERCISES ============
  Future<ProgramExercise> addExerciseToProgram(ProgramExercise programExercise) async {
    final db = await instance.database;
    final id = await db.insert('program_exercises', programExercise.toMap());
    return ProgramExercise(
      id: id,
      programId: programExercise.programId,
      exerciseId: programExercise.exerciseId,
      orderIndex: programExercise.orderIndex,
      sets: programExercise.sets,
      reps: programExercise.reps,
      durationSeconds: programExercise.durationSeconds,
      restSeconds: programExercise.restSeconds,
    );
  }

  Future<List<ProgramExercise>> getProgramExercises(int programId) async {
    final db = await instance.database;
    final result = await db.query(
      'program_exercises',
      where: 'program_id = ?',
      whereArgs: [programId],
      orderBy: 'order_index ASC',
    );
    return result.map((map) => ProgramExercise.fromMap(map)).toList();
  }

  Future<int> updateProgramExercise(ProgramExercise programExercise) async {
    final db = await instance.database;
    return db.update(
      'program_exercises',
      programExercise.toMap(),
      where: 'id = ?',
      whereArgs: [programExercise.id],
    );
  }

  Future<int> deleteProgramExercise(int id) async {
    final db = await instance.database;
    return await db.delete('program_exercises', where: 'id = ?', whereArgs: [id]);
  }

  // ============ WEEKLY SCHEDULE ============
  Future<WeeklySchedule> addToWeeklySchedule(WeeklySchedule schedule) async {
    final db = await instance.database;
    final id = await db.insert('weekly_schedule', schedule.toMap());
    return WeeklySchedule(
      id: id,
      userId: schedule.userId,
      programId: schedule.programId,
      dayOfWeek: schedule.dayOfWeek,
    );
  }

  Future<List<WeeklySchedule>> getWeeklySchedule(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'weekly_schedule',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'day_of_week ASC',
    );
    return result.map((map) => WeeklySchedule.fromMap(map)).toList();
  }

  Future<int> deleteFromWeeklySchedule(int id) async {
    final db = await instance.database;
    return await db.delete('weekly_schedule', where: 'id = ?', whereArgs: [id]);
  }

// ============ ACTIVE SESSIONS ============
Future<ActiveSession> createActiveSession(ActiveSession session) async {
  final db = await instance.database;
  
  // Supprimer toute session active existante pour cet utilisateur
  await db.delete(
    'active_sessions',
    where: 'user_id = ?',
    whereArgs: [session.userId],
  );
  
  final id = await db.insert('active_sessions', session.toMap());
  return ActiveSession(
    id: id,
    userId: session.userId,
    programId: session.programId,
    startTime: session.startTime,
    remainingSets: session.remainingSets,
    selectedExerciseId: session.selectedExerciseId,
    isResting: session.isResting,
    restTimeRemaining: session.restTimeRemaining,
  );
}

Future<ActiveSession?> getActiveSession(int userId) async {
  final db = await instance.database;
  final result = await db.query(
    'active_sessions',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
  if (result.isNotEmpty) {
    return ActiveSession.fromMap(result.first);
  }
  return null;
}

Future<int> updateActiveSession(ActiveSession session) async {
  final db = await instance.database;
  return db.update(
    'active_sessions',
    session.toMap(),
    where: 'id = ?',
    whereArgs: [session.id],
  );
}

Future<int> deleteActiveSession(int userId) async {
  final db = await instance.database;
  return db.delete(
    'active_sessions',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
}

  // ============ SET HISTORY ============
Future<SetHistory> createSetHistory(SetHistory setHistory) async {
  final db = await instance.database;
  final id = await db.insert('set_history', setHistory.toMap());
  return SetHistory(
    id: id,
    userId: setHistory.userId,
    exerciseId: setHistory.exerciseId,
    programId: setHistory.programId,
    date: setHistory.date,
    setNumber: setHistory.setNumber,
    weight: setHistory.weight,
    reps: setHistory.reps,
    durationSeconds: setHistory.durationSeconds,
  );
}

Future<List<SetHistory>> getSetHistoryByExercise(int exerciseId, {int? limit}) async {
  final db = await instance.database;
  final result = await db.query(
    'set_history',
    where: 'exercise_id = ?',
    whereArgs: [exerciseId],
    orderBy: 'date DESC',
    limit: limit,
  );
  return result.map((map) => SetHistory.fromMap(map)).toList();
}

Future<List<SetHistory>> getSetHistoryByProgram(int programId) async {
  final db = await instance.database;
  final result = await db.query(
    'set_history',
    where: 'program_id = ?',
    whereArgs: [programId],
    orderBy: 'date DESC',
  );
  return result.map((map) => SetHistory.fromMap(map)).toList();
}

Future<SetHistory?> getLastSetForExercise(int exerciseId) async {
  final db = await instance.database;
  final result = await db.query(
    'set_history',
    where: 'exercise_id = ?',
    whereArgs: [exerciseId],
    orderBy: 'date DESC',
    limit: 1,
  );
  if (result.isNotEmpty) {
    return SetHistory.fromMap(result.first);
  }
  return null;
}

Future<Map<int, double?>> getLastWeightsForProgram(int programId) async {
  final db = await instance.database;
  
  // Récupérer tous les exercices du programme
  final programExercises = await getProgramExercises(programId);
  Map<int, double?> lastWeights = {};
  
  for (var pe in programExercises) {
    final lastSet = await getLastSetForExercise(pe.exerciseId);
    lastWeights[pe.exerciseId] = lastSet?.weight;
  }
  
  return lastWeights;
}


  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
