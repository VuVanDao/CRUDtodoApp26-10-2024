import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
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
  final _headers = {'Content-Type': 'application/json'};
  final apiUrl = '${getBackendUrl()}/api/v1/todos';
  //lay ds todo
  Future<void> _fetchTodos() async {
    final res = await http.get(Uri.parse(apiUrl));
    if (res.statusCode == 200) {
      final List<dynamic> todoList = json.decode(res.body);
      setState(() {
        _todos.clear();
        _todos.addAll(todoList.map((e) => TodoModel.fromMap(e)).toList());
      });
    }
  }

  //them 1 todo
  Future<void> _addTodos() async {
    if (_controller.text.isEmpty) return;
    final newItem = TodoModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _controller.text,
        completed: false);
    final res = await http.post(Uri.parse(apiUrl),
        headers: _headers, body: json.encode(newItem.toMap()));
    if (res.statusCode == 200) {
      _controller.clear();
      _fetchTodos(); //lam moi ds
    }
  }

  //cap nhat trang thai complete
  Future<void> _updateTodo(TodoModel item) async {
    item.completed = !item.completed; //thay doi trang thai true,false
    final res = await http.put(Uri.parse('$apiUrl/${item.id}'),
        headers: _headers, body: json.encode(item.toMap()));
    if (res.statusCode == 200) {
      _fetchTodos();
    }
  }

  //xoa todo
  Future<void> _deleteTodo(int id) async {
    final res = await http.delete(
      Uri.parse('$apiUrl/$id'),
    );
    if (res.statusCode == 200) {
      _fetchTodos();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Todo App"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              //add todo
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: "Todo moi"),
                  )),
                  IconButton(onPressed: _addTodos, icon: const Icon(Icons.add))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  //ds todo
                  child: ListView.builder(
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        final item = _todos.elementAt(index);
                        return ListTile(
                          title: Text(item.title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                  value: item.completed,
                                  onChanged: (value) {
                                    _updateTodo(item);
                                  }),
                              IconButton(
                                  onPressed: () {
                                    _deleteTodo(item.id);
                                  },
                                  icon: const Icon(Icons.remove))
                            ],
                          ),
                        );
                      }))
            ],
          ),
        ));
  }
}
