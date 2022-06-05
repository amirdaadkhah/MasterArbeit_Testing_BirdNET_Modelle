import 'package:birdnet_models/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import '../Classifier.dart';

//late Classifier classifier;

class ChooseModelView extends StatefulWidget {
  final String _title;

  const ChooseModelView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  _ChooseModelViewState createState() => _ChooseModelViewState();
}

class _ChooseModelViewState extends State<ChooseModelView> {
  FlutterAudioCapture _plugin = new FlutterAudioCapture();

  //late Classifier classifier;
  late String _Selected_Model_Name;

  final List<String> _Assets_Model_Names = [
    'BirdNET_1K_V1.4_Model_INT8',
    'BirdNET_1K_V1.4_Model_FP16',
    'BirdNET_1K_V1.4_Model_FP32',
    'BirdNET_1K_V1.4_MData_Model_FP32'];

  List<String> Models_Name = ['INT8', 'FP16', 'FP32', 'MD-FP32'];
  final _is_Model_Selected = <bool>[true, false, false, false];

  ButtonStyle _Button_Style = ElevatedButton.styleFrom(primary: Colors.transparent,
      onSurface: Colors.blueAccent,
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      fixedSize: const Size(120, 50));

  @override
  void initState() {

    super.initState();
    Model_Pressed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 110,
      width: 240,
      child: Column (
          children: <Widget> [
            Container(
                alignment: Alignment.center,
                transformAlignment: Alignment.center,
                color: Colors.black12,
                height: 48,
                width: 240,
                child: Row(
                  children: <Widget>[
                    ElevatedButton(
                      style: _Button_Style,
                      child: Text(Models_Name[0]),
                      onPressed: !_is_Model_Selected[0] ? (){
                        Model_Pressed(0);
                      } : null,
                    ),
                    ElevatedButton(
                      style: _Button_Style,
                      child: Text(Models_Name[1]),
                      onPressed: !_is_Model_Selected[1] ? (){
                        Model_Pressed(1);
                      } : null,
                    ),
                  ],
                )
            ),

            Container(
                //padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                color: Colors.black12,
                height: 48,
                width: 240,
                child: Row(
                  children: <Widget>[
                    ElevatedButton(
                      style: _Button_Style,
                      child: Text(Models_Name[2]),
                      onPressed: !_is_Model_Selected[2] ? (){
                        Model_Pressed(2);
                      } : null,
                    ),
                    ElevatedButton(
                      style: _Button_Style,
                      child: Text(Models_Name[3]),
                      onPressed: !_is_Model_Selected[3] ? (){
                        Model_Pressed(3);
                      } : null,
                    ),
                  ],
                )
            ),
          ]
      )
    );
  }

  void Model_Pressed(int index) {

    //disable all model buttons

   /* for(int i=0;i<4;i++){
      _is_Model_Selected[i] = false;
    }
    _is_Model_Selected[index] = true;
    setState(() {});

    _Selected_Model_Name = _Assets_Model_Names[index]+'.tflite';
    classifier = Classifier(_Selected_Model_Name);*/
  }
}
