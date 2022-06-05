import 'package:birdnet_models/main.dart';
import 'package:birdnet_models/views/choose_input_methode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:birdnet_models/views/chosse_model.dart';
import 'Classifier.dart';
import 'package:birdnet_models/views/choose_input_methode.dart' as ch;


late List<double> MicChunk = [];

class RecordManager extends StatefulWidget {
  final bool Button_Is_Active;

  const RecordManager({Key? key, required bool is_Active})
      : Button_Is_Active = is_Active,
        super(key: key);

  @override
  _RecordManagerState createState() => _RecordManagerState();
}

class _RecordManagerState extends State<RecordManager> {

  FlutterAudioCapture _plugin = new FlutterAudioCapture();
  bool _is_Recording = false;
  bool _is_Pass = false; // if MicChunk is >= 144000 or not
  Timer? timer;
  int _Percent = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    Toggle_Record_Pause(true);
    super.dispose();
  }

  Future<void> _startCapture() async {
    await _plugin.start(listener, onError, sampleRate: sampleRate, bufferSize: 3000);
  }

  Future<void> _stopCapture() async {
    await _plugin.stop();
  }

  void listener(dynamic obj) async {
    var _Stream_Value_String = obj.toString();
    var _Stream_Values_Array = _Stream_Value_String.split(',');

    for(final raw in _Stream_Values_Array) {
      if (double.tryParse(raw) != null) {
        MicChunk.add(double.parse(raw));

      } else {
        MicChunk.add(change_To_double(raw));
      }
    }
  }

  double change_To_double(String Str) {
    String DOUBLE_VALUE = Str;

    if (Str.contains('[')) {
      DOUBLE_VALUE = Str.split('[')[1];

    } else if (Str.contains(']')) {
      DOUBLE_VALUE = Str.split(']')[0];

    } else {
      print('error in parsing');
    }
    return double.parse(DOUBLE_VALUE);
  }

  void onError(Object e) {
    print(e);
  }

  final _is_Mic_Pause = [false];
  bool _Icon_Toggle = false;

  int get_Percent(){
    if (_Percent >= 99*15 && !is_Model_Finished) { // *15 because there are 0 - 14 models
      return 99;
    } else if (_Percent >= 99*15 && is_Model_Finished && is_100) {
      return 100;
    }
    var res = (_Percent/15).toInt();
    if (res>99){
      res = 99;
    }
    return res;
  }

  bool is_Txt_Shown = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${get_Percent()}%', textAlign: TextAlign.left),
        Text('', textAlign: TextAlign.center),
        !is_Txt_Shown ? Text('', textAlign: TextAlign.center) : Text('It,s Done, Thank you, please share the result with us.', textAlign: TextAlign.center, maxLines: 2,),
        Text('', textAlign: TextAlign.center),
        Align(
          alignment: Alignment.center,
          child: Container(
            alignment: Alignment.center,
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.all(Radius.circular(60)),
            ),
            child: ToggleButtons(
              constraints: BoxConstraints(maxWidth: 140, minWidth: 140, minHeight: 140, maxHeight: 140),
              children: <Widget>[
                _Icon_Toggle != true ?
                new Row(children: <Widget>[new Icon(Icons.mic_outlined,size: 55.0,color: Colors.white)],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,)
                    : new Row(children: <Widget>[new Icon(Icons.pause_circle_filled,size: 55.0,color: Colors.blueAccent)],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,),
              ],
              borderRadius: BorderRadius.circular(60),
              borderWidth: 3,
              color: Colors.white,
              fillColor: Colors.white,
              selectedColor: Colors.blueAccent,
              onPressed: (int index) {
                _is_Mic_Pause[index] = !_is_Mic_Pause[index];
                Toggle_Record_Pause(_Icon_Toggle);
                //_Icon_Toggle = !_Icon_Toggle;
              },
              isSelected: _is_Mic_Pause,
            ),
          ),
        ),
        Text('', textAlign: TextAlign.center)
      ],
    );
  }

  void Toggle_Record_Pause(bool IS_RECORDING) {

    switch(IS_RECORDING) {
      case false:
        print('start recording');
        _startCapture();

        _new_Classifier = get_classifier_ready(All_Model_Name[Model_Index]) as Classifier; // create new classifier for first model, index must be 0
        timer = Timer.periodic(Duration(milliseconds: 600), (timer) {
          To_Classify(_is_Pass, get_Raw_Input());
        });

        break;
      case true:
        _Percent = 0;
        print('stop recording');
        _stopCapture();
        timer?.cancel();
        A_ChooseInputView().prepare_Share_File();
        setState(() {
          is_Txt_Shown = !is_Txt_Shown;
        });
        MicChunk.clear();
        break;
    }
    _is_Recording = !_is_Recording;
    setState(() {
      _Icon_Toggle = !_Icon_Toggle;
    });
  }

  List<double> get_Raw_Input() {
    if(MicChunk.length >= 144000) {
      final Diff = MicChunk.length - 144000;
      MicChunk.removeRange(0, Diff);
      _is_Pass = true;
    }
    if(MicChunk.length < 144000) {
      _is_Pass = false;
    }
    return MicChunk;
  }

  late Classifier _new_Classifier;
  bool is_Model_Changed = true;

  void To_Classify(bool pass, List<double> Mik_Row) {
    if (pass) {
      if(!is_Model_Finished){
        if(is_100) {
          close_Classifier();
          final M_Name = change_model_name();
          _new_Classifier = get_classifier_ready(M_Name);//create new classifier with the next model, change model name
          _new_Classifier.Max_Predictions = 1;
          is_100 = false;
        } else {
          _new_Classifier.predict(Mik_Row);
          setState(() {
            _Percent += 1;
          });
        }

      } else if(is_Model_Finished) {
        if(!is_100) {
          _new_Classifier.predict(Mik_Row);
          setState(() {
            print('percent is:   $_Percent');
            _Percent += 1;
          });
        } else {
          _is_Pass = false; // stop prediting
          Toggle_Record_Pause(true); // stop recording
          _Percent = 1500;
        }
      }
    }
  }


  Classifier get_classifier_ready(String Model_Name) {
    late Classifier classifier;
    classifier = Classifier(Model_Name);
    return classifier;
  }

  void close_Classifier() async {
    _new_Classifier.close();
  }

  String change_model_name()  {
    Model_Index += 1;
    print('Model index is: $Model_Index');
    if(Model_Index == 14) {
      is_Model_Finished = true;
      print('Model is finished: $is_Model_Finished');
    }
    return All_Model_Name[Model_Index];
  }
}



late String Str_Result;
bool is_100 = false;
int Model_Index = 0;
bool is_Model_Finished = false;
const List<String> All_Model_Name = [
  'BirdNET_1K_V1.1_Model_INT8.tflite',
  'BirdNET_1K_V1.1_Model_FP16.tflite',
  'BirdNET_1K_V1.1_Model_FP32.tflite',
  'BirdNET_1K_V1.2_Model_INT8.tflite',
  'BirdNET_1K_V1.2_Model_FP16.tflite',
  'BirdNET_1K_V1.2_Model_FP32.tflite',
  'BirdNET_1K_V1.3_Model_INT8.tflite',
  'BirdNET_1K_V1.3_Model_FP16.tflite',
  'BirdNET_1K_V1.3_Model_FP32.tflite',
  'BirdNET_1K_V1.4_Model_INT8.tflite',
  'BirdNET_1K_V1.4_Model_FP16.tflite',
  'BirdNET_1K_V1.4_Model_FP32.tflite',
  'BirdNET_GLOBAL_1K_V2.0_Model_INT8.tflite',
  'BirdNET_GLOBAL_1K_V2.0_Model_FP16.tflite',
  'BirdNET_GLOBAL_1K_V2.0_Model_FP32.tflite'
];
