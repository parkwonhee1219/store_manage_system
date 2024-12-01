import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store_management_system/Screen/calendar.dart';
import 'package:store_management_system/Screen/gpio.dart';

class HomeScreen extends StatefulWidget {
  final DocumentSnapshot userDoc; // userDoc을 생성자에서 받도록 변경

  const HomeScreen({Key? key, required this.userDoc}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // bottom navigation setting
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  
  // const 키워드를 삭제합니다.
  late final List<Widget> _widgetOptions; // Widget 리스트를 초기화합니다.

  @override
  void initState() {
    super.initState();
    
    // GpioScreen을 생성할 때 userDoc을 전달합니다.
    _widgetOptions = <Widget>[
      CalendarScreen(),
      GpioScreen(userDoc: widget.userDoc), // 명명된 인자로 userDoc 전달
      Text(
        '사용자 정보',
        style: optionStyle,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면을 구성하는 데 사용되는 메인 위젯인 Scaffold을 반환
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sensors_outlined), label: 'Gpio'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 231, 109, 109),
        onTap: _onItemTapped,
      ),
    );
  }
}
