import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/todo_model.dart';

//lop dinh nghia cac route cho CRUD
class TodoRouter {
  //danh sach cac cong viec dc quan li boi backend
  final _todos = <TodoModel>[];

  //tao, tra ve 1 route cho CRUD
  Router get router {
    final router = Router();

    //R
    router.get('/todos', _getTodohandler);
    //C
    router.post('/todos', _AddTodohandler);

    return router;
  }

  //header mac dinh cho du lieu tra ve json
  static final _headers = {'Content-Type': 'application/json'};
  //R
  Future<Response> _getTodohandler(Request req) async {
    try {
      //toList() chuyển đổi iterable  thành một danh sách (List) các Map.
      //Hàm json.encode() từ thư viện dart:convert chuyển đổi một đối tượng Dart (ở đây là List<Map>) thành chuỗi JSON.
      final body = json.encode(_todos
          .map((todo) => todo.toMap())
          .toList()); //Hàm toMap() chuyển đổi đối tượng todo thành một Map có các cặp khóa - giá trị, để dễ dàng chuyển đổi sang JSON.

      return Response.ok(body, headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: json.encode({'error': e.toString()}), headers: _headers);
    }
  }

  //C
  Future<Response> _AddTodohandler(Request req) async {
    try {
      final payload = await req
          .readAsString(); //payload sẽ chứa dữ liệu dưới dạng chuỗi, thường là JSON.
      final data = json.decode(
          payload); // json.decode để chuyển đổi chuỗi JSON payload thành một đối tượng Dart (Map hoặc List).\
      final todo = TodoModel.fromMap(
          data); // Phương thức tạo ra một đối tượng TodoModel từ một Map (tập hợp các cặp key-value).
      _todos.add(todo);
      return Response.ok(todo.toJson(), headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: json.encode({'error': e.toString()}), headers: _headers);
    }
  }
}
