import 'package:flutter/material.dart';
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
    final todo = await showDialog<Todo>(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        return AlertDialog(
          title: Text('새 할 일 추가'),
          content: TextField(
            onChanged: (value) {
              title = value;
            },
            decoration: InputDecoration(hintText: "할 일을 입력하세요"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () {
                Navigator.of(context).pop(Todo(title: title));
              },
            ),
          ],
        );
      },
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
