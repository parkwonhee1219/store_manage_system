import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '알바생 근태관리',
      home: Scaffold(
        appBar: AppBar(
          title: Text('알바생 근태관리'),
        ),
        body: Center(
          child: Text(
            'Calendar',
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