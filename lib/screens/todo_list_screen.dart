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
    String title = '';
    DateTime? selectedDate;

    final todo = await showDialog<Todo> (
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
          return AlertDialog(
            title: Text('새 할 일 추가'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    title = value;
                  },
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
                      initialDate: DateTime.now(),
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
                child: Text('추가'),
                onPressed: () {
                  Navigator.of(context).pop(Todo(title: title, dueDate: selectedDate));
                },
              ),
            ],
          );
        });
      }
    );

    if (todo != null) {
      await dbHelper.insertTodo(todo);
      _refreshTodoList();
    }
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
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTodo(todo.id!),
            ),
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
