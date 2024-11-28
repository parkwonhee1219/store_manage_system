import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_management_system/Firebase/calendar_events.dart';
import 'package:store_management_system/Firebase/workers.dart';

Future<void> addCalendarDialog(BuildContext context, DateTime selectedDay) async {
  String selectedWorkerName = '';
  String? selectedStartHour;
  String? selectedStartMin;
  String? selectedEndHour;
  String? selectedEndMin;

  FireStoreCalendar fireStoreCalendar = FireStoreCalendar();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final workerModel = Provider.of<WorkerModel>(context);

          return AlertDialog(
            title: Text('Add Work'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  hint: Text('근무자 선택'),
                  value: selectedWorkerName.isNotEmpty ? selectedWorkerName : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWorkerName = newValue!;
                    });
                  },
                  items: workerModel.workersList.map((worker) {
                    return DropdownMenuItem<String>(
                      value: worker.name,
                      child: Text(worker.name),
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    Text('출근 시간 : '),
                    DropdownButton<String>(
                      dropdownColor: Colors.white,
                      hint: Text('(시)'),
                      value: selectedStartHour,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStartHour = newValue;
                        });
                      },
                      items: List.generate(24, (index) => index.toString().padLeft(2, '0'))
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
                      items: List.generate(60, (index) => index.toString().padLeft(2, '0'))
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
                  children: [
                    Text('퇴근 시간 : '),
                    DropdownButton<String>(
                      dropdownColor: Colors.white,
                      hint: Text('(시)'),
                      value: selectedEndHour,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedEndHour = newValue;
                        });
                      },
                      items: List.generate(24, (index) => index.toString().padLeft(2, '0'))
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
                      items: List.generate(60, (index) => index.toString().padLeft(2, '0'))
                          .map<DropdownMenuItem<String>>((String min) {
                        return DropdownMenuItem<String>(
                          value: min,
                          child: Text(min),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  if (selectedWorkerName.isNotEmpty &&
                      selectedStartHour != null && selectedStartMin != null &&
                      selectedEndHour != null && selectedEndMin != null) {
                    
                    // Firestore에 저장할 DateTime 객체 생성
                    DateTime now = DateTime.now();
                    DateTime startDateTime = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 
                        int.parse(selectedStartHour!), int.parse(selectedStartMin!));
                    DateTime endDateTime = DateTime(now.year, now.month, now.day, 
                        int.parse(selectedEndHour!), int.parse(selectedEndMin!));

                    await fireStoreCalendar.product.add({
                      'id' : '',
                      'name': selectedWorkerName,
                      'start_time': Timestamp.fromDate(startDateTime),
                      'end_time': Timestamp.fromDate(endDateTime),
                    });

                    Navigator.of(context).pop();
                  }
                },
                child: Text('추가'),
              ),
            ],
          );
        },
      );
    },
  );
}
