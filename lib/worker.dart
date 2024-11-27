import 'package:flutter/material.dart';

class WorkerManage extends StatefulWidget {
  const WorkerManage({super.key});

  @override
  State<WorkerManage> createState() => _WorkerManageState();
}

class _WorkerManageState extends State<WorkerManage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '알바생 관리',
      home: Scaffold(
        appBar: AppBar(
          title: Text('알바생'),
        ),
        body: Center(
          child: Text(
            '알바생 목록',
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