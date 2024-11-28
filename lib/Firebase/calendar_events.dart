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

  // Future<void> addEvent(Event event) async {
  //   await product.add({
  //     'id' : '',
  //     'name': event.name,
  //     'startTime': Timestamp.fromDate(event.startTime),
  //     'endTime': Timestamp.fromDate(event.endTime),
  //   });
  // }

  // event 삭제
  Future<void> deleteEvent(String eventId) async {
    await product.doc(eventId).delete();
  }
}
