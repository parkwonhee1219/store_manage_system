import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store_management_system/Firebase/calendar_events.dart';
import 'package:store_management_system/Firebase/workers.dart';

Future<void> addWorkerDialog(BuildContext context) async {
  FireStoreWorkers fireStoreWorkers = FireStoreWorkers(); // add 함수를 위한 인스턴스 생성
  FireStoreCalendar fireStoreCalendar = FireStoreCalendar();

  final nameController = TextEditingController();
  final hourlyRateController = TextEditingController();
  String? selectedGender; // 성별 선택을 위한 변수
  bool? duty33;
  List<WorkHours> fixedWorkHours = []; // 근무 시간 입력을 위한 리스트
  String? selectedDay;
  String? selectedStartHour;
  String? selectedStartMin;
  String? selectedEndHour;
  String? selectedEndMin;

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text('New Worker',style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '이름',
                    ),
                  ),
                  TextField(
                    controller: hourlyRateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '시급 (원)'),
                  ),
                  DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value: selectedGender,
                    hint: Text('성별 선택'),
                    items: <String>['남', '여'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGender = newValue;
                      });
                    },
                  ),
                  DropdownButton<bool>(
                    dropdownColor: Colors.white,
                    value: duty33,
                    hint: Text('세금 선택'),
                    items: <bool>[
                      true, // 세금 적용
                      false, // 세금 미적용
                    ].map((bool value) {
                      return DropdownMenuItem<bool>(
                        value: value,
                        child: Text('${value ? "3.3% 적용" : "안 함"}'),
                      );
                    }).toList(),
                    onChanged: (bool? newValue) {
                      setState(() {
                        duty33 = newValue;
                      });
                    },
                  ),
                  // 근무 시간 입력 UI 추가
                  // 근무 시간이 추가되면 기존 항목들 표시
                  ...fixedWorkHours.map((entry) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          entry.day ?? '기본요일',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFD62B2B),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          entry.startTime ?? '00:00',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFD62B2B),
                          ),
                        ),
                        Text(
                          ' - ',
                          style: TextStyle(color: Color(0xFFD62B2B)),
                        ),
                        Text(
                          entry.endTime ?? '00:00',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFD62B2B),
                          ),
                        ),
                      ],
                    );
                  }).toList(),

                  SizedBox(
                    height: 10,
                  ),

                  Column(
                    children: [
                      DropdownButton<String>(
                        dropdownColor: Colors.white,
                        hint: Text('요일'),
                        value: selectedDay,
                        items: <String>[
                          '월요일',
                          '화요일',
                          '수요일',
                          '목요일',
                          '금요일',
                          '토요일',
                          '일요일'
                        ].map((String day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDay = newValue;
                          });
                        },
                      ),
                      SizedBox(width: 5), // 줄바꿈 추가
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '출근 : ',
                          ),
                          DropdownButton<String>(
                            dropdownColor: Colors.white,
                            hint: Text('(시)'),
                            value: selectedStartHour,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStartHour = newValue;
                              });
                            },
                            items: List.generate(24,
                                    (index) => index.toString().padLeft(2, '0'))
                                .map<DropdownMenuItem<String>>((String hour) {
                              return DropdownMenuItem<String>(
                                value: hour,
                                child: Text(hour),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 8),
                          DropdownButton<String>(
                            dropdownColor: Colors.white,
                            hint: Text('(분)'),
                            value: selectedStartMin,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStartMin = newValue;
                              });
                            },
                            items: List.generate(
                                    6,
                                    (index) =>
                                        (index * 10).toString().padLeft(2, '0'))
                                .map<DropdownMenuItem<String>>((String min) {
                              return DropdownMenuItem<String>(
                                value: min,
                                child: Text(min),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '퇴근 : ',
                          ),
                          DropdownButton<String>(
                            dropdownColor: Colors.white,
                            hint: Text('(시)'),
                            value: selectedEndHour,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedEndHour = newValue;
                              });
                            },
                            items: List.generate(24,
                                    (index) => index.toString().padLeft(2, '0'))
                                .map<DropdownMenuItem<String>>((String hour) {
                              return DropdownMenuItem<String>(
                                value: hour,
                                child: Text(hour),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 8),
                          DropdownButton<String>(
                            dropdownColor: Colors.white,
                            hint: Text('(분)'),
                            value: selectedEndMin,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedEndMin = newValue;
                              });
                            },
                            items: List.generate(
                                    6,
                                    (index) =>
                                        (index * 10).toString().padLeft(2, '0'))
                                .map<DropdownMenuItem<String>>((String min) {
                              return DropdownMenuItem<String>(
                                value: min,
                                child: Text(min),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      TextButton(
                        onPressed: () {
                          // 새로운 근무시간 항목 추가
                          WorkHours newEntry = WorkHours(
                            day: selectedDay ?? '기본요일', // 기본값 설정
                            startTime:
                                "${selectedStartHour ?? '00'}:${selectedStartMin ?? '00'}",
                            endTime:
                                "${selectedEndHour ?? '00'}:${selectedEndMin ?? '00'}",
                          );
                          setState(() {
                            fixedWorkHours.add(newEntry);

                            // 입력 필드 초기화
                            selectedDay = null;
                            selectedStartHour = null;
                            selectedStartMin = null;
                            selectedEndHour = null;
                            selectedEndMin = null;
                          });
                        },
                        child: Text(
                          '저장',
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFFD62B2B)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              '취소',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
          TextButton(
            child: Text(
              '추가',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () async {
              final name = nameController.text;
              final hourlyRate = int.tryParse(hourlyRateController.text) ?? 0;
              DateTime now = DateTime.now();
              DateTime firstDay = DateTime(now.year, now.month, 1);
              DateTime nextFirstDay = DateTime(now.year, now.month + 1, 1);

              // Worker 객체 생성
              Worker newWorker = Worker(
                name: name,
                fixedWorkHours: fixedWorkHours,
                monthlyHours: 0,
                hourlyRate: hourlyRate,
                duty33: duty33 ?? false,
                gender: selectedGender ?? '남', // 기본값 '남' 설정
              );

              // Worker 추가
              await fireStoreWorkers.addWorker(newWorker);

              // Firestore Batch Writes 사용
              WriteBatch batch = FirebaseFirestore.instance.batch();

              // 근무시간을 기반으로 이벤트 추가
              for (var workHour in fixedWorkHours) {
                // 선택한 요일을 숫자로 매핑
                int dayOfWeek = workHour.day == '월요일'
                    ? DateTime.monday
                    : workHour.day == '화요일'
                        ? DateTime.tuesday
                        : workHour.day == '수요일'
                            ? DateTime.wednesday
                            : workHour.day == '목요일'
                                ? DateTime.thursday
                                : workHour.day == '금요일'
                                    ? DateTime.friday
                                    : workHour.day == '토요일'
                                        ? DateTime.saturday
                                        : workHour.day == '일요일'
                                            ? DateTime.sunday
                                            : 0;

                for (DateTime date = firstDay;
                    date.isBefore(nextFirstDay);
                    date = date.add(Duration(days: 1))) {
                  if (date.weekday == dayOfWeek) {
                    // 이벤트 시작 및 종료 시간 설정
                    Timestamp startTime = Timestamp.fromDate(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      int.parse(workHour.startTime?.split(':')[0] ?? '00'),
                      int.parse(workHour.startTime?.split(':')[1] ?? '00'),
                    ));

                    Timestamp endTime = Timestamp.fromDate(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      int.parse(workHour.endTime?.split(':')[0] ?? '00'),
                      int.parse(workHour.endTime?.split(':')[1] ?? '00'),
                    ));

                    Timestamp realStart = Timestamp.fromDate(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      00,
                      00,
                    ));

                    Timestamp realEnd = Timestamp.fromDate(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      00,
                      00,
                    ));

                    print('newEvent : ${name},${startTime},${endTime}');

                    // 이벤트 Firestore에 추가를 배치에 추가
                    DocumentReference docRef =
                        fireStoreCalendar.product.doc(); // 새로운 문서 참조 생성
                    batch.set(docRef, {
                      'name': name,
                      'start_time': startTime,
                      'end_time': endTime,
                      'real_start' : realStart,
                      'real_end' : realEnd
                    });
                  }
                }
              }

              Navigator.of(context).pop(); // 다이얼로그 닫기
              // 모든 배치 작업을 커밋합니다.
              await batch.commit();
            },
          ),
        ],
      );
    },
  );
}
