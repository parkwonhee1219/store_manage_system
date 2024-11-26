import 'package:flutter/material.dart';

class GpioScreen extends StatefulWidget {
  const GpioScreen({super.key});

  @override
  State<GpioScreen> createState() => _GpioScreenState();
}

class _GpioScreenState extends State<GpioScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gpio',
      home: Scaffold(
        appBar: AppBar(
          title: Text('장치 제어'),
        ),
        body: Center(
          child: Text(
            'Gpio',
            style: TextStyle(
              fontSize: 24, // 글자 크기
              fontWeight: FontWeight.bold, // 글자 두께
            ),
          ),
        ),
      ),
    );
  }
}