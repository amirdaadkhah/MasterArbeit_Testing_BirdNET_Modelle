import 'package:flutter/material.dart';
import 'package:voice_reocrder/views/recorder_home_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BirdNET Models',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RecorderHomeView(
        title: 'BirdNET Models',
      ),
    );
  }
}
