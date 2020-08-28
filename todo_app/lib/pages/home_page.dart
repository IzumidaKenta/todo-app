import 'package:flutter/material.dart';
import 'package:todo_app/pages/app_background.dart';
import 'list_page.dart';

var homePageKey = GlobalKey<_HomePageState>();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          AppBackgroundPage(),
          ListPage(
            key: listPageKey,
          )
        ],
      ),
    );
  }
}
