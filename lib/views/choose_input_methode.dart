import 'dart:async';
import 'dart:io';
import 'package:birdnet_models/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../record_manager.dart';
import 'chosse_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool Share_To_Pressed = false;

class ChooseInputView extends StatefulWidget {
  final String _title;
  static Map<String, Map<dynamic, dynamic>> Result_To_Share = new Map();
  static Map<dynamic, dynamic> Content = new Map();


  const ChooseInputView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  A_ChooseInputView createState() => A_ChooseInputView();
}

class A_ChooseInputView extends State<ChooseInputView> {
  Timer? _timer;
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text('please press an Record Button'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //Mic_File_Row(),
          //Select_Model(),
          //ChooseModelView(title: '',),
          RecordManager(is_Active: is_Button_Active,),
          //Load_File_Row(),
          Share_Submit_Row(),
        ],
      ),
    );
  }

  final isSelected = <bool>[true, false];
  bool is_Recording = true;
  bool is_Button_Active = true;

  Widget Mic_File_Row() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(5, 2, 5, 5),
      child: ToggleButtons(
        color: Colors.black.withOpacity(0.60),
        selectedColor: Colors.white,
        selectedBorderColor: Colors.grey,
        fillColor: Colors.blueAccent,
        splashColor: Colors.grey,
        hoverColor: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        constraints: BoxConstraints(minHeight: 45.0),
        isSelected: isSelected,
        onPressed: (index) {
          setState(() {
            isSelected[0] = !isSelected[0];
            isSelected[1] = !isSelected[1];
            is_Button_Active = !is_Button_Active; // active either Mic or upload a audio file
          });
        },
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text('Microphone'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text('Audio file'),
          ),
        ],
      ),
    );
  }

  final is_Model_Selected = <bool>[true, false, false, false, false];

  Widget Select_Model() {
    return Container(
      padding: EdgeInsets.fromLTRB(5, 2, 5, 5),
      child: ToggleButtons(
        color: Colors.black.withOpacity(0.60),
        selectedColor: Colors.white,
        selectedBorderColor: Colors.grey,
        fillColor: Colors.blueAccent,
        splashColor: Colors.grey,
        hoverColor: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        constraints: BoxConstraints(minHeight: 35.0),
        isSelected: is_Model_Selected,
        onPressed: (index) {
          setState(() {
            Model_Selected(index);
          });
        },
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('V1.1'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('V1.2'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('V1.3'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('V1.4'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('V2.0'),
          ),
        ],
      ),
    );
  }

  void Model_Selected(int index) {

    for(int i=0;i<5;i++) {
      is_Model_Selected[i] = false;
    }
    is_Model_Selected[index] = true;
  }
/*
  Widget Load_File_Row() {
    return Container(
      decoration: new BoxDecoration(
          color: Colors.grey
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      width: 100,
      height: 70,
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 30,
            child: ElevatedButton(
              //style: Mic_Input_Button_Style,
              child: const Text('upload'),
              onPressed: !is_Button_Active ? (){} : null,
            ),
          ),
        ],
      ),
    );
  }
*/
  Widget Share_Submit_Row() {
    return Container(
      alignment: Alignment.center,
      width: 200,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 185,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: !Share_To_Pressed ? Colors.black87 : Colors.green,
                textStyle: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              child: const Text('Share Result'),
              onPressed: () {
                setState(() {
                  ShareButtonPressed();
                });
              },
            ),
          ),
        ],
      ),
    );
  }





  //List<String> Files_To_Share = ['test1'];
  void ShareButtonPressed() async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/result.txt');
    if(file != null) {
      Share.shareFiles([file.path]);
    }
  }

  void prepare_Share_File() async {
    String result = '';

    final prefs = await SharedPreferences.getInstance();
    for(int i=0;i<15;i++) {
      final String? action = prefs.getString(All_Model_Name[i]);
      result += action ?? 'No Result for: ${All_Model_Name[i]}';
    }

    final De_Info = {'Device_Info': Device_Info};// add device, version, OS etc. to category
    var STR = De_Info.toString() + ',*,' + result;

    _write(STR);
  }

  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = new File('${directory.path}/result.txt');
    await file.writeAsString(text);
  }
}
