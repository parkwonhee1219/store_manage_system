import 'package:flutter/material.dart';
import 'package:store_management_system/Screen/calendar.dart';
import 'package:store_management_system/Screen/gpio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //bottom navigation setting
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    CalendarScreen(),
    GpioScreen(),
    Text(
      '사용자 정보',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면을 구성하는 데 사용되는 메인 위젯인 Scaffold을 반환
    return Scaffold(
      // 달력을 표시하는 TableCalendar 위젯을 body에 추가
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