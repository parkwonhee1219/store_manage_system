import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:store_management_system/worker_screen.dart';
import 'package:store_management_system/workers.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  //각 evnet 객체 class
  final String name;
  final DateTime startTime;
  final DateTime endTime;

  Event({required this.name, required this.startTime, required this.endTime});
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
    product.snapshots().listen((snapshot) {
      events.clear(); //events map 초기화
      for (var doc in snapshot.docs) {
        Timestamp startTime = doc['start_time'];
        Timestamp endTime = doc['end_time'];
        String name = doc['name'];

        DateTime startDateTime = startTime.toDate();
        DateTime endDateTime = endTime.toDate();
        DateTime dateKey = DateTime.utc(startDateTime.year, startDateTime.month,
            startDateTime.day); //이벤트 추가될 날짜(년,월,일)

        //Event 객체 생성
        Event event =
            Event(name: name, startTime: startDateTime, endTime: endDateTime);

        // 날짜에 이벤트 추가
        if (events[dateKey] == null) {
          events[dateKey] = [];
        }
        events[dateKey]!.add(event);
      }
      setState(() {}); // 상태 업데이트

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

  void _onPersonIconPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WorkerManage()));
  }

  void _showAddDialog() {
    // 다이얼로그를 통해 이벤트 추가
    showDialog(
        context: context,
        builder: (context) {
          String title = '';
          return AlertDialog(
            title: Text('Add Work'),
            content: TextField(
              onChanged: (value) {
                title = value;
              },
              decoration: InputDecoration(hintText: '이벤트 제목'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  //여기에 근무 추가하는 함수
                  Navigator.of(context).pop();
                },
                child: Text('추가'),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _getEvents();
  }

  @override
  Widget build(BuildContext context) {
    final workerModel =
        Provider.of<WorkerModel>(context); // WorkerModel 인스턴스 가져오기
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
              onPressed: _onPersonIconPressed,
              icon: Icon(
                Icons.person,
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
                            color: Color.fromARGB(255, 47, 113, 77),
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

                return Container(
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
                            size: 40.0,
                            color: iconColor), // 사람 아이콘
                      ),
                      Expanded(
                        child: ListTile(
                          title:
                              Text(event.name, style: TextStyle(fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // 텍스트 정렬
                            children: [
                              Text(
                                '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                              ),
                              // 추가적인 텍스트
                              Text('출퇴근 : '),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
