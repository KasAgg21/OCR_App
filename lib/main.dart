import 'dart:html';
import 'dart:io';
import 'dart:js';

import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ocr_app/result_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget{
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isPermission = false;

  late final Future<void> _future;

  CameraController? _cameraController;

  final _textRecognizer = TextRecognizer();

  @override
  void initState(){
    super.initState();

    _future = _requestCp();
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    _stopcamera();
    _textRecognizer.close();
    super.dispose();
  }

  void didChangeAppLifeCycle(AppLifecycleState state)
  {
    //Control Camera Flow
    if(_cameraController==null || !_cameraController!.value.isInitialized)
      {
        return;
      }
    if(state==AppLifecycleState.inactive){
      _stopcamera();
    }else if (state == AppLifecycleState.resumed && _cameraController!=null && _cameraController!.value.isInitialized){
      _startCamera();
    }
  }

  Widget build(BuildContext context)
  {
    return FutureBuilder(future: _future,
    builder: (context, snapshot){
      return Stack(
        children: [
          if(_isPermission)
            FutureBuilder<List<CameraDescription>>(
              future: availableCameras(),
              builder: (context,snapshot){
                if(snapshot.hasData){
                  _initCameraController(snapshot.data!);
                  return Center(child: CameraPreview(_cameraController!),);
                }else{
                  return const LinearProgressIndicator();
                }
              },
            ),
      Scaffold(
        appBar: AppBar(
          title: const Text('OCR App'),
        ),
        backgroundColor: _isPermission ? Colors.transparent : null,
        body: _isPermission
            ? Column(
      children: [
              Expanded(
                  child: Container()
            ,),
      Container(
      padding: const EdgeInsets.only(bottom: 30),
      child: const Center(
      child: ElevatedButton(
          onPressed: _scanImage,
          child: Text('Scan Text')),
      ),
      )
      ],
      )
            : Center(
                  child: Container(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                        child: const Text(
                              'Not Granted',
                              textAlign: TextAlign.center,
                                          ),
                                  ),
                  ),
            )
        ],
      );
    },);
  }

  Future<void> _requestCp() async{
    final status = await Permission.camera.request();
    _isPermission = status == PermissionStatus.granted;
  }

  void _startCamera()
  {
    if(_cameraController !=null)
      {
        _cameraSelected(_cameraController!.description);
      }
  }

  void _stopcamera(){
    if(_cameraController!=null){
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras)
  {
    if (_cameraController !=null)
      {
        return;
      }
    CameraDescription? camera;
    for (var i = 0;i<cameras.length;i++)
      {
        final CameraDescription current = cameras[i];
        if(current.lensDirection==CameraLensDirection.back)
          {
            camera=current;
            break;
          }
      }
    if(camera !=null)
      {
        _cameraSelected(camera);
      }
  }

  Future<void> _cameraSelected(CameraDescription camera) async
  {
    _cameraController = CameraController(camera, ResolutionPreset.max,enableAudio: false);

    await _cameraController?.initialize();

    if(!mounted)
      {
        return;
      }
    setState(() {});
  }

  Future<void> _scanImage() async{
    if(_cameraController == null) {return;}

    final navigator = Navigator.of(context as BuildContext);

    try{
      final pictureFile = await _cameraController!.takePicture();
      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recoginizedText = await _textRecognizer.processImage(inputImage);
      await navigator.push(MaterialPageRoute(
          builder: (context)=>ResultScreen(text: recoginizedText.text)));
    }
    catch(e)
    {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(content: Text('An Error Occured while Scanning')));
    }
  }
}