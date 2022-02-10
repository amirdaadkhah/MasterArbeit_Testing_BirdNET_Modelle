import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Reading_FilePath {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;

    print('File is:');
    print(File('$path/1644228932921.wav').toString());
    final content = await File('$path/1644228932921.wav').readAsBytesSync();
    print('content is:');
    print(content);

    return File('$path/1644228932921.wav');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  void printing() {
    print('access granted!');
    print(readCounter());
  }
}

///var/mobile/Containers/Data/Application/281CFDF5-7D24-4B9F-8B4F-70F856C7C301/Documents/1644228932921.wav
