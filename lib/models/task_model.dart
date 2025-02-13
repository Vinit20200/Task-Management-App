class Task {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  String priority;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  Task copyWith(
      {int? id, String? title, String? description, DateTime? dueDate, bool? isCompleted, String? priority}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'isCompleted': isCompleted ? 1 : 0,
        'priority': priority
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        dueDate: DateTime.parse(map['dueDate']),
        isCompleted: map['isCompleted'] == 1,
        priority: map['priority'],
      );

  bool isDueOn(DateTime date) {
    return dueDate.year == date.year && dueDate.month == date.month && dueDate.day == date.day;
  }
}
