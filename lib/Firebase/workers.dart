import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkHours {
  String? day; // 요일 (예: "월요일")
  String? startTime; // 출근 시간 (예: "09:00")
  String? endTime; // 퇴근 시간 (예: "17:00")

  WorkHours(
      {required this.day, required this.startTime, required this.endTime});
}

class Worker {
  final String name; // 이름
  final List<WorkHours> fixedWorkHours; // 고정 근무 시간
  final num monthlyHours; // 월별 누적 근무 시간
  final int hourlyRate; // 시급
  final bool duty33; // 3.3% 세금 적용 여부
  final String gender;

  Worker({
    required this.name,
    required this.fixedWorkHours,
    required this.monthlyHours,
    required this.hourlyRate,
    required this.duty33,
    required this.gender,
  });
}

//FireStore 'Workers' Collection Read
class WorkerModel with ChangeNotifier {
  List<Worker> _workersList = [];
  List<Worker> get workersList => _workersList;

  WorkerModel() {
    _getWorkers(); // 인스턴스 생성 -> WorkerModel()생성자 호출 -> _getWorkers()메서드 호출
  }

  void _getWorkers() {
    CollectionReference product_workers =
        FirebaseFirestore.instance.collection('workers');

    // Firestore의 실시간 업데이트 리스너 설정
    product_workers.snapshots().listen((snapshot) {
      List<Worker> workersList = []; // 새로운 리스트 초기화

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        print('고정근무시간 : ${data['fixedWorkHours']}');

        // 고정 근무 시간을 리스트로 변환
        List<WorkHours> workHoursList =
            (data['fixedWorkHours'] as List<dynamic>).map((item) {
          return WorkHours(
            day: item['day'],
            startTime: item['start_time'],
            endTime: item['end_time'],
          );
        }).toList();

        // Worker 객체 생성
        Worker worker = Worker(
          name: data['name'],
          fixedWorkHours: workHoursList,
          monthlyHours: data['monthlyHours'],
          hourlyRate: data['hourlyRate'],
          duty33: data['duty33'],
          gender: data['gender'],
        );

        workersList.add(worker);
      }

      // 상태 업데이트
      _workersList = workersList; // 리스트 업데이트
      notifyListeners(); // 리스너 알림
    });
  }

  DateTime parseTime(String time) {
    final parts = time.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }
}

//FireStore 'Workers' Collection Create, Update, Delete
class FireStoreWorkers {
  final CollectionReference product_workers =
      FirebaseFirestore.instance.collection('workers');

  // Worker 추가
  Future<void> addWorker(Worker worker) async {
    await product_workers.add({
      'name': worker.name,
      'fixedWorkHours': worker.fixedWorkHours
          .map((workhour) => {
                'day': workhour.day,
                'start_time': workhour.startTime,
                'end_time': workhour.endTime,
              })
          .toList(),
      'monthlyHours': worker.monthlyHours,
      'hourlyRate': worker.hourlyRate,
      'duty33': worker.duty33,
      'gender': worker.gender,
    });
  }

  // Worker 삭제
  Future<void> deleteWorker(String workerId) async {
    //final DocumentSnapshot documentSnapshot = product_workers.snapshots()
    await product_workers.doc(workerId).delete();
  }

  // Worker 수정
  Future<void> updateWorker(String workerId, Worker updatedWorker) async {
    await product_workers.doc(workerId).update({
      'name': updatedWorker.name,
      'fixedWorkHours': updatedWorker.fixedWorkHours
          .map((workhour) => {
                'day': workhour.day,
                'start_time': workhour.startTime,
                'end_time': workhour.endTime,
              })
          .toList(),
      'monthlyHours': updatedWorker.monthlyHours,
      'hourlyRate': updatedWorker.hourlyRate,
      'duty33': updatedWorker.duty33,
      'gender': updatedWorker.gender,
    });
  }
}
