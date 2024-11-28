import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  //각 evnet 객체 class
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;

  Event(
      {required this.id,
      required this.name,
      required this.startTime,
      required this.endTime});
}

class FireStoreCalendar {
  CollectionReference product =
      FirebaseFirestore.instance.collection('calendar_events');

  // Worker 삭제
  Future<void> deleteEvent(String eventId) async {
    //final DocumentSnapshot documentSnapshot = product_workers.snapshots()
    await product.doc(eventId).delete();
  }
}
