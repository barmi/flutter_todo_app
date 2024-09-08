class Todo {
  int? id;
  String title;
  bool isCompleted;
  DateTime? dueDate;

  Todo({this.id, required this.title, this.isCompleted = false, this.dueDate});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.toIso8601String()
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }
}
