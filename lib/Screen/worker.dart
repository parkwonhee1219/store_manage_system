import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:store_management_system/Dialog/addWorkerDialog.dart';
import 'package:store_management_system/Firebase/calendar_events.dart';
import 'package:store_management_system/Firebase/workers.dart';

class WorkerManage extends StatefulWidget {
  const WorkerManage({super.key});

  @override
  State<WorkerManage> createState() => _WorkerManageState();
}

class _WorkerManageState extends State<WorkerManage> {
  @override
  Widget build(BuildContext context) {
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
              itemCount: streamSnapshot.data!.docs.length, // workersList의 길이
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                // 문서 데이터 가져오기
                Map<String, dynamic> data =
                    documentSnapshot.data() as Map<String, dynamic>;

                return ListTile(
                  leading: Icon(
                    Icons.person,
                    color: data['gender'] == '여'
                        ? Color.fromARGB(255, 231, 109, 109)
                        : Color.fromARGB(255, 47, 113, 77),
                    size: 40,
                  ), // 사람 아이콘 추가
                  title: Text('${data['name']}'), // 근무자 이름 표시
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
                    children: List.generate(data['fixedWorkHours'].length,
                        (dayIndex) {
                      // 각 고정 근무 시간에 대해 Text 위젯 생성
                      final workHour = data['fixedWorkHours'][dayIndex];
                      return Text(
                        '${workHour['day']} ${workHour['start_time']} - ${workHour['end_time']}',
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
                          showSalaryDialog(context, data);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete), // 삭제 아이콘
                        onPressed: () async{
                          // 삭제 버튼 클릭 시의 동작 정의
                          await deleteAllEvents(data['name']);
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
          onPressed: () {
            addWorkerDialog(context);
          },
          child: Icon(Icons.add), // 더하기 아이콘
          tooltip: 'New Worker',
        ),
      ),
    );
  }

  void showSalaryDialog(BuildContext context, Map<String, dynamic> data) {
    int month = DateTime.now().month;
    double SalaryNo33 =
        (double.parse(data['monthlyHours'])) * (data['hourlyRate']);
    double SalaryYes33 = SalaryNo33 - ((SalaryNo33) * (3.3 / 100));
    // 금액 형식화
    String formattedSalaryNo33 = NumberFormat('#,###,##0원').format(SalaryNo33);
    String formattedSalaryYes33 =
        NumberFormat('#,###,##0원').format(SalaryYes33);
    String formattedHourlyRate =
        NumberFormat('#,###,##0원').format(data['hourlyRate']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${month}월 \'${data['name']}\' 급여'), // 다이얼로그 제목
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ' ${data['duty33'] ? formattedSalaryYes33 : formattedSalaryNo33} ',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              Text('시급: ${formattedHourlyRate}'),
              Text('총 근무 시간: ${data['monthlyHours']} 시간'),
              Text('3.3% 세금 적용 (${data['duty33'] ? "O" : "X"})'), // duty33 값 표시
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

  Future<void> deleteAllEvents(String workerName) async {
  final FireStoreCalendar fireStoreCalendar = FireStoreCalendar();
  WriteBatch batch = FirebaseFirestore.instance.batch(); // Batch 객체 생성

  // 해당 이름을 가진 모든 이벤트를 쿼리
  QuerySnapshot querySnapshot = await fireStoreCalendar.product
      .where('name', isEqualTo: workerName)
      .get();

  // 각 문서를 삭제를 배치에 추가
  for (var doc in querySnapshot.docs) {
    batch.delete(fireStoreCalendar.product.doc(doc.id)); // 삭제 작업 추가
  }

  // 배치 작업 커밋
  await batch.commit();

  // 삭제 알림
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("$workerName의 모든 이벤트가 삭제되었습니다."),
    ),
  );
}

}
