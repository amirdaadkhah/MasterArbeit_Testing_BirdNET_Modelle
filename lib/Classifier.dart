import 'dart:io';
import 'package:birdnet_models/record_manager.dart';
import 'package:birdnet_models/views/choose_input_methode.dart' as CH_View;
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Classifier {
  final String _modelFileName;
  final String _labelFileName = 'assets/BirdNET_1K_V1.4_Labels.txt';
  final String _labelFileName2 = 'assets/BirdNET_GLOBAL_1K_V2.0_Labels.txt';
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  late List<int> _inputShape;
  late List<int> _outputShape;
  late TensorBuffer _outputBuffer;
  TfLiteType _outputType = TfLiteType.uint8;
  late Map<int, String> labels;
  late List<String> ListLabels;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();


  Classifier(this._modelFileName, {int? numThreads}) {

    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }

    loadModel();

    if(_modelFileName == 'BirdNET_GLOBAL_1K_V2.0_Model_INT8.tflite'
        || _modelFileName == 'BirdNET_GLOBAL_1K_V2.0_Model_FP16.tflite'
        || _modelFileName == 'BirdNET_GLOBAL_1K_V2.0_Model_FP32.tflite')
    {
      loadLabels(_labelFileName2);
    } else {
      loadLabels(_labelFileName);
    }
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(_modelFileName);

      print('Interpreter Created Successfully');
      print(interpreter.getInputTensors());
      print(interpreter.getOutputTensors());
      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;

      _outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      print('Model loaded successfully.');
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  Future<void> loadLabels(String ModelSTR) async {
    //labels = await loadLabelsFile(_labelFileName);
    ListLabels = await FileUtil.loadLabels(ModelSTR);
  }
  Future<void> changeLabels() async {
    ListLabels = await FileUtil.loadLabels(_labelFileName2);
  }


  Future<List<Category>> predict(List<double> audioSample) async {
    //ListLabels = await FileUtil.loadLabels(_labelFileName);
    final pres = DateTime.now().millisecondsSinceEpoch;
    TensorAudio tensorAudio = TensorAudio.create(
        TensorAudioFormat.create(1, sampleRate), _inputShape[1]);
    tensorAudio.loadDoubleList(audioSample);
    TensorBuffer inputBuffer = tensorAudio.tensorBuffer;
    final pre = DateTime.now().millisecondsSinceEpoch - pres;

    final runs = DateTime.now().millisecondsSinceEpoch;
    try {
      interpreter.run(inputBuffer.getBuffer(), _outputBuffer.getBuffer());
    } catch (e) {
      print('Error loading model: ' + e.toString());
    }
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    final Full_Classification_Time = DateTime.now().millisecondsSinceEpoch - pres;

    TensorLabel tensorLabel = TensorLabel.fromList(ListLabels, _outputBuffer);
    Map<String, double> doubleMap = tensorLabel.getMapWithFloatValue();

    final top = getTopProbability(doubleMap); //our result

    if (Max_Predictions <= 100) {
      Result_Category(top, Full_Classification_Time, run, pre);

    } else {
      var Model_Content = {_modelFileName: CH_View.ChooseInputView.Content};
      is_100 = true; // change model name
      _write_to_sharedP(_modelFileName, Model_Content.toString());
    }
    return top;
  }

  void close() {
    interpreter.close();
  }

  var Max_Predictions = 1;
  Map<String, Map<dynamic, dynamic>> Content_100 = new Map();

  void Result_Category(List<Category> Pred_List, int T, int run_T, int pre_T) {
    Map<String, dynamic> Predict_Content = new Map();

    var content1 = {'C_Time': T};
    var content2 = {'run_Time': run_T};
    var content3 = {'pre_Time': pre_T};
    Predict_Content.addAll(content1);
    Predict_Content.addAll(content2);
    Predict_Content.addAll(content3);

    for(int i=0;i<3;i++){
      var content4 = {'Label${i+1}': Pred_List[0].label};
      var content5 = {'score${i+1}': Pred_List[0].score};
      Predict_Content.addAll(content4);
      Predict_Content.addAll(content5);
    }
    var content6 = {'Predict$Max_Predictions': Predict_Content};
    Max_Predictions += 1;
    CH_View.ChooseInputView.Content.addAll(content6);
  }

  Future<void> _write_to_sharedP(String Key, String Value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(Key, Value);
  }
}

List<Category> getTopProbability(Map<String, double> labeledProb) {
  var pq = PriorityQueue<MapEntry<String, double>>(compare);
  pq.addAll(labeledProb.entries);
  var result = <Category>[];
  while (pq.isNotEmpty && result.length < 5 && (pq.first.value > 0.1 || result.length < 3)) {
    result.add(Category(pq.first.key, pq.first.value));
    pq.removeFirst();
  }
  return result;
}

int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
  if (e1.value > e2.value) {
    return -1;
  } else if (e1.value == e2.value) {
    return 0;
  } else {
    return 1;
  }
}

Future<Map<int, String>> loadLabelsFile(String fileAssetLocation) async {
  final fileString = await rootBundle.loadString('$fileAssetLocation');
  return labelListFromString(fileString);
}

Map<int, String> labelListFromString(String fileString) {
  var classMap = <int, String>{};
  final newLineList = fileString.split('\n');
  for (var i = 1; i < newLineList.length; i++) {
    final entry = newLineList[i].trim();
    if (entry.length > 0) {
      final data = entry.split(',');
      classMap[int.parse(data[0])] = data[2];
    }
  }
  return classMap;
}