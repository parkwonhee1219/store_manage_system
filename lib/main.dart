import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:store_management_system/Firebase/workers.dart';
import 'package:store_management_system/Screen/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null); // 한국어 로케일 초기화
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => WorkerModel()), //WorkerModel 인스턴스 생성
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          //primarySwatch: customRedColor,
          //useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.black,
            secondary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          //colorSchemeSeed: Colors.white,
          //dropdownMenuTheme:DropdownMenuThemeData() ,
          dialogBackgroundColor: Colors.white,
          textTheme: TextTheme(),
          appBarTheme: AppBarTheme(
            color: Colors.white,
            // color: const Color.fromARGB(255, 41, 116, 99),
            //color: const Color.fromARGB(255, 215, 66, 66),
            titleTextStyle: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            //toolbarHeight: 50
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: const Color.fromARGB(255, 231, 109, 109),
              foregroundColor: Colors.white)),
      home: LoginScreen(),
    );
  }
}

// const MaterialColor customRedColor = MaterialColor(
//   0xFFFFFFFF, // 주 색상 (Hex)
//   <int, Color>{
//     0 : Color(0xFFFFFFFF),
//     50: Color(0xFFFDE7E7), // 50% opacity
//     100: Color(0xFFFAB8B8), // 100% opacity
//     200: Color(0xFFE76D6D), // 200% opacity (주 색상)
//     300: Color(0xFFD62B2B), // 300% opacity
//     400: Color(0xFFC72B2B), // 400% opacity
//     500: Color(0xFFA82A2A), // 500% opacity
//     600: Color(0xFF931C1C), // 600% opacity
//     700: Color(0xFF7D1515), // 700% opacity
//     800: Color(0xFF691010), // 800% opacity
//     900: Color(0xFF5B0C0C), // 900% opacity
//   },
// );

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   //bottom navigation setting
//   int _selectedIndex = 0;
//   static const TextStyle optionStyle =
//       TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
//   static const List<Widget> _widgetOptions = <Widget>[
//     CalendarScreen(),
//     GpioScreen(),
//     Text(
//       '사용자 정보',
//       style: optionStyle,
//     ),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 화면을 구성하는 데 사용되는 메인 위젯인 Scaffold을 반환
//     return Scaffold(
//       // 달력을 표시하는 TableCalendar 위젯을 body에 추가
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),

//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_month), label: 'Calendar'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.sensors_outlined), label: 'Gpio'),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Color.fromARGB(255, 231, 109, 109),
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
