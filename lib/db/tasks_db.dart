import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:todoapp/models/task_model.dart';

class TasksDatabase{
  static final TasksDatabase instance = TasksDatabase._init();
  static Database? _database;
  TasksDatabase._init();
  Future<Database> get database async{
    if (_database != null) return _database!;

    _database = await _initDB('tasks.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = (dbPath + filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  FutureOr<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableTasks(
      ${TaskFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${TaskFields.name} TEXT NOT NULL,
      ${TaskFields.isDone} BOOLEAN NOT NULL
    )
    ''');
  }
  Future<Task> create(Task task) async {
    final db = await instance.database;
    // final json = task.toJson();
    // final columns = '${TaskFields.name}, ${TaskFields.isDone}';
    // final values = '${json[TaskFields.name]}, ${task.isDone ? 1 : 0}';
    // final id  = await db.rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');
    final id = await db.insert(tableTasks, task.toJson());
    return task.copy(id: id);
  }
  Future<Task> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableTasks,
      columns: TaskFields.values,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }
  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    final orderBy = '${TaskFields.isDone}, ${TaskFields.name}';
    final result = await db.query(tableTasks, orderBy: orderBy);
    return result.map((json) => Task.fromJson(json)).toList();
  }
  
  Future<int> update(Task task) async {
    final db = await instance.database;
    return db.update(
      tableTasks,
      task.toJson(),
      where: '${TaskFields.id} = ?',
      whereArgs: [task.id],
    );
  }
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableTasks,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );
  }
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}