import 'package:flutter/material.dart';
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

class _MainScreenState extends State<MainScreen>{
  bool isPermission = false;

  late final Future<void> _future;

  @override
  void initState(){
    super.initState();

    _future = _requestCp();
  }

  Widget build(BuildContext context)
  {
    return FutureBuilder(future: _future,
    builder: (context, snapshot){
      return Scaffold(
        appBar: AppBar(
          title: const Text('OCR App'),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Text(
              isPermission
                ? 'Camera Granted'
                : 'Not Granted',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    },);
  }

  Future<void> _requestCp() async{
    final status = await Permission.camera.request();
    isPermission = status == PermissionStatus.granted;
  }

}