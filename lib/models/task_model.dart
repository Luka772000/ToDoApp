final String tableTasks = 'tasks';

class TaskFields{
  static final List<String> values = [
    id, name, isDone
  ];
  static final String id = '_id';
  static final String name = 'name';
  static final String isDone = 'isDone';
}

class Task{
  final int? id;
  final String name;
  final bool isDone;
  const Task({
    this.id,
    required this.name,
    this.isDone = false,
  });
  Map<String, Object?> toJson() => {
  TaskFields.id: id,
  TaskFields.name: name,
  TaskFields.isDone: isDone ? 1 : 0,
};
static Task fromJson(Map<String,Object?> json) => Task(
  id: json[TaskFields.id] as int?,
  name: json[TaskFields.name] as String,
  isDone: json[TaskFields.isDone] == 1,
);
Task copy({
  int? id,
  String? name,
  bool? isDone,
})=>
Task(
  id: id ?? this.id,
  name: name ?? this.name,
  isDone: isDone ?? this.isDone,
);
}
