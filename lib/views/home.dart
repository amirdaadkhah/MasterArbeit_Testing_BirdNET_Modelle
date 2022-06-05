import 'package:birdnet_models/views/choose_input_methode.dart';
import 'package:birdnet_models/views/result_view.dart';
import 'package:flutter/material.dart';
import 'chosse_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

class HomeView extends StatefulWidget {
  final String _title;

  const HomeView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();
    get_Permission();
    Wakelock.enable();
  }

  Future<void> get_Permission() async {
    await Permission.microphone.request();
    //await Permission.manageExternalStorage.request();
    //await Permission.storage.request();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 30,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.input)),
              //Tab(icon: Icon(Icons.model_training)),
              Tab(icon: Icon(Icons.watch_later_outlined)),
            ],
          ),
          title: Text('BirdNET Models'),
        ),
        body: const TabBarView(
          children: [
            ChooseInputView(title: '',),
            //ChooseModelView(title: '',),
            ResultView(title: '',),
          ],
        ),
      ),
    );
  }
}
