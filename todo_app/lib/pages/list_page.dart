import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_app/pages/app_background.dart';
import 'package:http/http.dart' as http; //httpリクエスト用
import 'dart:async'; //非同期処理用
import 'dart:convert';
import 'package:todo_app/models/todo.dart';

var listPageKey = GlobalKey<_ListPageState>();

class ListPage extends StatefulWidget {
  const ListPage({Key key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  bool _validate = false;

  final TextEditingController eCtrl = TextEditingController();
  List todoList;

  Future getData() async {
    await http
        .get('http://localhost:8080/api/v1/todos')
        .then((http.Response response) {
      String responseBody = utf8.decode(response.bodyBytes);
      final body = json.decode(responseBody);
      todoList = body.map((j) => Todo.fromJson(j)).toList();
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    eCtrl.dispose();
    super.dispose();
  }

  //Listに新しいTodoを追加する処理
  void addListItem(String text) {
    _validate = false;
    final Todo newItem = Todo(
      title: text,
      checked: false,
    );
    //データベースに新しいTodoをPOSTしてからGETして表示すると、表示に時間がかかってしまうため、
    //todoListに新しいTodoをインサートしている。
    todoList.add(newItem);
    eCtrl.clear();
    setState(() {});

    //POSTする
    postTodo(newItem);
  }

  Future postTodo(Todo newItem) async {
    final String url = 'http://localhost:8080/api/v1/todos';
    final response = await http.post(url,
        body: json.encode(newItem.toJson()),
        headers: {"Content-Type": "application/json"});
  }

  //Todoのアップデートを行う処理
  void updateTodos(Todo data, int i) {
    if (data.checked == false) {
      final updatedTask = Todo(
        title: data.title,
        checked: true,
      );
      todoList[i] = updatedTask;
    } else if (data.checked == true) {
      final updatedTask = Todo(
        title: data.title,
        checked: false,
      );
      todoList[i] = updatedTask;
    }
    setState(() {});
  }

  //PUTする
  Future putTodo(int i) async {
    //MySQLデータベースとListViewの開始Indexが違うため
    i = i + 1;
    final String url = 'http://localhost:8080/api/v1/todos/' + i.toString();
    await http.put(url).then((http.Response response) {});
  }

  //タスクの削除を行う処理
  void removeTodo(Todo todo) async {
    setState(() => todoList.remove(todo));
  }

  //DELETEする
  Future deleteTodo(int i) async {
    final String url = 'http://localhost:8080/api/v1/todos/' + i.toString();
    await http.delete(url).then((http.Response response) {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Tasks'),
          centerTitle: true,
          actions: <Widget>[],
        ),
        body: Stack(
          children: <Widget>[
            AppBackgroundPage(),
            Column(
              children: <Widget>[
                buildInputContainer(),
                todoList != null
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: todoList.length,
                          itemBuilder: (BuildContext context, int i) {
                            return buildListItem(todoList, i);
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Dismissible buildListItem(List data, int i) {
    return Dismissible(
      key: ObjectKey(data[i]),
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                data[i].title,
                style: TextStyle(
                  color: data[i].checked == false ? Colors.black : Colors.grey,
                  decoration: data[i].checked == false
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              leading: Icon(Icons.list),
              trailing: IconButton(
                icon: Icon(
                  (data[i].checked == false)
                      ? Icons.check_box_outline_blank
                      : Icons.check_box,
                  color: Colors.greenAccent,
                ),
                onPressed: () {
                  //データベースを変更した後に読み込んで表示すると、表示に時間がかかってしまうため、ローカルでcheckedの値を変更している
                  updateTodos(data[i], i);
                  putTodo(i);
                },
              ),
            ),
            Divider(height: 0),
          ],
        ),
        actions: <Widget>[
          IconSlideAction(
            caption: "Undo",
            color: Colors.grey,
            icon: Icons.delete,
            onTap: () {
              removeTodo(data[i]);
              deleteTodo(i);
            },
          ),
        ],
      ),
    );
  }

  //インプットボックスの定義
  Padding buildInputContainer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              height: MediaQuery.of(context).size.height * 0.1,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(8.0)),
              ),
              child: TextField(
                controller: eCtrl,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter your Task",
                  errorText: _validate ? 'The input is empty.' : null,
                  contentPadding: EdgeInsets.all(8.0),
                ),
                onTap: () => setState(() => _validate = false),
                onSubmitted: (text) {
                  if (text.isEmpty) {
                    setState(() {
                      _validate = true;
                    });
                  } else {
                    addListItem(text);
                  }
                },
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            child: RaisedButton(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(8.0)),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                if (eCtrl.text.isEmpty) {
                  setState(() => _validate = true);
                } else {
                  addListItem(eCtrl.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
