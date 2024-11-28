import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:store_management_system/dialog.dart';
import 'package:store_management_system/workers.dart';

class WorkerManage extends StatefulWidget {
  const WorkerManage({super.key});

  @override
  State<WorkerManage> createState() => _WorkerManageState();
}

class _WorkerManageState extends State<WorkerManage> {
  @override
  Widget build(BuildContext context) {
    final workerModel =
        Provider.of<WorkerModel>(context); // WorkerModel 인스턴스 가져오기
    final FireStoreWorkers fireStoreWorkers = FireStoreWorkers();

    return Scaffold(
      appBar: AppBar(
        title: Text('Workers'),
      ),
      body: StreamBuilder(
        stream: fireStoreWorkers.product_workers.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: workerModel.workersList.length, // workersList의 길이
              itemBuilder: (context, index) {
                final worker = workerModel.workersList[index];
                int day_length = worker.fixedWorkHours.length;
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                return ListTile(
                  leading: Icon(
                    Icons.person,
                    color: worker.gender == '여'
                        ? Color.fromARGB(255, 231, 109, 109)
                        : Color.fromARGB(255, 47, 113, 77),
                    size: 40,
                  ), // 사람 아이콘 추가
                  title: Text('${worker.name}'), // 근무자 이름 표시
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
                    children: List.generate(day_length, (dayIndex) {
                      // 각 고정 근무 시간에 대해 Text 위젯 생성
                      final workHour = worker.fixedWorkHours[dayIndex];
                      return Text(
                        '${workHour.day} ${workHour.startTime} - ${workHour.endTime}',
                        style: TextStyle(fontSize: 14), // 필요에 따라 스타일 조정
                      );
                    }),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Row의 크기를 최소화
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_money_outlined), // 달라 아이콘
                        onPressed: () {
                          // 달라 버튼 클릭 시의 동작 정의
                          showSalaryDialog(context, worker);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete), // 삭제 아이콘
                        onPressed: () {
                          // 삭제 버튼 클릭 시의 동작 정의
                          fireStoreWorkers.deleteWorker(documentSnapshot.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시
          }
        },
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 50.0, right: 0.0), // 아래와 오른쪽 여백 추가
        child: FloatingActionButton(
          onPressed: () async {
            addWorkerDialog(context);
          },
          child: Icon(Icons.add), // 더하기 아이콘
          tooltip: 'New Worker',
        ),
      ),
    );
  }

  void showSalaryDialog(BuildContext context, Worker worker) {
    int month = DateTime.now().month;
    double SalaryNo33 = (worker.monthlyHours) * (worker.hourlyRate);
    double SalaryYes33 = SalaryNo33 - ((SalaryNo33) * (3.3 / 100));
    // 금액 형식화
    String formattedSalaryNo33 = NumberFormat('#,###,##0원').format(SalaryNo33);
    String formattedSalaryYes33 =
        NumberFormat('#,###,##0원').format(SalaryYes33);
    String formattedHourlyRate =
        NumberFormat('#,###,##0원').format(worker.hourlyRate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${month}월 \'${worker.name}\' 급여'), // 다이얼로그 제목
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ' ${worker.duty33 ? formattedSalaryYes33 : formattedSalaryNo33} ',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text('시급: ${formattedHourlyRate}'),
              Text('총 근무 시간: ${worker.monthlyHours} 시간'),
              Text('3.3% 세금 적용 (${worker.duty33 ? "O" : "X"})'), // duty33 값 표시
            ],
          ),
          actions: [
            TextButton(
              child: Text('닫기'), // 닫기 버튼
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }
}
