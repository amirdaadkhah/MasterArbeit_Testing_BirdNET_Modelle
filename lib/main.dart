import 'package:birdnet_models/views/home.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:ios_utsname_ext/extension.dart';

const int sampleRate = 48000;
late Map<String, dynamic?> Device_Info = {'Test': 'first'};

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
    //get_Device_Name();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();

/*  Future<void> get_Device_Name() async {

    if (Platform.isIOS) {
      var build = await deviceInfoPlugin.iosInfo;
      setState(() {
          var content1 = {'iOS_Model': build.model};//brand
          var content2 = {'OS': build.systemName};//OS
          var content3 = {'Version': build.systemVersion};//iOS Version
          var content4 = {'Iphone_Exact_Model': build.utsname.machine?.iOSProductName};// iphone exact model
          Device_Info.addAll(content1);
          Device_Info.addAll(content2);
          Device_Info.addAll(content3);
          Device_Info.addAll(content4);
      });
    }
    if(Platform.isAndroid) {
     var build = await deviceInfoPlugin.androidInfo;
      setState(() {
        var content1 = {'model': build.model};
        var content2 = {'product': build.product};
        var content3 = {'SDK': build.version.sdkInt};//Android SDK Version
        var content4 = {'board': build.board};
        var content5 = {'brand': build.brand};
        var content6 = {'device': build.device};
        Device_Info.addAll(content1);
        Device_Info.addAll(content2);
        Device_Info.addAll(content3);
        Device_Info.addAll(content4);
        Device_Info.addAll(content5);
        Device_Info.addAll(content6);
      });
    }

    var content7 = {'Platform_OPSystem': Platform.operatingSystem}; //iOS or android
    var content8 = {'Platform_OPSys_Version': Platform.operatingSystemVersion}; // version
    var content9 = {'Platform.Nr_Processors': Platform.numberOfProcessors}; // number of processor
    Device_Info.addAll(content7);
    Device_Info.addAll(content8);
    Device_Info.addAll(content9);
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BirdNET Models',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeView(
        title: 'BirdNET Models',
      ),
    );
  }


  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
        if (Platform.isAndroid) {
          deviceData =
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        }

    } catch (e) {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      Device_Info = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
      'iphone_exact_model': data.utsname.machine?.iOSProductName,// iphone exact model
    };
  }
}