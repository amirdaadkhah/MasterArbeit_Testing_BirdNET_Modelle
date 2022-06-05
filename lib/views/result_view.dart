import 'package:flutter/material.dart';

class ResultView extends StatefulWidget {
  final String _title;

  const ResultView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  _ResultView createState() => _ResultView();
}

class _ResultView extends State<ResultView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Input',
      home: new Scaffold(
        //Here you can set what ever background color you need.
        backgroundColor: Colors.blue,
      ),
    );

  }
}
