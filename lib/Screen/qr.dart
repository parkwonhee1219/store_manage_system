import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:store_management_system/Firebase/calendar_events.dart';
import 'package:store_management_system/Firebase/workers.dart';
import 'package:table_calendar/table_calendar.dart';

class QrScreen extends StatefulWidget {
  final DocumentSnapshot userDoc; // userDoc을 생성자에서 받도록 변경

  const QrScreen({Key? key, required this.userDoc}) : super(key: key);

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  CollectionReference product =
      FirebaseFirestore.instance.collection('calendar_events');

  Map<DateTime, List<Event>> events = {}; //모든 event를 저장할 Map
  List<Event> _selectedEvents = []; // 선택된 날짜의 이벤트 리스트

  //table calendar setting
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat =
      CalendarFormat.month; //사용자가 달력을 어떻게 볼지 지정 (한달 단위? 2주 단위? 1주 단위?)

  Future<void> _getEvents() async {
    //Firestore에서 이벤트 가져와서 events map에 저장
    product.where('name', isEqualTo: widget.userDoc['name']).snapshots().listen((snapshot) {
      events.clear(); //events map 초기화
      for (var doc in snapshot.docs) {
        Timestamp startTime = doc['start_time'];
        Timestamp endTime = doc['end_time'];
        String name = doc['name'];
        String id = doc.id;
        Timestamp realStart = doc['real_start'];
        Timestamp realEnd = doc['real_end'];

        DateTime startDateTime = startTime.toDate();
        DateTime endDateTime = endTime.toDate();
        DateTime dateKey = DateTime.utc(startDateTime.year, startDateTime.month,
            startDateTime.day); //이벤트 추가될 날짜(년,월,일)
        DateTime realStartToDate = realStart.toDate();
        DateTime realEndToDate = realEnd.toDate();

        //Event 객체 생성
        Event event = Event(
            id: id,
            name: name,
            startTime: startDateTime,
            endTime: endDateTime,
            realStart: realStartToDate,
            realEnd: realEndToDate);

        // 날짜에 이벤트 추가
        if (events[dateKey] == null) {
          events[dateKey] = [];
        }
        events[dateKey]!.add(event);
      }
      setState(() {
        _selectedEvents = events[_selectedDay] ?? [];
      }); // 상태 업데이트

      print(events);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? []; // 해당 날짜의 이벤트 반환
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
        _selectedEvents = events[selectedDay] ?? []; // 선택된 날짜의 이벤트 가져오기
        print(selectedDay);
      });
    }
  }

  void _onQrIconPressed() {
     Uint8List imgBytes = base64Decode(widget.userDoc['qr_img_base64']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Qr code',style: TextStyle(fontWeight: FontWeight.bold),),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          //       Text(
          //     '${widget.userDoc['name']}',
          //     style: TextStyle(
          //       fontSize: 24, // 글자 크기
          //       fontWeight: FontWeight.bold, // 글자 두께
          //     ),
          // ),
              Image.memory(imgBytes, height: 200, width: 200,),
            ],
          ),
          actions: [
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getEvents();
    _selectedEvents = events[_selectedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final workerModel =
        Provider.of<WorkerModel>(context); // WorkerModel 인스턴스 가져오기
    final FireStoreCalendar fireStoreCalendar = FireStoreCalendar();
    final FireStoreWorkers fireStoreWorkers = FireStoreWorkers();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 5), // 제목 앞의 여백
            Text('Calendar'),
          ],
        ),
        actions: [
          IconButton(
              onPressed: _onQrIconPressed,
              icon: Icon(
                Icons.qr_code_2,
                color: Colors.black,
                size: 30,
              )),
          SizedBox(
            width: 17,
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            daysOfWeekHeight: 30,
            locale: 'ko-KR',
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: _onDaySelected,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 231, 109, 109), // 선택된 날짜의 동그라미 색상
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 245, 157, 157), // 오늘 날짜의 동그라미 색상
                shape: BoxShape.circle,
              ),
            ),
            // 이벤트 표시를 위한 eventLoader 추가
            eventLoader: (day) {
              return _getEventsForDay(day); // 각 날짜에 대한 이벤트 반환
            },
            // 이벤트 표시를 위한 calendarBuilders 추가
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Container(
                          width: 7.0,
                          height: 7.0,
                          decoration: const BoxDecoration(
                            // color: Color.fromARGB(255, 47, 113, 77),
                            color: Color.fromARGB(255, 125, 125, 125),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    DateFormat('yyyy.MM.dd', 'ko')
                        .format(_selectedDay)
                        .toString(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 2.0)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedEvents[index];

                // event.name에 해당하는 Worker 객체 찾기
                final worker = workerModel.workersList.firstWhere(
                  (worker) => worker.name == event.name,
                  orElse: () => Worker(
                      name: 'Unknown',
                      fixedWorkHours: [],
                      monthlyHours: 0,
                      hourlyRate: 0,
                      duty33: false,
                      gender: ''), // 기본 Worker 객체 반환
                );

                // 성별에 따라 아이콘 색상 설정
                Color iconColor = worker.gender == '여'
                    ? Color.fromARGB(255, 231, 109, 109)
                    : Color.fromARGB(255, 47, 113, 77);

                return Dismissible(
                  key: Key(event.id), // 고유한 키를 제공
                  background: Container(
                    color:
                        Color.fromARGB(255, 231, 109, 109), // 슬라이드 시 나타나는 배경색
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white), // 삭제 아이콘
                  ),
                  direction: DismissDirection.startToEnd, // 오른쪽에서 왼쪽으로 슬라이드
                  onDismissed: (direction) {
                    // 이벤트 삭제 처리
                    fireStoreCalendar.deleteEvent(event.id);
                    print('delete');
                    // 삭제 알림
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("삭제되었습니다."),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0), // 마진 추가
                    decoration: BoxDecoration(
                      color: Colors.transparent, // 배경색
                      border: Border.all(color: Colors.black), // 검정색 테두리
                      borderRadius: BorderRadius.circular(10.0), // 라운딩 처리
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0), // 아이콘 주변 패딩
                          child: Icon(Icons.person,
                              size: 40.0, color: iconColor), // 사람 아이콘
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(event.name,
                                style: TextStyle(fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // 텍스트 정렬
                              children: [
                                Text(
                                  '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                                ),
                                // 추가적인 텍스트
                                Text(
                                    '출퇴근 : ${DateFormat("HH:mm").format(event.realStart)} - ${DateFormat('HH:mm').format(event.realEnd)}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     addCalendarDialog(context, _selectedDay);
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}


  // @override
  // Widget build(BuildContext context) {
  //   Uint8List imgBytes = base64Decode(widget.userDoc['qr_img_base64']);

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Row(
  //         children: [
  //           SizedBox(width: 5), // 제목 앞의 여백
  //           Text('Qr Screen'),
  //         ],
  //       ),
  //     ),
  //     body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Text(
  //             '${widget.userDoc['name']}',
  //             style: TextStyle(
  //               fontSize: 24, // 글자 크기
  //               fontWeight: FontWeight.bold, // 글자 두께
  //             ),
  //         ),
  //             Image.memory(imgBytes, height: 200, width: 200,),
  //       ],
  //     )),
  //   );
  // }