import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/todo_model.dart';

String getBackendUrl() {
  if (kIsWeb) {
    return 'http://localhost:8080'; // hoặc sử dụng IP LAN nếu cần
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080'; // cho emulator
    // return 'http://192.168.1.x:8080'; // cho thiết bị thật khi truy cập qua LAN
  } else {
    return 'http://localhost:8080';
  }
}

class TodoView extends StatefulWidget {
  const TodoView({super.key});
  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final _todos = <TodoModel>[];
  final _controller = TextEditingController();

  final apiUrl = '${getBackendUrl()}/api/v1/todos';
  _fetchTodos() async {
    final res = await http.get(Uri.parse(apiUrl));
    if (res.statusCode == 200) {
      final List<dynamic> todoList = json.decode(res.body);
      setState(() {
        _todos.clear();
        _todos.addAll(todoList.map((e) => TodoModel.fromJson(e)).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
