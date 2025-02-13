import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class TaskDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 2, // ✅ Increment version from 1 to 2
      onCreate: (db, version) {
        return db.execute(
          '''CREATE TABLE tasks(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              title TEXT, 
              description TEXT, 
              dueDate TEXT, 
              isCompleted INTEGER,
              priority TEXT  -- ✅ Ensure priority column exists
          )''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute("ALTER TABLE tasks ADD COLUMN priority TEXT DEFAULT 'Normal'");
        }
      },
    );
  }

  Future<List<Task>> fetchTasks() async {
    final db = await database;
    final maps = await db.query('tasks');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }
}
