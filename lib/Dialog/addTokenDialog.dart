// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:store_management_system/Firebase/gpio.dart';

  
//   // 토큰 입력 팝업
//   void _showTokenInputDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String localToken = token;
//         return AlertDialog(
//           title: Text(
//             'SmartThings Token',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: TextField(
//             decoration: InputDecoration(
//               labelText: 'Token',
//               border: OutlineInputBorder(),
//             ),
//             onChanged: (value) => localToken = value,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Firestore의 userDoc 업데이트
//                 try {
//                   // gpio 컬렉션의 모든 문서 가져오기
//                   final gpioDocs = await gpio_collection.get();

//                   // 문서가 있는지 확인
//                   if (gpioDocs.docs.isNotEmpty) {
//                     // 문서가 있으면 모든 문서 삭제
//                     for (var doc in gpioDocs.docs) {
//                       await gpio_collection.doc(doc.id).delete();
//                     }
//                     print(
//                         "All documents in GPIO collection have been deleted.");
//                   } else {
//                     print("No documents found in GPIO collection.");
//                   }

//                   await FirebaseFirestore.instance
//                       .collection('login')
//                       .doc(widget.userDoc.id) // userDoc의 ID를 사용
//                       .update({'token': localToken}); // token 필드 업데이트

//                   // 로컬 상태 업데이트
//                   setState(() {
//                     token = localToken; // 토큰 저장
//                   });

//                   _loadDevices(); // 디바이스 로드
//                   Navigator.pop(context);
//                 } catch (e) {
//                   print("Error updating token: $e");
//                 }
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }