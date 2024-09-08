import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    _refreshTodoList();
  }

  void _refreshTodoList() async {
    final list = await dbHelper.getTodos();
    setState(() {
      todos = list;
    });
  }

  void _addTodo() async {
    final todo = await _showTodoDialog();
    if (todo != null) {
      await dbHelper.insertTodo(todo);
      _refreshTodoList();
    }
  }

  void _editTodo(Todo todo) async {
    final editedTodo = await _showTodoDialog(todo: todo);
    if (editedTodo != null) {
      await dbHelper.updateTodo(editedTodo);
      _refreshTodoList();
    }
  }

  Future<Todo?> _showTodoDialog({Todo? todo}) async {
    String title = todo?.title ?? '';
    DateTime? selectedDate = todo?.dueDate;

    return await showDialog<Todo>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(todo == null ? '새 할 일 추가' : '할 일 수정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    onChanged: (value) {
                      title = value;
                    },
                    controller: TextEditingController(text: title),
                    decoration: InputDecoration(hintText: "할 일을 입력하세요"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(
                        selectedDate == null ? '마감일 선택' : DateFormat('yyyy-MM-dd')
                            .format(selectedDate!)),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('취소'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(todo == null ? '추가' : '수정'),
                  onPressed: () {
                    Navigator.of(context).pop(Todo(
                      id: todo?.id,
                      title: title,
                      isCompleted: todo?.isCompleted ?? false,
                      dueDate: selectedDate,
                    ));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleTodoStatus(Todo todo) async {
    todo.isCompleted = !todo.isCompleted;
    await dbHelper.updateTodo(todo);
    _refreshTodoList();
  }

  void _deleteTodo(int id) async {
    await dbHelper.deleteTodo(id);
    _refreshTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo 리스트')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            title: Text(todo.title),
            subtitle: todo.dueDate != null ? Text('마감일: ${DateFormat('yyyy-MM-dd').format(todo.dueDate!)}') : null,
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (_) => _toggleTodoStatus(todo),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editTodo(todo),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTodo(todo.id!),
                ),
              ],
            ),
            onTap: () => _editTodo(todo),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: Icon(Icons.add),
      ),
    );
  }
}
