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
                        onPressed: () async {
                          // 삭제 버튼 클릭 시의 동작 정의
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Delete Worker',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content:
                                    Text('${data['name']}님의 모든 정보를 삭제하시겠습니까?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 다이얼로그 닫기
                                    },
                                    child: Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(); // 다이얼로그 닫기
                                      fireStoreWorkers
                                          .deleteWorker(documentSnapshot.id);
                                      await deleteAllEvents(data['name']);
                                      
                                    },
                                    child: Text('삭제'),
                                  ),
                                ],
                              );
                            },
                          );
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

  void showSalaryDialog(BuildContext context, Map<String, dynamic> data) async {
    int month = DateTime.now().month;
    double totalMinutes = 0.0; // 총 근무 시간을 분 단위로 저장할 변수
    double totalHours = 0.0;

    // 이번 달의 calendar_events 쿼리
    final FireStoreCalendar fireStoreCalendar = FireStoreCalendar();
    QuerySnapshot querySnapshot = await fireStoreCalendar.product
        .where('name', isEqualTo: data['name'])
        .get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> eventData = doc.data() as Map<String, dynamic>;

      Event event = Event(
        id: doc.id,
        name: eventData['name'],
        startTime: eventData['start_time'].toDate(),
        endTime: eventData['end_time'].toDate(),
        realStart: eventData['real_start'].toDate(),
        realEnd: eventData['real_end'].toDate()
      );

      if (event.startTime.month == month) {
        // 근무 시간 계산
        Duration duration = event.endTime.difference(event.startTime);
        totalMinutes += duration.inMinutes.toDouble(); // 총 근무 시간을 분 단위로 누적
        print(totalMinutes);
      }
      totalHours = totalMinutes / 60;
      print('totalHours : ${totalHours}');
    }

    // 급여 계산
    num SalaryNo33 = totalHours * data['hourlyRate']; // 시급 계산 시 시간으로 변환
    num SalaryYes33 = SalaryNo33 - (SalaryNo33 * (3.3 / 100));

    // 금액 형식화
    String formattedSalaryNo33 = NumberFormat('#,###,##0원').format(SalaryNo33);
    String formattedSalaryYes33 =
        NumberFormat('#,###,##0 원').format(SalaryYes33);
    String formattedHourlyRate =
        NumberFormat('#,###,##0 원').format(data['hourlyRate']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${month}월 \'${data['name']}\' 급여'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${data['duty33'] ? formattedSalaryYes33 : formattedSalaryNo33}',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color:Color(0xFFD62B2B) ),
              ),
              SizedBox(height: 20),
              Text('시급: ${formattedHourlyRate}'),
              Text(
                  '총 근무 시간: ${NumberFormat('0.00').format(totalHours)} 시간'), // 총 근무 시간 표시 (시 단위)
              Text('3.3% 세금 적용 (${data['duty33'] ? "O" : "X"})'),
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
        content: Text("$workerName님의 모든 정보가 삭제되었습니다."),
      ),
    );
  }
}
