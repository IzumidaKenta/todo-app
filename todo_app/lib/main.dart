import 'package:flutter/material.dart';
import 'package:todo_app/pages/home_page.dart';

void main () => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TodoApp",
      debugShowCheckedModeBanner: false,
      color: Colors.pink,
      home: HomePage(),
    );
  }

}