import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget{
  final String text;

  const ResultScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) =>Scaffold(
    appBar: AppBar(
      title: const Text('Extracted Text'),
    ),
    body: Container(
      padding: const EdgeInsets.all(30),
      child: Text(text),
    ),
  );
}