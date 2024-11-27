import 'package:flutter/material.dart';

class GpioScreen extends StatefulWidget {
  const GpioScreen({super.key});

  @override
  State<GpioScreen> createState() => _GpioScreenState();
}

class _GpioScreenState extends State<GpioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 5), // 제목 앞의 여백
            Text('Gpio'),
          ],
        ),
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
    );
  }
}
